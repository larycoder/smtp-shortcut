/*++
/* NAME
/*    mail_copy 3
/* SUMMARY
/*    copy message with extreme prejudice
/* SYNOPSIS
/*    #include <mail_copy.h>
/*
/*    int    mail_copy(sender, orig_to, delivered, src, dst, flags, eol, why)
/*    const char *sender;
/*    const char *orig_to;
/*    const char *delivered;
/*    VSTREAM    *src;
/*    VSTREAM    *dst;
/*    int    flags;
/*    const char *eol;
/*    DSN_BUF    *why;
/* DESCRIPTION
/*    mail_copy() copies a mail message from record stream to stream-lf
/*    stream, and attempts to detect all possible I/O errors.
/*
/*    Arguments:
/* .IP sender
/*    The sender envelope address.
/* .IP delivered
/*    Null pointer or delivered-to: header address.
/* .IP src
/*    The source record stream, positioned at the beginning of the
/*    message contents.
/* .IP dst
/*    The destination byte stream (in stream-lf format). If the message
/*    ends in an incomplete line, a newline character is appended to
/*    the output.
/* .IP flags
/*    The binary OR of zero or more of the following:
/* .RS
/* .IP MAIL_COPY_QUOTE
/*    Prepend a `>' character to lines beginning with `From '.
/* .IP MAIL_COPY_DOT
/*    Prepend a `.' character to lines beginning with `.'.
/* .IP MAIL_COPY_TOFILE
/*    On systems that support this, use fsync() to flush the
/*    data to stable storage, and truncate the destination
/*    file to its original length in case of problems.
/* .IP MAIL_COPY_FROM
/*    Prepend a UNIX-style From_ line to the message.
/* .IP MAIL_COPY_BLANK
/*    Append an empty line to the end of the message.
/* .IP MAIL_COPY_DELIVERED
/*    Prepend a Delivered-To: header with the name of the
/*    \fIdelivered\fR attribute.
/*    The address is quoted according to RFC822 rules.
/* .IP MAIL_COPY_ORIG_RCPT
/*    Prepend an X-Original-To: header with the original
/*    envelope recipient address. This is a NOOP with
/*    var_enable_orcpt === 0.
/* .IP MAIL_COPY_RETURN_PATH
/*    Prepend a Return-Path: header with the value of the
/*    \fIsender\fR attribute.
/* .RE
/*    The manifest constant MAIL_COPY_MBOX is a convenient shorthand for
/*    all MAIL_COPY_XXX options that are appropriate for mailbox delivery.
/*    Use MAIL_COPY_NONE to copy a message without any options enabled.
/* .IP eol
/*    Record delimiter, for example, LF or CF LF.
/* .IP why
/*    A null pointer, or storage for the reason of failure in
/*    the form of a DSN detail code plus free text.
/* DIAGNOSTICS
/*    A non-zero result means the operation failed. Warnings: corrupt
/*    message file. A corrupt message is marked as corrupt.
/*
/*    The result is the bit-wise OR of zero or more of the following:
/* .IP MAIL_COPY_STAT_CORRUPT
/*    The queue file is marked as corrupt.
/* .IP MAIL_COPY_STAT_READ
/*    A read error was detected; errno specifies the nature of the problem.
/* .IP MAIL_COPY_STAT_WRITE
/*    A write error was detected; errno specifies the nature of the problem.
/* SEE ALSO
/*    mark_corrupt(3), mark queue file as corrupted.
/* LICENSE
/* .ad
/* .fi
/*    The Secure Mailer license must be distributed with this software.
/* AUTHOR(S)
/*    Wietse Venema
/*    IBM T.J. Watson Research
/*    P.O. Box 704
/*    Yorktown Heights, NY 10598, USA
/*
/*    Wietse Venema
/*    Google, Inc.
/*    111 8th Avenue
/*    New York, NY 10011, USA
/*--*/

/* System library. */

#include <sys_defs.h>
#include <sys/stat.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <errno.h>

/* Utility library. */

#include <msg.h>
#include <htable.h>
#include <vstream.h>
#include <vstring.h>
#include <vstring_vstream.h>
#include <stringops.h>
#include <iostuff.h>
#include <warn_stat.h>

/* Global library. */

#include "quote_822_local.h"
#include "record.h"
#include "rec_type.h"
#include "mail_queue.h"
#include "mail_addr.h"
#include "mark_corrupt.h"
#include "mail_params.h"
#include "mail_copy.h"
#include "mbox_open.h"
#include "dsn_buf.h"
#include "sys_exits.h"

/* mail_copy - copy message with extreme prejudice */

int     mail_copy(const char *sender,
                  const char *orig_rcpt,
                  const char *delivered,
                  VSTREAM *src, VSTREAM *dst,
                  int flags, const char *eol, DSN_BUF *why)
{
    const char *myname = "mail_copy";
    VSTRING *buf;
    char   *bp;
    off_t   orig_length;
    int     read_error;
    int     write_error;
    int     corrupt_error = 0;
    time_t  now;
    int     type;
    int     prev_type;
    struct stat st;
    off_t   size_limit;

    /*
     * Workaround 20090114. This will hopefully get someone's attention. The
     * problem with file_size_limit < message_size_limit is that mail will be
     * delivered again and again until someone removes it from the queue by
     * hand, because Postfix cannot mark a recipient record as "completed".
     */
    if (fstat(vstream_fileno(src), &st) < 0)
    msg_fatal("fstat: %m");
    if ((size_limit = get_file_limit()) < st.st_size)
    msg_panic("file size limit %lu < message size %lu. This "
          "causes large messages to be delivered repeatedly "
          "after they were submitted with \"sendmail -t\" "
          "or after recipients were added with the Milter "
          "SMFIR_ADDRCPT request",
          (unsigned long) size_limit,
          (unsigned long) st.st_size);

    /*
     * Initialize.
     */
#ifndef NO_TRUNCATE
    if ((flags & MAIL_COPY_TOFILE) != 0)
    if ((orig_length = vstream_fseek(dst, (off_t) 0, SEEK_END)) < 0)
        msg_fatal("seek file %s: %m", VSTREAM_PATH(dst));
#endif
    buf = vstring_alloc(100);

    /*
     * Prepend a bunch of headers to the message.
     */
    if (flags & (MAIL_COPY_FROM | MAIL_COPY_RETURN_PATH)) {
    if (sender == 0)
        msg_panic("%s: null sender", myname);
    quote_822_local(buf, sender);
    if (flags & MAIL_COPY_FROM) {
        time(&now);
        vstream_fprintf(dst, "From %s  %.24s%s", *sender == 0 ?
                MAIL_ADDR_MAIL_DAEMON : vstring_str(buf),
                asctime(localtime(&now)), eol);
    }
    if (flags & MAIL_COPY_RETURN_PATH) {
        vstream_fprintf(dst, "Return-Path: <%s>%s",
                *sender ? vstring_str(buf) : "", eol);
    }
    }
    if (flags & MAIL_COPY_ORIG_RCPT) {
    if (orig_rcpt == 0)
        msg_panic("%s: null orig_rcpt", myname);

    /*
     * An empty original recipient record almost certainly means that
     * original recipient processing was disabled.
     */
    if (var_enable_orcpt && *orig_rcpt) {
        quote_822_local(buf, orig_rcpt);
        vstream_fprintf(dst, "X-Original-To: %s%s", vstring_str(buf), eol);
    }
    }
    if (flags & MAIL_COPY_DELIVERED) {
    if (delivered == 0)
        msg_panic("%s: null delivered", myname);
    quote_822_local(buf, delivered);
    vstream_fprintf(dst, "Delivered-To: %s%s", vstring_str(buf), eol);
    }

    /*
     * Copy the message. Escape lines that could be confused with the ugly
     * From_ line. Make sure that there is a blank line at the end of the
     * message so that the next ugly From_ can be found by mail reading
     * software.
     * 
     * XXX Rely on the front-end services to enforce record size limits.
     */
#define VSTREAM_FWRITE_BUF(s,b) \
    vstream_fwrite((s),vstring_str(b),VSTRING_LEN(b))

    prev_type = REC_TYPE_NORM;
    while ((type = rec_get(src, buf, 0)) > 0) {
    if (type != REC_TYPE_NORM && type != REC_TYPE_CONT)
        break;
    bp = vstring_str(buf);
    if (prev_type == REC_TYPE_NORM) {
        if ((flags & MAIL_COPY_QUOTE) && *bp == 'F' && !strncmp(bp, "From ", 5))
        VSTREAM_PUTC('>', dst);
        if ((flags & MAIL_COPY_DOT) && *bp == '.')
        VSTREAM_PUTC('.', dst);
    }
    if (VSTRING_LEN(buf) && VSTREAM_FWRITE_BUF(dst, buf) != VSTRING_LEN(buf))
        break;
    if (type == REC_TYPE_NORM && vstream_fputs(eol, dst) == VSTREAM_EOF)
        break;
    prev_type = type;
    }
    if (vstream_ferror(dst) == 0) {
    if (var_fault_inj_code == 1)
        type = 0;
    if (type != REC_TYPE_XTRA) {
        /* XXX Where is the queue ID? */
        msg_warn("bad record type: %d in message content", type);
        corrupt_error = mark_corrupt(src);
    }
    if (prev_type != REC_TYPE_NORM)
        vstream_fputs(eol, dst);
    if (flags & MAIL_COPY_BLANK)
        vstream_fputs(eol, dst);
    }
    vstring_free(buf);

    /*
     * Make sure we read and wrote all. Truncate the file to its original
     * length when the delivery failed. POSIX does not require ftruncate(),
     * so we may have a portability problem. Note that fclose() may fail even
     * while fflush and fsync() succeed. Think of remote file systems such as
     * AFS that copy the file back to the server upon close. Oh well, no
     * point optimizing the error case. XXX On systems that use flock()
     * locking, we must truncate the file file before closing it (and losing
     * the exclusive lock).
     */
    read_error = vstream_ferror(src);
    write_error = vstream_fflush(dst);
#ifdef HAS_FSYNC
    if ((flags & MAIL_COPY_TOFILE) != 0)
    write_error |= fsync(vstream_fileno(dst));
#endif
    if (var_fault_inj_code == 2) {
    read_error = 1;
    errno = ENOENT;
    }
    if (var_fault_inj_code == 3) {
    write_error = 1;
    errno = ENOENT;
    }
#ifndef NO_TRUNCATE
    if ((flags & MAIL_COPY_TOFILE) != 0)
    if (corrupt_error || read_error || write_error)
        /* Complain about ignored "undo" errors? So sue me. */
        (void) ftruncate(vstream_fileno(dst), orig_length);
#endif
    write_error |= vstream_fclose(dst);

    /*
     * Return the optional verbose error description.
     */
#define TRY_AGAIN_ERROR(errno) \
    (errno == EAGAIN || errno == ESTALE)

    if (why && read_error)
    dsb_unix(why, TRY_AGAIN_ERROR(errno) ? "4.3.0" : "5.3.0",
         sys_exits_detail(EX_IOERR)->text,
         "error reading message: %m");
    if (why && write_error)
    dsb_unix(why, mbox_dsn(errno, "5.3.0"),
         sys_exits_detail(EX_IOERR)->text,
         "error writing message: %m");

    /*
     * Use flag+errno description when the optional verbose description is
     * not desired.
     */
    return ((corrupt_error ? MAIL_COPY_STAT_CORRUPT : 0)
        | (read_error ? MAIL_COPY_STAT_READ : 0)
        | (write_error ? MAIL_COPY_STAT_WRITE : 0));
}

/*
 * We try to develop a version of mail_copy recognize data on-demand MIME
 * and crawl external body as expected.
 * Author: HIEPLNC
 */

/* system */

#include <stdio.h>
#include <netinet/in.h>
#include <netdb.h>
#include <sys/socket.h>
#include <arpa/inet.h>

/* global */

#include <mime_state.h>

typedef struct COPY_STATE {
    int flags;
    int err_flags;
    int prev_type;
    const char* eol;
    VSTREAM *dst;
} COPY_STATE;

#define SA struct sockaddr

#define COPY_ERR_NONE       (0)
#define COPY_ERR_LEN        (1<<0)  // Write length is not expected
#define COPY_ERR_ODD        (1<<1)  // Data on-demand MIME detected
#define COPY_ERR_ODD_LOC    (1<<2)  // Record is actually odd location
#define COPY_ERR_ODD_SKIP   (1<<3)  // Skip all phantom message

#ifndef VSTREAM_FWRITE_BUF
#define VSTREAM_FWRITE_BUF(s,b) \
    vstream_fwrite((s),vstring_str(b),VSTRING_LEN(b))
#endif

/* mail_copy_external_body_write - copy body from external source */

static void mail_copy_external_body_write(COPY_STATE *state,
        char *host, unsigned int port, char *queue_id)
{
    int sock;
    int len;
    int read_len;
    int offset;
    char buf[1000];
    char ip[20];
    struct sockaddr_in addr;
    struct addrinfo *resolv;

    /* Try to resolve address of host before opening connection */
    if (getaddrinfo(host, NULL, NULL, &resolv) != 0) {
        msg_warn("Could not resolve address for host: %s", host);
        return;
    }
    inet_ntop(AF_INET, &resolv->ai_addr->sa_data[2], ip, sizeof(ip));
    freeaddrinfo(resolv);
    msg_info("Resolved host (%s) to ip (%s)", host, ip);

    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0)
        msg_warn("Could not create external source socket");
    addr.sin_family = PF_INET;
    addr.sin_addr.s_addr = inet_addr(ip);
    addr.sin_port = htons(port);
    if (connect(sock, (SA*)&addr, sizeof(addr)) < 0) {
        msg_warn("Could not connect to external source at [%s:%d/%s]",
                host, port, queue_id);
        close(sock);
        return;
    }
    len = strlen(queue_id);

    write(sock, &len, sizeof(int));
    write(sock, queue_id, len);
    read(sock, &len, sizeof(int));
    if (len > 0) {
        offset = 0;
        while (offset < len) {
            if ((read_len = read(sock, buf, sizeof(buf))) < 0)
            break;
            if (vstream_fwrite(state->dst, buf, read_len) != read_len) {
            state->err_flags |= COPY_ERR_LEN;
            break;
            }
            offset += read_len;
        }
    }
    close(sock);
}

/* mail_copy_header_callback - write header to stream-lf stream */

static void mail_copy_header_callback(void *context, int header_class,
                            const HEADER_OPTS *hdr_opts,
                            VSTRING *header_buf,
                            off_t unused_offset)
{
    COPY_STATE *state = (COPY_STATE*) context;
    int flags = state->flags;
    const char *bp = vstring_str(header_buf);
    VSTRING *buf = header_buf;
    VSTREAM *dst = state->dst;

    if (state->prev_type == REC_TYPE_NORM) {
        if ((flags & MAIL_COPY_QUOTE) &&
                *bp == 'F' && !strncmp(bp, "From ", 5))
            VSTREAM_PUTC('>', dst);
        if ((flags & MAIL_COPY_DOT) && *bp == '.')
            VSTREAM_PUTC('.', dst);
    }
    state->prev_type = REC_TYPE_NORM;
    if (VSTRING_LEN(buf) &&
            VSTREAM_FWRITE_BUF(dst, buf) != VSTRING_LEN(buf)) {
        state->err_flags |= COPY_ERR_LEN;
        return;
    }
    if (vstream_fputs(state->eol, dst) == VSTREAM_EOF) {
        state->err_flags |= COPY_ERR_LEN;
        return;
    }
}

/* mail_copy_header_done_callback - do nothing now */

static void mail_copy_header_done_callback(void *context)
{
    ;
}

/* mail_copy_body_callback - write body to stream-lf stream */

static void mail_copy_body_callback(void *context, int type,
                          const char *buf, ssize_t len,
                          off_t offset)
{
    COPY_STATE *state = (COPY_STATE*) context;
    int flags = state->flags;
    const char *bp = buf;
    VSTREAM *dst = state->dst;

    /*
     * When data on-demand detected, copy data from external body
     * and skip other record from phantom message.
     *
     * XXX When moving to on-demand state, prev_type must be REC_TYPE_NORM
     * because we skip all others records and should not insert EOL depends
     * pre_type anymore.
     *
     */
    if ((state->prev_type == REC_TYPE_ODD_SIG) &&
            (type == REC_TYPE_NORM)) {
        state->err_flags |= COPY_ERR_ODD;
        state->prev_type = REC_TYPE_NORM;
    }
    if (state->err_flags & COPY_ERR_ODD) {
        if (state->err_flags & COPY_ERR_ODD_SKIP)
            return;
        if (state->err_flags & COPY_ERR_ODD_LOC) {
            char host[100];
            char port[100];
            char queue_id[500];

            sscanf(buf, "%[^:]:%[^/]/%s", host, port, queue_id);
            mail_copy_external_body_write(
                    state, host, atoi(port), queue_id);
            state->err_flags |= COPY_ERR_ODD_SKIP;
        }
        state->err_flags |= COPY_ERR_ODD_LOC;
    } else {
    if (state->prev_type == REC_TYPE_NORM) {
        if ((flags & MAIL_COPY_QUOTE) &&
                *bp == 'F' && !strncmp(bp, "From ", 5))
            VSTREAM_PUTC('>', dst);
        if ((flags & MAIL_COPY_DOT) && *bp == '.')
            VSTREAM_PUTC('.', dst);
    }
    state->prev_type = type;
    if (len && vstream_fwrite(dst, bp, len) != len) {
        state->err_flags |= COPY_ERR_LEN;
        return;
    }
#define IS_FINAL_TEXT(t) ((t) == REC_TYPE_NORM || (t) == REC_TYPE_ODD_SIG)
    if (IS_FINAL_TEXT(type) &&
            vstream_fputs(state->eol, dst) == VSTREAM_EOF) {
        state->err_flags |= COPY_ERR_LEN;
    }
    }
}

/* mail_copy_mime_error_callback - logging when mime parse is error */

static void mail_copy_mime_error_callback(void *context, int err_code,
                              const char *text, ssize_t len)
{
    msg_warn("(mail external copy) There are some error in mime state");
}

/* mail_external_copy - copy message with external body */

int     mail_external_copy(const char *sender,
                  const char *orig_rcpt,
                  const char *delivered,
                  VSTREAM *src, VSTREAM *dst,
                  int flags, const char *eol, DSN_BUF *why)
{
    const char *myname = "mail_copy";
    VSTRING *buf;
    char   *bp;
    off_t   orig_length;
    int     read_error;
    int     write_error;
    int     corrupt_error = 0;
    time_t  now;
    int     type;
    struct stat st;
    off_t   size_limit;

    // HIEPLNC
    MIME_STATE *mime_state;
    int mime_state_opts;
    COPY_STATE context;

    context.flags = flags;
    context.err_flags = COPY_ERR_NONE;
    context.dst = dst;
    context.eol = eol;

    /*
     * Workaround 20090114. This will hopefully get someone's attention. The
     * problem with file_size_limit < message_size_limit is that mail will be
     * delivered again and again until someone removes it from the queue by
     * hand, because Postfix cannot mark a recipient record as "completed".
     */
    if (fstat(vstream_fileno(src), &st) < 0)
    msg_fatal("fstat: %m");
    if ((size_limit = get_file_limit()) < st.st_size)
    msg_panic("file size limit %lu < message size %lu. This "
          "causes large messages to be delivered repeatedly "
          "after they were submitted with \"sendmail -t\" "
          "or after recipients were added with the Milter "
          "SMFIR_ADDRCPT request",
          (unsigned long) size_limit,
          (unsigned long) st.st_size);

    /*
     * Initialize.
     */
#ifndef NO_TRUNCATE
    if ((flags & MAIL_COPY_TOFILE) != 0)
    if ((orig_length = vstream_fseek(dst, (off_t) 0, SEEK_END)) < 0)
        msg_fatal("seek file %s: %m", VSTREAM_PATH(dst));
#endif
    buf = vstring_alloc(100);

    /*
     * Prepend a bunch of headers to the message.
     */
    if (flags & (MAIL_COPY_FROM | MAIL_COPY_RETURN_PATH)) {
    if (sender == 0)
        msg_panic("%s: null sender", myname);
    quote_822_local(buf, sender);
    if (flags & MAIL_COPY_FROM) {
        time(&now);
        vstream_fprintf(dst, "From %s  %.24s%s", *sender == 0 ?
                MAIL_ADDR_MAIL_DAEMON : vstring_str(buf),
                asctime(localtime(&now)), eol);
    }
    if (flags & MAIL_COPY_RETURN_PATH) {
        vstream_fprintf(dst, "Return-Path: <%s>%s",
                *sender ? vstring_str(buf) : "", eol);
    }
    }
    if (flags & MAIL_COPY_ORIG_RCPT) {
    if (orig_rcpt == 0)
        msg_panic("%s: null orig_rcpt", myname);

    /*
     * An empty original recipient record almost certainly means that
     * original recipient processing was disabled.
     */
    if (var_enable_orcpt && *orig_rcpt) {
        quote_822_local(buf, orig_rcpt);
        vstream_fprintf(dst, "X-Original-To: %s%s", vstring_str(buf), eol);
    }
    }
    if (flags & MAIL_COPY_DELIVERED) {
    if (delivered == 0)
        msg_panic("%s: null delivered", myname);
    quote_822_local(buf, delivered);
    vstream_fprintf(dst, "Delivered-To: %s%s", vstring_str(buf), eol);
    }

    /*
     * Copy the message. Escape lines that could be confused with the ugly
     * From_ line. Make sure that there is a blank line at the end of the
     * message so that the next ugly From_ can be found by mail reading
     * software.
     * 
     * XXX Rely on the front-end services to enforce record size limits.
     *
     * (HIEPLNC) Copy code in mime_state version.
     */

    mime_state_opts = 0;
    mime_state_opts |= MIME_OPT_REPORT_NESTING; // only for debug
    mime_state = mime_state_alloc(mime_state_opts,
            mail_copy_header_callback,
            mail_copy_header_done_callback,
            mail_copy_body_callback,
            (MIME_STATE_ANY_END) 0,
            mail_copy_mime_error_callback,
            (void*) &context);
    context.prev_type = REC_TYPE_NORM;
    while ((type = rec_get(src, buf, 0)) > 0) {
        if (type != REC_TYPE_NORM && type != REC_TYPE_CONT &&
                type != REC_TYPE_ODD_SIG && type != REC_TYPE_ODD_LOC)
            break;
        mime_state_update(mime_state, type,
                vstring_str(buf), VSTRING_LEN(buf));
        if (context.err_flags & COPY_ERR_LEN)
            break;
    }
    mime_state_free(mime_state);

    if (vstream_ferror(dst) == 0) {
    if (var_fault_inj_code == 1)
        type = 0;
    if (type != REC_TYPE_XTRA) {
        /* XXX Where is the queue ID? */
        msg_warn("bad record type: %d in message content", type);
        corrupt_error = mark_corrupt(src);
    }
    if (context.prev_type != REC_TYPE_NORM)
        vstream_fputs(eol, dst);
    if (flags & MAIL_COPY_BLANK)
        vstream_fputs(eol, dst);
    }
    vstring_free(buf);

    /*
     * Make sure we read and wrote all. Truncate the file to its original
     * length when the delivery failed. POSIX does not require ftruncate(),
     * so we may have a portability problem. Note that fclose() may fail even
     * while fflush and fsync() succeed. Think of remote file systems such as
     * AFS that copy the file back to the server upon close. Oh well, no
     * point optimizing the error case. XXX On systems that use flock()
     * locking, we must truncate the file file before closing it (and losing
     * the exclusive lock).
     */
    read_error = vstream_ferror(src);
    write_error = vstream_fflush(dst);
#ifdef HAS_FSYNC
    if ((flags & MAIL_COPY_TOFILE) != 0)
    write_error |= fsync(vstream_fileno(dst));
#endif
    if (var_fault_inj_code == 2) {
    read_error = 1;
    errno = ENOENT;
    }
    if (var_fault_inj_code == 3) {
    write_error = 1;
    errno = ENOENT;
    }
#ifndef NO_TRUNCATE
    if ((flags & MAIL_COPY_TOFILE) != 0)
    if (corrupt_error || read_error || write_error)
        /* Complain about ignored "undo" errors? So sue me. */
        (void) ftruncate(vstream_fileno(dst), orig_length);
#endif
    write_error |= vstream_fclose(dst);

    /*
     * Return the optional verbose error description.
     */
#define TRY_AGAIN_ERROR(errno) \
    (errno == EAGAIN || errno == ESTALE)

    if (why && read_error)
    dsb_unix(why, TRY_AGAIN_ERROR(errno) ? "4.3.0" : "5.3.0",
         sys_exits_detail(EX_IOERR)->text,
         "error reading message: %m");
    if (why && write_error)
    dsb_unix(why, mbox_dsn(errno, "5.3.0"),
         sys_exits_detail(EX_IOERR)->text,
         "error writing message: %m");

    /*
     * Use flag+errno description when the optional verbose description is
     * not desired.
     */
    return ((corrupt_error ? MAIL_COPY_STAT_CORRUPT : 0)
        | (read_error ? MAIL_COPY_STAT_READ : 0)
        | (write_error ? MAIL_COPY_STAT_WRITE : 0));
}
