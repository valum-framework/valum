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

#include <libsoup/soup.h>
#include <vsgi.h>
#include <valum.h>

static gboolean
home_handler (VSGIRequest        *req,
              VSGIResponse       *res,
              ValumNextCallback   next,
              void               *next_user_data,
              ValumContext       *context,
              void               *user_data,
              GError            **error)
{
	soup_message_headers_set_content_type (vsgi_response_get_headers (res), "text/plain", NULL);
	return vsgi_response_expand_utf8 (res, "Hello world!", NULL, error);
}

int
main (int argc, char** argv)
{
	ValumRouter *app;
	VSGIServer *server;
	gint ret;

	app = valum_router_new ();

	valum_router_get (app, "/", home_handler, NULL, NULL, NULL);

	server = vsgi_server_new ("http", "handler", app, NULL);

	ret = vsgi_server_run (server, argv, argc);

	g_object_unref (server);

	return ret;
}
