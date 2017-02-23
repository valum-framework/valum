#ifndef __VSGI_FASTCGI_OUTPUT_STREAM_H__
#define __VSGI_FASTCGI_OUTPUT_STREAM_H__

#include <gio/gio.h>
#include <gio/gunixoutputstream.h>

#include <fcgiapp.h>

G_BEGIN_DECLS

#define VSGI_FASTCGI_TYPE_OUTPUT_STREAM (vsgi_fastcgi_output_stream_get_type ())
G_DECLARE_FINAL_TYPE (VSGIFastCGIOutputStream, vsgi_fastcgi_output_stream, VSGI_FASTCGI, OUTPUT_STREAM, GUnixOutputStream)

VSGIFastCGIOutputStream * vsgi_fastcgi_output_stream_new (gint fd, FCGX_Stream *out, FCGX_Stream *err);

G_END_DECLS

#endif
