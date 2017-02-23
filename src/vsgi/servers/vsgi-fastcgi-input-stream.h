#ifndef __VSGI_FASTCGI_INPUT_STREAM_H__
#define __VSGI_FASTCGI_INPUT_STREAM_H__

#include <gio/gio.h>
#include <gio/gunixinputstream.h>

#include <fcgiapp.h>

G_BEGIN_DECLS

#define VSGI_FASTCGI_TYPE_INPUT_STREAM (vsgi_fastcgi_input_stream_get_type ())
G_DECLARE_FINAL_TYPE (VSGIFastCGIInputStream, vsgi_fastcgi_input_stream, VSGI_FASTCGI, INPUT_STREAM, GUnixInputStream)

VSGIFastCGIInputStream * vsgi_fastcgi_input_stream_new (gint fd, FCGX_Stream *in);

G_END_DECLS

#endif
