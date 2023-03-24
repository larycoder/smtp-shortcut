/**
 * Description:
 * Dump whatever data inside a specific queue through connection.
 */

#include <stdio.h>
#include <stdlib.h>

#include <string.h>

#include <pthread.h>
#include <signal.h>
#include <sys/stat.h>
#include <unistd.h>

#include <errno.h>
#include <fcntl.h>

#include "data-dump.h"

static int run_flag = 1; // keep parent running loop

#define IS_VALID_FD(fd) (fcntl((fd), F_GETFD) != -1 || errno != EBADF)

/* IS_FILE - check valid file */

static int IS_FILE(char* file)
{
    struct stat status;
    if (stat(file, &status) != 0)
        return 0;
    return S_ISREG(status.st_mode);
}

/* dump_alloc - allocate location and zero value to state */

DUMP_STATE* dump_alloc()
{
    DUMP_STATE* state = (DUMP_STATE*)malloc(sizeof(DUMP_STATE));
    state->err_flags = DUMP_ERR_NON;
    state->queue = 0;
    state->queue_id = 0;
    state->listen_fd = -1;
    state->file_fd = -1;
    state->file_size = 0;
    state->client_fd = -1;
    state->client_addr; // Don't initialize this
    return state;
}

/* dump_init - initialize file and socket */

void dump_init(DUMP_STATE* state, char* queue_path)
{
    int sock;
    int str_len;
    int sockopt = 1;
    struct stat fstat;
    struct sockaddr_in addr;

    /*
     * We open listen socket but not yet listen now.
     */
    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        state->err_flags |= DUMP_ERR_SOCK;
#ifdef DEBUG
        printf("Could not create socket...\n");
#endif
        return;
    }
    setsockopt(sock, SOL_SOCKET, SO_REUSEADDR,
        &sockopt, sizeof(sockopt));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons(PORT);
    if (bind(sock, (SA*)&addr, sizeof(addr)) != 0) {
        state->err_flags |= DUMP_ERR_SOCK;
#ifdef DEBUG
        printf("Could not bind socket with err \"%s\"\n",
            strerror(errno));
#endif
        return;
    }
    if (listen(sock, LISTEN_MAX) != 0) {
        state->err_flags |= DUMP_ERR_SOCK;
#ifdef DEBUG
        printf("Could not listen socket..\n");
#endif
        return;
    }
    state->listen_fd = sock;

    /*
     * Keep queue path as the state owner.
     */
    str_len = strlen(queue_path);
    if (state->queue != 0)
        free(state->queue);
    state->queue = (char*)malloc(str_len + 1);
    memset(state->queue, 0, str_len + 1);
    memcpy(state->queue, queue_path, str_len);
    if (stat(state->queue, &fstat) != 0 || (fstat.st_mode & S_IFDIR) == 0) {
        state->err_flags |= DUMP_ERR_QUEUE_NOT_EXIST;
        return;
    }
}

/* dump_free - free up state */

void dump_free(DUMP_STATE* state)
{
    if (state->queue)
        free(state->queue);
    if (state->queue_id)
        free(state->queue_id);
    if (IS_VALID_FD(state->listen_fd))
        close(state->listen_fd);
    if (IS_VALID_FD(state->client_fd))
        close(state->client_fd);
    free(state);
}

/* dump_path_get - get final path to queue file */

static int dump_path_get(DUMP_STATE* state, char* queue_file)
{
    int queue_len;

    memset(queue_file, 0, STR_MAX);
    strcat(queue_file, state->queue);
    queue_len = strlen(state->queue);
    if (*(state->queue + queue_len - 1) != '/')
        strcat(queue_file, "/");
    strcat(queue_file, state->queue_id);
    if (!IS_FILE(queue_file)) {
        state->err_flags |= DUMP_ERR_FILE_NOT_EXIST;
    }
    return state->err_flags;
}

/* dump_file_open - open stream to queue file */

int dump_file_open(DUMP_STATE* state)
{
    struct stat file_status;
    char queue_file[STR_MAX];
    FILE* file_stream;

    if (dump_path_get(state, queue_file) & DUMP_ERR_FILE_NOT_EXIST)
        return state->err_flags;
    state->file_fd = open(queue_file, O_RDONLY);
    if (!IS_VALID_FD(state->file_fd)) {
        state->err_flags |= DUMP_ERR_FILE_NOT_EXIST;
        return state->err_flags;
    }
    if (stat(queue_file, &file_status) != 0) {
        state->err_flags |= DUMP_ERR_FILE_NOT_EXIST;
        return state->err_flags;
    }
    state->file_size = file_status.st_size;
    return state->err_flags;
}

/* dump_file_del - delete queue file */

int dump_file_del(DUMP_STATE* state)
{
    char queue_file[STR_MAX];

    if (IS_VALID_FD(state->file_fd))
        close(state->file_fd);
    if (dump_path_get(state, queue_file) & DUMP_ERR_FILE_NOT_EXIST)
        return state->err_flags;
    if (remove(queue_file) != 0)
        state->err_flags |= DUMP_ERR_FILE_NOT_DEL;
    return state->err_flags;
}

/* dump_proto_talk - send file to client */

void dump_proto_talk(DUMP_STATE* state)
{
#ifdef DEBUG
    printf("Start simple protocol session...\n");
#endif
    int offset;
    int buf_len;
    int queue_id_len;
    char queue_id[STR_MAX];
    char data_buf[STR_MAX];

    read(state->client_fd, &queue_id_len, sizeof(int));
    read(state->client_fd, queue_id, queue_id_len);
    state->queue_id = (char*)malloc(queue_id_len + 1);
    memset(state->queue_id, 0, queue_id_len + 1);
    memcpy(state->queue_id, queue_id, queue_id_len);
#ifdef DEBUG
    printf("Get request with length %d of queue_id %s\n",
        queue_id_len, state->queue_id);
#endif
    if (dump_file_open(state) & DUMP_ERR_FILE_NOT_EXIST) {
        state->file_size = -1;
        write(state->client_fd, &state->file_size, sizeof(int));
    } else {
        offset = 0;
        memset(data_buf, 0, STR_MAX);

        write(state->client_fd, &state->file_size, sizeof(int));
        while (offset < state->file_size) {
            buf_len = read(state->file_fd, data_buf, STR_MAX);
            write(state->client_fd, data_buf, buf_len);
            offset += buf_len;
        }
#if 0
        if (offset > 0)
            dump_file_del(state);
#endif
    }
#ifdef DEBUG
    printf("End simple protocol session...\n");
#endif
}

/* segm_handle - stop server */

static void segm_handle(int unused)
{
#ifdef DEBUG
    printf("Exited with segmentation fault...\n");
#endif
    exit(1);
}

/* client_simulate - allow server to be passed accept */
static void* client_simulate(void* vargp)
{
    int sock;
    int ret;
    struct sockaddr_in addr;

    sock = socket(AF_INET, SOCK_STREAM, 0);
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = inet_addr("127.0.0.1");
    addr.sin_port = htons(PORT);
    ret = connect(sock, (SA*)&addr, sizeof(addr));
    if (IS_VALID_FD(sock))
        close(sock);
    return NULL;
}

/* stop_handle - stop server */

static void stop_handle(int unused)
{
#ifdef DEBUG
    printf("Server is shutdown...\n");
#endif
    pthread_t thread;

    run_flag = 0;
    pthread_create(&thread, NULL, client_simulate, NULL);
}

/* main - test function */

int main(int argc, char* argv[])
{
    signal(SIGSEGV, segm_handle);
    signal(SIGINT, stop_handle);

    unsigned int client_len;

    /*
     * Fast check, we assume argument of main is path to data queue.
     */
    DUMP_STATE* state = dump_alloc();
    dump_init(state, argv[1]);
    if (state->err_flags & DUMP_ERR_SOCK) {
        printf("Could not initialize socket...\n");
        dump_free(state);
        exit(1);
    } else if (state->err_flags & DUMP_ERR_QUEUE_NOT_EXIST) {
        printf("Could not initialize queue...\n");
        dump_free(state);
        exit(1);
    }

    while (1) {
        state->client_fd = accept(
            state->listen_fd, (SA*)&state->client_addr, &client_len);
        if (!run_flag) {
            break;
        }
        if (state->client_fd < 0)
            continue;
        if (fork() == 0) {
            // This is children
            close(state->listen_fd);
            dump_proto_talk(state);
            break;
        } else {
            // This is parent
            close(state->client_fd);
            client_len = 0;
        }
    }
    dump_free(state);
    return 0;
}
