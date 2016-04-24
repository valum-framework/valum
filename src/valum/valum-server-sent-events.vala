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

using GLib;
using Valum.ContentNegotiation;
using VSGI;

/**
 * Middleware and utilities to produce server-sent events.
 *
 * @since 0.3
 */
[CCode (gir_namespace = "Valum.ServerSentEvents", gir_version = "0.3")]
namespace Valum.ServerSentEvents {

	/**
	 * Send an message over the body stream.
	 *
	 * All string data must be encoded using UTF-8 and multi-line data are
	 * handled properly by writing multiple 'data:' fields.
	 *
	 * @since 0.3
	 *
	 * @param event event name, or 'null' to omit the field
	 * @param data  event data
	 * @param id    event identifier, or 'null' to omit the field
	 * @param retry retry, or 'null' to omit the field
	 *
	 * @throws Error errors are handled as warnings to avoid breaking the
	 *               `text/event-stream` content
	 */
	public delegate void SendEventCallback (string?   event,
	                                        string    data,
	                                        string?   id    = null,
	                                        TimeSpan? retry = null) throws Error;

	/**
	 * Create a context for sending SSE messages.
	 *
	 * It replaces the {@link VSGI.Response} by a {@link Valum.ServerSentEvents.SendEventCallback}.
	 *
	 * @since 0.3
	 *
	 * @param request    request this is responding to
	 * @param send_event send a SSE message
	 * @param context    routing context
	 *
	 * @throws GLib.Error thrown errors are suppressed with {@link GLib.warning}
	 */
	public delegate void EventStreamCallback (Request                 request,
	                                          owned SendEventCallback send_event,
	                                          Context                 context) throws Error;

	/**
	 * Middleware that create a context for sending Server-Sent Events.
	 *
	 * The {@link VSGI.Response} cannot be manipulated directly, but through a
	 * {@link Valum.ServerSentEvents.SendEventCallback} callback instead.
	 *
	 * The stream is explicitly flushed the ensure that the user agent receives
	 * the message.
	 *
	 * Messages are send directly with the {@link Soup.Encoding.EOF} encoding
	 * as recommended by the W3C.
	 *
	 * The middleware automatically send a keep-alive every 15 seconds to ensure
	 * that unaware clients keep the connection opened.
	 *
	 * @since 0.3
	 *
	 * @param context context for sending events
	 */
	public HandlerCallback stream_events (owned EventStreamCallback context) {
		return accept ("text/event-stream", (req, res, next, _context) => {
			res.headers.set_encoding (Soup.Encoding.EOF);

			// write headers right away
			size_t bytes_size;
			res.write_head (out bytes_size);

			// flush headers right away
			req.connection.output_stream.flush ();

			// don't hang the user agent on a 'HEAD' request
			if (req.method == Request.HEAD)
				return res.end ();

			Timeout.add_seconds (15, () => {
				try {
					return res.ref_count > 1 && res.append_utf8 (":\n");
				} catch (Error err) {
					critical ("%s (%s, %d)", err.message, err.domain.to_string (), err.code);
					return false;
				}
			});

			context (req, (event, data, id, retry) => {
				var message = new StringBuilder ();

				if (event != null)
					message.append_printf ("event: %s\n", event);

				if (id != null)
					message.append_printf ("id: %s\n", id);

				if (retry != null)
					message.append_printf ("retry: %" + int64.FORMAT + "\n", retry / 1000);

				// split multi-line data in multiple 'data:' fields
				foreach (var line in data.split ("\n"))
					message.append_printf ("data: %s\n", line);

				// final newline that concludes the message
				message.append_c ('\n');

				res.append_utf8 (message.str);
			}, _context);

			return true;
		});
	}
}

