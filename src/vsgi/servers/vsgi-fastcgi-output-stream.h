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
G_DECLARE_FINAL_TYPE (VSGIFastCGIOutputStream, vsgi_fastcgi_output_stream, VSGI_FASTCGI, OUTPUT_STREAM, GUnixOutputStream)

VSGIFastCGIOutputStream * vsgi_fastcgi_output_stream_new (gint fd, FCGX_Stream *out, FCGX_Stream *err);

G_END_DECLS

#endif
