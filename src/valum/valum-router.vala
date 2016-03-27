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
		private HashTable<string, Regex> types = new HashTable<string, Regex> (str_hash, str_equal);

		/**
		 * Registered routes by HTTP method.
		 */
		private Sequence<Route> routes = new Sequence<Route> ();

		/**
		 * Registered status handlers.
		 */
		private HashTable<uint , Sequence<Route>> status_handlers = new HashTable<uint, Sequence<Route>> (direct_hash, direct_equal);

		/**
		 * Stack of scopes.
		 *
		 * @since 0.1
		 */
		private Queue<string> scopes = new Queue<string> ();

		construct {
			// initialize default types
			register_type ("int",    /\d+/);
			register_type ("string", /\w+/);
			register_type ("path",   /(?:\.?[\w-\s\/])+/);
		}

		/**
		 * Register a type to be understood by {@link Valum.RuleRoute}.
		 *
		 * If a type is already registered with that name, it is replaced with
		 * the new definition.
		 *
		 * @since 0.3
		 *
		 * @param name             name by which types are identified in the
		 *                         rule pattern
		 * @param pattern          matches instance of the type in a path
		 * @param destination_type type into which the extracted value will be
		 *                         converted
		 */
		public void register_type (string name, Regex pattern, Type destination_type = typeof (string)) {
			types[name] = pattern;
		}

		/**
		 * Mount a handling middleware on the routing queue.
		 *
		 * @since 0.3
		 */
		public Route use (owned HandlerCallback cb) {
			return route (new AnyRoute (Method.ANY, (owned) cb));
		}

		/**
		 * Bind a callback to handle asterisk '*'.
		 *
		 * Typically, this is used with {@link Valum.Method.OPTIONS} to provide
		 * general information about the service.
		 *
		 * @since 0.3
		 */
		public Route asterisk (Method method, owned HandlerCallback cb) {
			return this.route (new AsteriskRoute (method, (owned) cb));
		}

		/**
		 * @since 0.0.1
		 */
		public new Route get (string rule, owned HandlerCallback cb) {
			return this.rule (Method.GET, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route post (string rule, owned HandlerCallback cb) {
			return this.rule (Method.POST, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route put (string rule, owned HandlerCallback cb) {
			return this.rule (Method.PUT, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route delete (string rule, owned HandlerCallback cb) {
			return this.rule (Method.DELETE, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route head (string rule, owned HandlerCallback cb) {
			return this.rule (Method.HEAD, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route options (string rule, owned HandlerCallback cb) {
			return this.rule (Method.OPTIONS, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public Route trace (string rule, owned HandlerCallback cb) {
			return this.rule (Method.TRACE, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public new Route connect (string rule, owned HandlerCallback cb) {
			return this.rule (Method.CONNECT, rule, (owned) cb);
		}

		/**
		 * [[http://tools.ietf.org/html/rfc5789]]
		 *
		 * @since 0.0.1
		 */
		public Route patch (string rule, owned HandlerCallback cb) {
			return this.rule (Method.PATCH, rule, (owned) cb);
		}

		/**
		 * Bind a callback with a custom method.
		 *
		 * The actual rule is scoped, anchored and compiled down to a
		 * {@link GLib.Regex}.
		 *
		 * @since 0.1
		 *
		 * @param method HTTP method
		 * @param rule   rule
		 * @param cb     callback used to process the pair of request and response.
		 */
		public Route rule (Method method, string rule, owned HandlerCallback cb) {
			var pattern = new StringBuilder ();

			// scope the route
			foreach (var scope in scopes.head) {
				pattern.append (scope);
			}

			pattern.append (rule);

			try {
				return this.route (new RuleRoute (method | Method.PROVIDED, pattern.str, types, (owned) cb));
			} catch (RegexError err) {
				error (err.message);
			}
		}

		/**
		 * Bind a callback with a custom HTTP method and regular expression.
		 *
		 * The providen regular expression pattern will be extracted, scoped,
		 * anchored and optimized. This means you must not anchor the regex yourself
		 * with '^' and '$' characters and providing a pre-optimized {@link  GLib.Regex}
		 * is useless.
		 *
		 * @since 0.1
		 *
		 * @param method HTTP method or 'null' for any
		 * @param regex  regular expression matching the request path.
		 * @param cb     callback used to process the pair of request and response.
		 */
		public Route regex (Method method, Regex regex, owned HandlerCallback cb) {
			var pattern = new StringBuilder ();

			pattern.append ("^");

			// scope the route
			foreach (var scope in scopes.head) {
				pattern.append (Regex.escape_string (scope));
			}

			pattern.append (regex.get_pattern ());

			pattern.append ("$");

			try {
				return route (new RegexRoute (method | Method.PROVIDED, new Regex (pattern.str, RegexCompileFlags.OPTIMIZE), (owned) cb));
			} catch (RegexError err) {
				error (err.message);
			}
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
		public Route matcher (Method method, owned MatcherCallback matcher, owned HandlerCallback cb) {
			return this.route (new MatcherRoute (method | Method.PROVIDED, (owned) matcher, (owned) cb));
		}

		/**
		 * Bind a {@link Route} to a custom HTTP method.
		 *
		 * @since 0.3
		 *
		 * @param route an instance of Route defining the matching process and
		 *              the callback.
		 */
		public Route route (Route route) {
			this.routes.append (route);
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
		public Route status (uint status, owned HandlerCallback cb) {
			if (!this.status_handlers.contains (status))
				this.status_handlers[status] = new Sequence<Route> ();

			var route = new AnyRoute (Method.ANY, (owned) cb);
			this.status_handlers[status].append (route);
			return route;
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
		 * @param routes  sequence of routes to traverse
		 * @param req     request
		 * @param res     response
		 * @param context routing context passed to match and fire
		 * @return tells if something matched during the routing process
		 */
		private bool perform_routing (SequenceIter<Route> routes,
		                              Request req,
		                              Response res,
		                              Context context) throws Informational,
		                                                          Success,
		                                                          Redirection,
		                                                          ClientError,
		                                                          ServerError,
		                                                          Error {
			for (SequenceIter<Route> node = routes; !node.is_end (); node = node.next ()) {
				var req_method = Method.from_string (req.method);
				var local_context = new Context.with_parent (context);
				if (req_method in node.@get ().method && node.@get ().match (req, local_context)) {
					return node.@get ().fire (req, res, () => {
						// keep routing if there are more routes to explore
						if (node.next ().is_end ()) {
							return false;
						} else {
							return perform_routing (node.next (), req, res, local_context);
						}
					}, local_context);
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
		public bool invoke (Request req, Response res, NextCallback next) {
			try {
				return next ();
			} catch (Error err) {
				// replace any other error by a 500 status
				var status_code = (err is Informational ||
								   err is Success ||
								   err is Redirection ||
								   err is ClientError ||
								   err is ServerError) ?  err.code : 500;

				/*
				 * Only the error message is pushed on the routing context, the
				 * handler should assume that the status code is the one for
				 * which it has been registered.
				 */
				if (this.status_handlers.contains (status_code)) {
					var context = new Context ();
					context["message"] = err.message;
					try {
						if (this.perform_routing (this.status_handlers[status_code].get_begin_iter (), req, res, context))
							return true; // handled!
					} catch (Error err) {
						var _err = err; // Vala bug, '_err' is not in the closure scope
						// feed the error back in the invocation
						return invoke (req, res, () => {
							throw _err;
						});
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
						var @params = new HashTable<string, string> ((HashFunc<string>) Soup.str_case_hash,
						                                             (EqualFunc<string>) Soup.str_case_equal);
						@params["charset"] = "utf-8";
						res.headers.set_content_type ("text/plain", @params);
						try {
							return res.expand_utf8 (err.message);
						} catch (IOError io_err) {
							warning (io_err.message);
						}
						break;
				}

				return true;
			}
		}

		/**
		 * Perform the routing of the request by calling {@link Valum.Router.invoke}.
		 *
		 * If nothing matches the request, look for alternate HTTP methods and
		 * raise a {@link Valum.ClientError.METHOD_NOT_ALLOWED}, otherwise
		 * raise a {@link Valum.ClientError.NOT_FOUND} exception.
		 *
		 * @since 0.1
		 */
		public bool handle (Request req, Response res) {
			// initial invocation
			return this.invoke (req, res, () => {
				var context = new Context ();

				// ensure at least one route has been declared with that method
				if (this.perform_routing (this.routes.get_begin_iter (), req, res, context))
					return true; // something matched

				// find routes from other methods matching this request
				var req_method = Method.from_string (req.method);

				// prevent head w/o get
				if (req_method in Method.GET)
					req_method |= Method.GET;

				// prevent the meta
				req_method |= Method.META;

				Method allowed = 0;
				this.routes.@foreach ((route) => {
					if (Method.PROVIDED in route.method && route.match (req, new Context ())) {
						allowed |= route.method & ~req_method;
					}
				});

				// other method(s) match this request
				if (allowed > 0) {
					string[] allowedv = {};
					var method_class = (FlagsClass) typeof (Method).class_ref ();

					do {
						unowned FlagsValue flags_value = method_class.get_first_value (allowed);
						allowed  &= ~flags_value.@value;
						allowedv += flags_value.value_nick == "only-get" ? "GET" : flags_value.value_nick.up ();
					} while (allowed > 0);

					if (req.method == Request.OPTIONS) {
						res.status = Soup.Status.OK;
						res.headers.append ("Allow", string.joinv (", ", allowedv));
						return res.expand_utf8 (""); // result in 'Content-Length: 0' as specified
					} else {
						throw new ClientError.METHOD_NOT_ALLOWED (string.joinv (", ", allowedv));
					}
				}

				throw new ClientError.NOT_FOUND ("The request URI %s was not found.", req.uri.to_string (true));
			});
		}
	}
}
