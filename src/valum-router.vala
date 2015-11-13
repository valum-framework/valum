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
		private Queue<Route?> routes = new Queue<Route?> ();

		/**
		 * Registered status handlers.
		 */
		private HashTable<uint , Queue<Route?>> status_handlers = new HashTable<uint, Queue<Route?>> (direct_hash, direct_equal);

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
		public new Builder get (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.rule (Request.GET, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Builder post (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.rule (Request.POST, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Builder put (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.rule (Request.PUT, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Builder delete (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.rule (Request.DELETE, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Builder head (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.rule (Request.HEAD, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Builder options (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.rule (Request.OPTIONS, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Builder trace (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.rule (Request.TRACE, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public new Builder connect (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.rule (Request.CONNECT, rule, (owned) cb);
		}

		/**
		 * [[http://tools.ietf.org/html/rfc5789]]
		 *
		 * @since 0.0.1
		 */
		public Builder patch (string? rule, owned HandlerCallback cb) throws RegexError {
			return this.rule (Request.PATCH, rule, (owned) cb);
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
		[Deprecated (since = "0.3", replacement = "rule")]
		public Builder method (string method, string? rule, owned HandlerCallback cb) throws RegexError {
			return this.rule (method, rule, (owned) cb);
		}

		/**
		 * Bind a callback to all HTTP methods defined in {@link VSGI.Request.METHODS}.
		 *
		 * @since 0.1
		 */
		public Builder[] all (string? rule, owned HandlerCallback cb) throws RegexError {
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
		public Builder[] methods (string[] methods, string? rule, owned HandlerCallback cb) throws RegexError {
			var routes = new Builder[methods.length];
			var i      = 0;
			foreach (var method in methods) {
				routes[i++] = this.rule (method, rule, (owned) cb);
			}
			return routes;
		}

		/**
		 * Compile a rule into a regular expression.
		 *
		 * Parameters are compiled down to named captures and any other
		 * character goes through {@link Regex.escape_string}.
		 *
		 * The compilation process is contextualized for this {@link Valum.Router}
		 * to honor its defined types.
		 *
		 * @since 0.3
		 *
		 * @param rule the rule to compile down to regular expression
		 * @return a regular expression pattern
		 */
		public string compile_rule (string rule) throws RegexError {
			var @params = /(<(?:\w+:)?\w+>)/.split_full (rule);
			var pattern = new StringBuilder ();

			foreach (var p in @params) {
				if (p[0] != '<') {
					// regular piece of route
					pattern.append (Regex.escape_string (p));
				} else {
					// extract parameter
					var cap  = p.slice (1, p.length - 1).split (":", 2);
					var type = cap.length == 1 ? "string" : cap[0];
					var key  = cap.length == 1 ? cap[0] : cap[1];

					if (!this.types.contains (type))
						throw new RegexError.COMPILE ("using an undefined type %s", type);

					pattern.append ("(?<%s>%s)".printf (key, this.types[type].get_pattern ()));
				}
			}

			return pattern.str;
		}

		/**
		 * Create a Route for a given callback from a rule.
         *
		 * Rule are scoped from the {@link Router.scope} fragment stack and
		 * compiled down to {@link GLib.Regex}.
		 *
		 * The 'null' rule is a special rule that captures anything '.*'.
		 *
		 * Rule start matching after the first '/' character of the request URI
		 * path.
		 *
		 * @since 0.3
		 *
		 * @param method method matching this rule
		 * @param rule   rule or 'null' to capture all possible paths
		 * @param cb     handling callback
		 *
		 * @throws RegexError if the rule is incorrectly formed or a type is
		 *                    undefined in the 'types' mapping
		 *
		 * @return a builder upon the created {@link Route} object
		 */
		public Builder rule (string method, string? rule, owned HandlerCallback cb) throws RegexError {
			// catch-all null rule
			if (rule == null) {
				return this.regex (method, /(?<path>.*)/, (owned) cb);
			} else {
				return this.regex (method, new Regex (compile_rule (rule)), (owned) cb);
			}
		}

		/**
		 * Create a Route for a given callback using a {@link GLib.Regex}.
		 *
		 * The providen regular expression pattern will be extracted, scoped,
		 * anchored and optimized. This means you must not anchor the regex
		 * yourself with '^' and '$' characters and providing a pre-optimized
		 * {@link GLib.Regex} is useless.
		 *
		 * Like for the rules, the regular expression starts matching after the
		 * scopes and the leading '/' character.
		 *
		 * @since 0.1
		 *
		 * @param method HTTP method
		 * @param regex  regular expression matching the request path.
		 * @param cb     callback used to process the pair of request and response.
		 *
		 * @return a builder upon the created {@link Route} object
		 */
		public Builder regex (string method, Regex regex, owned HandlerCallback cb) throws RegexError {
			var pattern = new StringBuilder ("^");

			// root the route
			pattern.append ("/");

			// scope the route
			foreach (var scope in this.scopes.head) {
				pattern.append_printf ("%s/", compile_rule (scope));
			}

			pattern.append (regex.get_pattern ());

			pattern.append ("$");

			// extract the captures from the regular expression
			var captures = new SList<string> ();
			MatchInfo capture_match_info;

			if (/\(\?<(\w+)>.+?\)/.match (pattern.str, 0, out capture_match_info)) {
				do {
					captures.append (capture_match_info.fetch (1));
				} while (capture_match_info.next ());
			}

			// regex are optimized automatically :)
			var prepared_regex = new Regex (pattern.str, RegexCompileFlags.OPTIMIZE);

			return this.matcher (method, (req, stack) => {
				MatchInfo match_info;
				if (prepared_regex.match (req.uri.get_path (), 0, out match_info)) {
					if (captures.length () > 0) {
						// populate the request parameters
						var p = new HashTable<string, string?> (str_hash, str_equal);
						foreach (var capture in captures) {
							p[capture] = match_info.fetch_named (capture);
							stack.push_tail (match_info.fetch_named (capture));
						}
						req.params = p;
					}
					return true;
				}
				return false;
			}, (owned) cb);
		}

		/**
		 * Bind a callback with a custom HTTP method and a matcher callback.
		 *
		 * @since 0.1
		 *
		 * @param method  HTTP method
		 * @param matcher callback used to match the request
		 * @param cb      callback used to process the pair of request and response.
		 *
		 * @return a builder upon the created {@link Route} object
		 */
		public Builder matcher (string method, owned MatcherCallback matcher, owned HandlerCallback cb) {
			return this.route ({method, (owned) matcher, (owned) cb});
		}

		/**
		 * Bind a {@link Route} to a custom HTTP method.
		 *
		 * This is a low-level function and should be used with care.
		 *
		 * @param route  an instance of Route defining the matching process and the
		 *               handling callback.
		 *
		 * @return a builder upon the created {@link Route} object
		 */
		private Builder route (owned Route route) {
			this.routes.push_tail (route);
			return new Builder (this, routes.tail);
		}

		/**
		 * Bind a callback to handle a particular thrown status code.
		 *
		 * This only applies to status thrown by one of {@link Redirection}
		 * {@link ClientError} or {@link ServerError} domains.
		 *
		 * @param status status handled
		 * @param cb     callback used to handle the status
		 *
		 * @return a builder upon the created {@link Route} object
		 */
		public Builder status (uint status, owned HandlerCallback cb) {
			if (!this.status_handlers.contains (status))
				this.status_handlers[status] = new Queue<Route?> ();

			this.status_handlers[status].push_tail ({null, () => { return true; }, (owned) cb});
			return new Builder (this, status_handlers[status].tail);
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
		private bool perform_routing (List<Route?> routes, Request req, Response res, Queue<Value?> stack) throws Informational, Success, Redirection, ClientError, ServerError {
			foreach (var route in routes) {
				if ((route.method == null || route.method == req.method) && route.match (req, stack)) {
					route.fire (req, res, (req, res) => {
						unowned List<Route?> current = routes.find (route);
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
		 */
		public void invoke (Request req, Response res, owned NextCallback next) {
			try {
				try {
					next (req, res);
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
			} catch (Success.NO_CONTENT s) {
				res.status = s.code;
			} catch (Success.RESET_CONTENT s) {
				res.status = s.code;
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
				var @params = new HashTable<string, string> (str_hash, str_equal);
				@params["charset"] = "utf-8";
				res.headers.set_content_type ("text/plain", @params);
				res.headers.set_content_length (e.message.data.length);
				size_t bytes_written;
				res.body.write_all (e.message.data, out bytes_written);
			}

			res.body.close ();
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
			var @params = new HashTable<string, string> (str_hash, str_equal);
			@params["charset"] = "utf-8";
			res.headers.set_content_type ("text/html", @params);
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
					    !string.joinv ("", allowed).contains (route.method) &&
#endif
					    route.match (req, stack)) {
						allowed += route.method;
					}
				}

				// other method(s) match this request
				if (allowed.length > 0)
					throw new ClientError.METHOD_NOT_ALLOWED (string.joinv (", ", allowed));

				throw new ClientError.NOT_FOUND ("The request URI %s was not found.".printf (req.uri.to_string (false)));
			});
		}

		/**
		 * Builder to chain route creation upon a given router.
		 *
		 * @since 0.3
		 */
		public class Builder : Object {

			/**
			 * @since 0.3
			 */
			public Router router { construct; get; }

			/**
			 * Node in the routes queue this is building upon.
			 *
			 * @since 0.3
			 */
			public unowned List<Route?> node { construct; get; }

			/**
			 * @since 0.3
			 */
			protected Builder (Router router, List<Route?> node) {
				Object (router: router, node: node);
			}

			/**
			 * Insert a {@link Valum.Route} right after the created route using
			 * its matcher and a provided handler in the {@link Valum.Router}
			 * queue.
			 *
			 * @since 0.2
			 *
			 * @param handler callback for the {@link Valum.Route} to be created.
			 * @return a builder over the created {@link Valum.Route}
			 */
			public Builder then (owned HandlerCallback handler) {
				router.routes.insert_after (node,
				                            {node.data.method, node.data.match, (owned) handler});
				return new Builder (router, node.next);
			}
		}
	}
}
