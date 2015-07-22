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
		private HashTable<string, Queue<Route>> routes = new HashTable<string, Queue<Route>> (str_hash, str_equal);

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
		 * @since 0.0.1
		 */
		public new Route get (string? rule, HandlerCallback cb) throws RegexError {
			return this.method (Request.GET, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route post (string? rule, HandlerCallback cb) throws RegexError {
			return this.method (Request.POST, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route put (string? rule, HandlerCallback cb) throws RegexError {
			return this.method (Request.PUT, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route delete (string? rule, HandlerCallback cb) throws RegexError {
			return this.method (Request.DELETE, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route head (string? rule, HandlerCallback cb) throws RegexError {
			return this.method (Request.HEAD, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route options (string? rule, HandlerCallback cb) throws RegexError {
			return this.method (Request.OPTIONS, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route trace (string? rule, HandlerCallback cb) throws RegexError {
			return this.method (Request.TRACE, rule, cb);
		}

		/**
		 * @since 0.0.1
		 */
		public new Route connect (string? rule, HandlerCallback cb) throws RegexError {
			return this.method (Request.CONNECT, rule, cb);
		}

		/**
		 * [[http://tools.ietf.org/html/rfc5789]]
		 *
		 * @since 0.0.1
		 */
		public Route patch (string? rule, HandlerCallback cb) throws RegexError {
			return this.method (Request.PATCH, rule, cb);
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
		public Route method (string method, string? rule, HandlerCallback cb) throws RegexError {
			return this.route (method, new Route.from_rule (this, method, rule, cb));
		}

		/**
		 * Bind a callback to all HTTP methods defined in {@link VSGI.Request.METHODS}.
		 *
		 * @since 0.1
		 */
		public void all (string? rule, HandlerCallback cb) throws RegexError {
			this.methods (Request.METHODS, rule, cb);
		}

		/**
		 * Bind a callback to a list of HTTP methods.
		 *
		 * @since 0.1
		 *
		 * @param methods methods to which the callback will be bound
		 * @param rule    rule
		 */
		public void methods (string[] methods, string? rule, HandlerCallback cb) throws RegexError {
			var route = new Route.from_rule (this, null, rule, cb);
			foreach (var method in methods) {
				this.route (method, route);
			}
		}

		/**
		 * Bind a callback with a custom HTTP method and regular expression.
		 *
		 * The regular expression will be scoped, anchored and optimized by the
		 * {@link Route} automatically.
		 *
		 * @since 0.1
		 *
		 * @param method HTTP method
		 * @param regex  regular expression matching the request path.
		 * @param cb     callback used to process the pair of request and response.
		 */
		public Route regex (string method, Regex regex, HandlerCallback cb) throws RegexError {
			return this.route (method, new Route.from_regex (this, method, regex, cb));
		}

		/**
		 * Bind a callback with a custom HTTP method and a matcher callback.
		 *
		 * @since 0.1
		 *
		 * @param method  HTTP method
		 * @param matcher callback used to match the request
		 * @param cb      callback used to process the pair of request and response.
		 */
		public Route matcher (string method, MatcherCallback matcher, HandlerCallback cb) {
			return this.route (method, new Route (this, method, matcher, cb));
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
		private Route route (string method, Route route) {
			if (!this.routes.contains (method))
				this.routes[method] = new Queue<Route> ();

			this.routes[method].push_tail (route);

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
		public void status (uint status, HandlerCallback cb) {
			if (!this.status_handlers.contains (status))
				this.status_handlers[status] = new Queue<Route> ();

			this.status_handlers[status].push_tail (new Route (this, null, () => { return true; }, cb));
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
		public void scope (string fragment, LoaderCallback loader) {
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
		 * @param state  propagated state
		 * @return tells if something matched during the routing process
		 */
		private bool perform_routing (List<Route> routes, Request req, Response res, Queue<Value?> stack) throws Informational, Success, Redirection, ClientError, ServerError {
			foreach (var route in routes) {
				if (route.match (req, stack)) {
					route.fire (req, res, () => {
						unowned List<Route> current = routes.find (route);
						// keep routing if there are more routes to explore
						if (current.next != null)
							if (perform_routing (current.next, req, res, stack))
								return;
						throw new ClientError.NOT_FOUND ("The request URI %s was not found.".printf (req.uri.to_string (false)));
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
		 * @param state state to pass to the callback
		 */
		public void invoke (Request req, Response res, NextCallback next) {
			try {
				try {
					next ();
					return;
				} catch (Error e) {
					// handle using a registered status handler
					if (this.status_handlers.contains (e.code)) {
						var stack = new Queue<Value?> ();
						stack.push_tail (e.message);
						if (this.perform_routing (this.status_handlers[e.code].head, req, res, stack)) {
							return;
						}
					}

					// propagate the error if it is not handled
					throw e;
				}

			// default status code handling
			} catch (Informational.SWITCHING_PROTOCOLS i) {
				res.status = i.code;
				res.headers.append ("Upgrade", i.message);
			} catch (Success.CREATED s) {
				res.status = s.code;
				res.headers.append ("Location", s.message);
			} catch (Success.PARTIAL_CONTENT s) {
				res.status = s.code;
				res.headers.append ("Range", s.message);
			} catch (Redirection r) {
				res.status = r.code;
				res.headers.append ("Location", r.message);
			} catch (ClientError.METHOD_NOT_ALLOWED c) {
				res.status = c.code;
				res.headers.append ("Allow", c.message);
			} catch (ClientError.UPGRADE_REQUIRED c) {
				res.status = c.code;
				res.headers.append ("Upgrade", c.message);
			} catch (Error e) {
				res.status = e.code;
			}

			// write head if a status has been thrown
			res.write_head ();
		}

		/**
		 * {@inheritDoc}
		 *
		 * The response is initialized with sane default such as 200 status
		 * code, 'text/html' content type, 'chunked' transfer encoding and
		 * request cookies.
		 */
		public void handle (Request req, Response res) {
			// sane initialization
			res.status = Soup.Status.OK;
			res.headers.set_content_type ("text/html", null);
			if (req.http_version == Soup.HTTPVersion.@1_1)
				res.headers.set_encoding (Soup.Encoding.CHUNKED);

			// initial invocation
			this.invoke (req, res, () => {
				var stack = new Queue<Value?> ();

				// ensure at least one route has been declared with that method
				if (this.routes.contains (req.method))
					if (this.perform_routing (this.routes[req.method].head, req, res, stack))
						return; // something matched

				// find routes from other methods matching this Request
				var allowed = new StringBuilder ();
				foreach (var method in this.routes.get_keys ()) {
					if (method != req.method) {
						foreach (var route in this.routes[method].head) {
							if (route.match (req, stack)) {
								if (allowed.len > 0)
									allowed.append (", ");
								allowed.append (method);
								break;
							}
						}
					}
				}

				// a Route from another method allows this Request
				if (allowed.len > 0)
					throw new ClientError.METHOD_NOT_ALLOWED (allowed.str);

				throw new ClientError.NOT_FOUND ("The request URI %s was not found.".printf (req.uri.to_string (false)));
			});
		}
	}
}
