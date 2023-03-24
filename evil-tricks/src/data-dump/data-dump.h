#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#define SA  struct sockaddr
#define LISTEN_MAX  5
#define STR_MAX     1000
#define PORT    8081
#define DEBUG

typedef struct DUMP_STATE {
    int err_flags;  // flag to report errors

    char* queue;     // path to data queue (local file-system only)
    char* queue_id;   // identify of data file
    int listen_fd;  // server main socket

    int file_fd;    // file data
    int file_size;  // file size

    int client_fd;  // client target
    struct sockaddr_in client_addr; // client address
} DUMP_STATE;

/* error flags */

#define DUMP_ERR_NON                (0)
#define DUMP_ERR_QUEUE_NOT_EXIST    (1<<0)
#define DUMP_ERR_FILE_NOT_EXIST     (1<<1)
#define DUMP_ERR_SOCK               (1<<2)
#define DUMP_ERR_FILE_NOT_DEL       (1<<3)

/* dump functions */

// Initialize state
DUMP_STATE* dump_alloc();
void dump_init(DUMP_STATE* state, char* queue_path);
void dump_free(DUMP_STATE* state);

// Auxiliary
int dump_file_open(DUMP_STATE* state);

// Protocol handler
void dump_proto_talk(DUMP_STATE* state);
