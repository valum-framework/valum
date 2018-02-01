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

namespace Valum {

#if SOUP_2_50
	/**
	 * Perform a handshake and promote the {@link Request.connection} to
	 * communicate using the WebSocket protocol.
	 *
	 * If the client does not provide 'Connection: Upgrade' nor 'Upgrade: websocket',
	 * the control is passed to the next handler.
	 *
	 * @param protocols a list of supported protocols, or an empty array
	 *                  not to use any in particular
	 */
	[Version (since = "0.4")]
	public HandlerCallback websocket (string[] protocols, ForwardCallback<Soup.WebsocketConnection> forward) {
		return (req, res, next, ctx) => {
			if (req.method != "GET") {
				throw new ClientError.METHOD_NOT_ALLOWED ("The WebSocket protocol require a 'GET' method to be initiated.");
			}

			var connection = req.headers.get_one ("Connection");
			if (connection == null ||
				Soup.header_parse_list (connection).find_custom ("Upgrade", (a, b) => Soup.str_case_equal (a, b) ? 0 : 1) == null) {
				return next ();
			}

			var upgrade = req.headers.get_one ("Upgrade");
			if (upgrade == null || !Soup.str_case_equal (upgrade, "websocket")) {
				return next ();
			}

			var ws_key = req.headers.get_one ("Sec-WebSocket-Key");
			var ws_protocol = req.headers.get_list ("Sec-WebSocket-Protocol");
			var ws_version = req.headers.get_one ("Sec-WebSocket-Version");

			if (ws_key == null) {
				throw new ClientError.BAD_REQUEST ("The 'Sec-WebSocket-Key' header is missing.");
			}

			if (ws_version == null) {
				throw new ClientError.BAD_REQUEST ("The 'Sec-WebSocket-Version' header is missing.");
			}

			var ws_accept_sha1 = new Checksum (ChecksumType.SHA1);

			ws_accept_sha1.update (ws_key.data, ws_key.length);
			ws_accept_sha1.update ("258EAFA5-E914-47DA-95CA-C5AB0DC85B11".data, 36);

			uint8 ws_accept_digest[20];
			size_t ws_accept_digest_len = 20;
			ws_accept_sha1.get_digest (ws_accept_digest, ref ws_accept_digest_len);

			var ws_accept = Base64.encode (ws_accept_digest);

			string? chosen_protocol = null;
			if (protocols.length == 0) {
				chosen_protocol = null;
			} else if (ws_protocol == null) {
				chosen_protocol = protocols[0];
			} else {
				// negotiate the protocol
				foreach (var protocol in protocols) {
					foreach (var client_protocol in Soup.header_parse_list (ws_protocol)) {
						if (Soup.str_case_equal (protocol, client_protocol)) {
							chosen_protocol = protocol;
							break;
						}
					}
					if (chosen_protocol != null) {
						break;
					}
				}
			}

			if (res.head_written) {
				throw new ServerError.INTERNAL_SERVER_ERROR ("The connection cannot be promoted to WebSocket: headers have already been written.");
			}

			res.status = Soup.Status.SWITCHING_PROTOCOLS;
			res.headers.replace ("Connection", "Upgrade");
			res.headers.replace ("Upgrade", "websocket");
			res.headers.replace ("Sec-WebSocket-Accept", ws_accept);

			// ensure that we have a fully written head
			res.write_head (null, null);

			res.wrote_headers.connect (() => {
				IOStream? con = req.steal_connection ();

				if (con == null) {
					warning ("Could not steal the connection to complete WebSocket connection upgrade.");
					return;
				}

				var ws_conn = new Soup.WebsocketConnection (con,
				                                            req.uri,
				                                            Soup.WebsocketConnectionType.SERVER,
				                                            req.headers.get_one ("Origin"),
				                                            chosen_protocol);

				try {
					forward (req, res, next, ctx, ws_conn);
				} catch (Error err) {
					critical ("%s (%s, %d)", err.message, err.domain.to_string (), err.code);
				}
			});

			return true;
		};
	}
#endif
}
