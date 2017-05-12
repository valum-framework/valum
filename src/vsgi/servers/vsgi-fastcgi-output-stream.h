/*
 * This file is part of Valum.
 *
 * Valum is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * Valum is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Valum.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef __VSGI_FASTCGI_OUTPUT_STREAM_H__
#define __VSGI_FASTCGI_OUTPUT_STREAM_H__

#include <gio/gio.h>
#include <gio/gunixoutputstream.h>

#include <fcgiapp.h>

G_BEGIN_DECLS

#define VSGI_FASTCGI_TYPE_OUTPUT_STREAM (vsgi_fastcgi_output_stream_get_type ())

GType vsgi_fastcgi_input_stream_get_type (void);

typedef struct _VSGIFastCGIOutputStream VSGIFastCGIOutputStream;

typedef struct {
    GUnixOutputStreamClass parent_class;
} VSGIFastCGIOutputStreamClass;

#define VSGI_FASTCGI_OUTPUT_STREAM(ptr) G_TYPE_CHECK_INSTANCE_CAST (ptr, vsgi_fastcgi_output_stream_get_type (), VSGIFastCGIOutputStream)

#define VSGI_FASTCGI_IS_OUTPUT_STREAM(ptr) G_TYPE_CHECK_INSTANCE_TYPE (ptr, vsgi_fastcgi_output_stream_get_type ())

VSGIFastCGIOutputStream * vsgi_fastcgi_output_stream_new (gint fd, FCGX_Stream *out, FCGX_Stream *err);

G_END_DECLS

#endif
