#include <valum-0.3.h>

int
app (VSGIRequest *request, VSGIResponse *response, GError **error, void* user_data)
{
    soup_message_headers_set_content_type (vsgi_response_get_headers (response),
                                           "text/plain",
                                           NULL);

    return vsgi_response_expand_utf8 (response,
                                      "Hello world!",
                                      NULL,
                                      error);
}

int
main (int argc, char** argv)
{
    VSGIServer *server = vsgi_server_new_with_application ("http",
                                                           app,
                                                           NULL,
                                                           NULL,
                                                           NULL);

    return vsgi_server_run (server, argv, argc);
}
