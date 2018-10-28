#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <amqp.h>
#include <amqp_tcp_socket.h>

#include "utils.h"

int main(int argc, char const *const *argv) {
    char const *hostname = "localhost";
    int port = 5672;
    int  status;
    const char *user = "test";
    const char *password = "test";
    char const *exchange = "amq.direct";
    char const *routingkey = "testkey";
    char const *messagebody;
    amqp_socket_t *socket = NULL;
    amqp_connection_state_t conn;
    amqp_rpc_reply_t reply;
    if (argc < 2) {
	printf("Usage: amqp_sendstring host port exchange routingkey messagebody\n");
	return -1;
    }

    //hostname = argv[1];
    //port = atoi(argv[2]);
    //exchange = argv[3];
    //routingkey = argv[4];
    //messagebody = argv[5];
    messagebody = argv[1];

    conn = amqp_new_connection();

    socket = amqp_tcp_socket_new(conn);
    if (!socket) {
        printf("creating TCP socket");
    }

    status = amqp_socket_open(socket, hostname, port);
    if (status) {
	    printf("opening TCP socket failed\n");
	    return -1;
    }

    reply = amqp_login(conn, "/", 0, 131072, 0, AMQP_SASL_METHOD_PLAIN, user, password);
    if (reply.reply_type == AMQP_RESPONSE_SERVER_EXCEPTION)
    {
        printf("amqp login error\n");
        return 0;
    }

    amqp_channel_open(conn, 1);
    reply = amqp_get_rpc_reply(conn);
    if(reply.reply_type == AMQP_RESPONSE_SERVER_EXCEPTION)
    {
        printf("open channel error\n");
        return -1;
    }
    
    amqp_basic_properties_t props;
    props._flags = AMQP_BASIC_CONTENT_TYPE_FLAG | AMQP_BASIC_DELIVERY_MODE_FLAG;
    props.content_type = amqp_cstring_bytes("text/plain");
    props.delivery_mode = 2; /* persistent delivery mode */
    amqp_basic_publish(conn, 1, amqp_cstring_bytes(exchange),
			    amqp_cstring_bytes(routingkey), 0, 0,
			    &props, amqp_cstring_bytes(messagebody));


    amqp_channel_close(conn, 1, AMQP_REPLY_SUCCESS);;
    amqp_connection_close(conn, AMQP_REPLY_SUCCESS);;
    amqp_destroy_connection(conn);
    return 0;
}

