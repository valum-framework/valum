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
using VSGI;

namespace Valum {

	/**
	 * Dispatches incoming requests to the appropriate registered handler.
	 *
	 * @since 0.0.1
	 */
	public class Router : Object {

		/**
		 * Registered types used to extract {@link VSGI.Request} parameters.
         *
		 * @since 0.1
		 */
		public HashTable<string, Regex> types = new HashTable<string, Regex> (str_hash, str_equal);

		/**
		 * Registered routes by HTTP method.
		 */
		private Queue<Route> routes = new Queue<Route> ();

		/**
		 * Registered status handlers.
		 */
		private HashTable<uint , Queue<Route>> status_handlers = new HashTable<uint, Queue<Route>> (direct_hash, direct_equal);

		/**
		 * Stack of scopes.
		 *
		 * @since 0.1
		 */
		public Queue<string> scopes = new Queue<string> ();

		/**
		 * @since 0.0.1
		 */
		public Router () {
			// initialize default types
			this.types["int"]    = /\d+/;
			this.types["string"] = /\w+/;
			this.types["path"]   = /[\w\/]+/;
			this.types["any"]    = /.+/;
		}

		/**
		 * Mount a handling middleware on the routing queue.
		 *
		 * @since 0.3
		 */
		public Route use (owned HandlerCallback cb) {
			return matcher (null, () => { return true; }, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public new Route get (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.method (Request.GET, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route post (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.method (Request.POST, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route put (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.method (Request.PUT, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route delete (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.method (Request.DELETE, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route head (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.method (Request.HEAD, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route options (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.method (Request.OPTIONS, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route trace (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.method (Request.TRACE, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public new Route connect (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.method (Request.CONNECT, rule, (owned) cb);
		}

		/**
		 * [[http://tools.ietf.org/html/rfc5789]]
		 *
		 * @since 0.0.1
		 */
		public Route patch (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.method (Request.PATCH, rule, (owned) cb);
		}

		/**
		 * Bind a callback with a custom method.
		 *
		 * Useful if you need to support a non-standard HTTP method, otherwise you
		 * should use the predefined methods.
		 *
		 * @since 0.1
		 *
		 * @param method HTTP method
		 * @param rule   rule
		 * @param cb     callback used to process the pair of request and response.
		 */
		public Route method (string? method, string? rule, owned HandlerCallback cb) throws RegexError {
			return this.route (new Route.from_rule (this, method, rule, (owned) cb));
		}

		/**
		 * Bind a callback to all HTTP methods defined in {@link VSGI.Request.METHODS}.
		 *
		 * This function is deprecated in favour of {@link Valum.Router.use}.
		 *
		 * @since 0.1
		 */
		[Deprecated (replacement = "Valum.Router.use", since = "0.3")]
		public Route[] all (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.methods (Request.METHODS, rule, (owned) cb);
		}

		/**
		 * Bind a callback to a list of HTTP methods.
		 *
		 * @since 0.1
		 *
		 * @param methods methods to which the callback will be bound
		 * @param rule    rule
		 */
		public Route[] methods (string[] methods, string? rule, owned HandlerCallback cb) throws RegexError {
			var routes = new Route[methods.length];
			var i      = 0;
			foreach (var method in methods) {
				routes[i++] = this.route (new Route.from_rule (this, method, rule, (owned) cb));
			}
			return routes;
		}

		/**
		 * Bind a callback with a custom HTTP method and regular expression.
		 *
		 * The regular expression will be scoped, anchored and optimized by the
		 * {@link Route} automatically.
		 *
		 * @since 0.1
		 *
		 * @param method HTTP method or 'null' for any
		 * @param regex  regular expression matching the request path.
		 * @param cb     callback used to process the pair of request and response.
		 */
		public Route regex (string? method, Regex regex, owned HandlerCallback cb) throws RegexError {
			return this.route (new Route.from_regex (this, method, regex, (owned) cb));
		}

		/**
		 * Bind a callback with a custom HTTP method and a matcher callback.
		 *
		 * @since 0.1
		 *
		 * @param method  HTTP method or 'null' for any
		 * @param matcher callback used to match the request
		 * @param cb      callback used to process the pair of request and response.
		 */
		public Route matcher (string? method, owned MatcherCallback matcher, owned HandlerCallback cb) {
			return this.route (new Route (this, method, (owned) matcher, (owned) cb));
		}

		/**
		 * Bind a {@link Route} to a custom HTTP method.
		 *
		 * This is a low-level function and should be used with care.
		 *
		 * @param method HTTP method
		 * @param route  an instance of Route defining the matching process and the
		 *               callback.
		 */
		private Route route (Route route) {
			this.routes.push_tail (route);
			return route;
		}

		/**
		 * Bind a callback to handle a particular thrown status code.
		 *
		 * This only applies to status thrown by one of {@link Redirection}
		 * {@link ClientError} or {@link ServerError} domains.
		 *
		 * @param status status handled
		 * @param cb     callback used to handle the status
		 */
		public void status (uint status, owned HandlerCallback cb) {
			if (!this.status_handlers.contains (status))
				this.status_handlers[status] = new Queue<Route> ();

			this.status_handlers[status].push_tail (new Route (this,
			                                                   null,
			                                                   () => { return true; },
			                                                   (owned) cb));
		}

		/**
		 * Add a fragment to the scope stack and nest a router in this new
		 * environment.
		 *
		 * Scoping will only work with rules and regular expressions.
		 *
		 * @since 0.0.1
		 *
		 * @param fragment fragment to push on the scopes stack
		 * @param loader   nests a router in the new scoped environment
		 */
		public void scope (string fragment, owned LoaderCallback loader) {
			this.scopes.push_tail (fragment);
			loader (this);
			this.scopes.pop_tail ();
		}

		/**
		 * Perform the routing given a specific list of routes.
		 *
		 * @param routes sequence of routes to traverse
		 * @param req    request
		 * @param res    response
		 * @param stack  routing stack passed to match and fire
		 * @return tells if something matched during the routing process
		 */
		private bool perform_routing (List<Route> routes,
		                              Request req,
		                              Response res,
		                              Queue<Value?> stack) throws Informational,
		                                                          Success,
		                                                          Redirection,
		                                                          ClientError,
		                                                          ServerError,
		                                                          Error {
			var tmp_stack = new Queue<Value?> ();
			for (unowned List<Route> node = routes; node != null; node = node.next) {
				tmp_stack.clear ();
				if ((node.data.method == null || node.data.method == req.method) && node.data.match (req, tmp_stack)) {
					// commit the stack pushes
					while (!tmp_stack.is_empty ())
						stack.push_tail (tmp_stack.pop_head ());
					node.data.fire (req, res, (req, res) => {
						// keep routing if there are more routes to explore
						if (node.next != null)
							if (perform_routing (node.next, req, res, stack))
								return;
						throw new ClientError.NOT_FOUND ("The request URI %s was not found.", req.uri.to_string (true));
					}, stack);
					return true;
				}
			}
			return false;
		}

		/**
		 * Invoke the {@link NextCallback} in the routing context.
		 *
		 * This is particularly useful to invoke next in an async callback when
		 * the routing context is lost.
		 *
		 * @since 0.2
		 *
		 * @param req   request for the context
		 * @param res   response for the context
		 * @param next  callback to be invoked in the routing context
		 */
		public void invoke (Request req, Response res, owned NextCallback next) {
			try {
				next (req, res);
			} catch (Error err) {
				// replace any other error by a 500 status
				var status_code = (err is Informational ||
								   err is Success ||
								   err is Redirection ||
								   err is ClientError ||
								   err is ServerError) ?  err.code : 500;

				/*
				 * Only the error message is pushed on the stack, the handler
				 * should assume that the status code is the one for which it
				 * has been registered.
				 */
				if (this.status_handlers.contains (status_code)) {
					var stack = new Queue<Value?> ();
					stack.push_tail (err.message);
					try {
						if (this.perform_routing (this.status_handlers[status_code].head, req, res, stack))
							return; // handled!
					} catch (Error err) {
						// feed the error back in the invocation
						invoke (req, res, () => {
							throw err;
						});
						return;
					}
				}

				// default status code handling
				res.status = status_code;

				/*
				 * The error message is used as a header if the HTTP/1.1
				 * specification indicate that it MUST be provided.
				 *
				 * The content encoding is set to NONE if the HTTP/1.1
				 * specification indicates that an entity MUST NOT be
				 * provided.
				 *
				 * For practical purposes, the error message is used for the
				 * 'Location' of redirection codes.
				 */
				switch (status_code) {
					case global::Soup.Status.SWITCHING_PROTOCOLS:
						res.headers.replace ("Upgrade", err.message);
						res.headers.set_encoding (Soup.Encoding.NONE);
						break;

					case global::Soup.Status.CREATED:
						res.headers.replace ("Location", err.message);
						break;

					// no content
					case global::Soup.Status.NO_CONTENT:
					case global::Soup.Status.RESET_CONTENT:
						res.headers.set_encoding (Soup.Encoding.NONE);
						break;

					case global::Soup.Status.PARTIAL_CONTENT:
						res.headers.replace ("Range", err.message);
						break;

					case global::Soup.Status.MOVED_PERMANENTLY:
					case global::Soup.Status.FOUND:
					case global::Soup.Status.SEE_OTHER:
						res.headers.replace ("Location", err.message);
						break;

					case global::Soup.Status.NOT_MODIFIED:
						res.headers.set_encoding (Soup.Encoding.NONE);
						break;

					case global::Soup.Status.USE_PROXY:
					case global::Soup.Status.TEMPORARY_REDIRECT:
						res.headers.replace ("Location", err.message);
						break;

					case global::Soup.Status.UNAUTHORIZED:
						res.headers.replace ("WWW-Authenticate", err.message);
						break;

					case global::Soup.Status.METHOD_NOT_ALLOWED:
						res.headers.append ("Allow", err.message);
						break;

					case 426: // Upgrade Required
						res.headers.replace ("Upgrade", err.message);
						break;

					// basic handling
					default:
						var @params = new HashTable<string, string> (str_hash, str_equal);
						@params["charset"] = "utf-8";
						res.headers.set_content_type ("text/plain", @params);
						res.headers.set_content_length (err.message.data.length);
						try {
							size_t bytes_written;
							res.body.write_all (err.message.data, out bytes_written);
						} catch (IOError io_err) {
							warning (io_err.message);
						}
						break;
				}

				try {
					res.body.close ();
				} catch (IOError io_err) {
					warning (io_err.message);
				}
			}
		}

		/**
		 * Perform the routing of the request by calling {@link Valum.Router.invoke}.
		 *
		 * If nothing matches the request, look for alternate HTTP methods and
		 * raise a {@link Valum.ClientError.METHOD_NOT_ALLOWED}, otherwise
		 * raise a {@link Valum.ClientError.NOT_FOUND} exception.
		 *
		 * The response is initialized with 'chunked' transfer encoding since
		 * most processing are generally based on stream.
		 *
		 * @since 0.1
		 */
		public void handle (Request req, Response res) {
			// sane initialization
			if (req.http_version == Soup.HTTPVersion.@1_1)
				res.headers.set_encoding (Soup.Encoding.CHUNKED);

			// initial invocation
			this.invoke (req, res, () => {
				var stack = new Queue<Value?> ();

				// ensure at least one route has been declared with that method
				if (this.perform_routing (this.routes.head, req, res, stack))
					return; // something matched

				// find routes from other methods matching this request
				string[] allowed = {};
				foreach (var route in this.routes.head) {
					if (route.method != null &&                  // null method allow anything
					    route.method != req.method &&            // exclude the request method (it's not allowed already)
#if GLIB_2_44
					    !strv_contains (allowed, route.method) && // skip already allowed method
#else
					    !string.joinv (",", allowed).contains (route.method) &&
#endif
					    route.match (req, stack)) {
						allowed += route.method;
					}
				}

				// other method(s) match this request
				if (allowed.length > 0)
					throw new ClientError.METHOD_NOT_ALLOWED (string.joinv (", ", allowed));

				throw new ClientError.NOT_FOUND ("The request URI %s was not found.", req.uri.to_string (true));
			});
		}
	}
}
