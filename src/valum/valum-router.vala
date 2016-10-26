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
	 */
	[Version (since = "0.1")]
	public class Router : Object {

		/**
		 * Global routing context.
		 */
		[Version (since = "0.3")]
		public Context context { get; construct; }

		[Version (since = "0.3", experimental = true)]
		public Sequence<Route> routes = new Sequence<Route> ();

		private HashTable<string, Regex> types  = new HashTable<string, Regex> (str_hash, str_equal);
		private Queue<string>            scopes = new Queue<string> ();

		[Version (since = "0.3")]
		public Router () {
			Object (context: new Context ());
		}

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
		 * @param name             name by which types are identified in the
		 *                         rule pattern
		 * @param pattern          matches instance of the type in a path
		 */
		[Version (since = "0.3")]
		public void register_type (string name, Regex pattern) {
			types[name] = pattern;
		}

		[Version (since = "0.3")]
		public void once (owned HandlerCallback cb) {
			size_t _once_init = 0;
			route (new MatcherRoute (Method.ANY, () => { return _once_init == 0; }, (req, res, next, ctx) => {
				if (Once.init_enter (&_once_init)) {
					try {
						return cb (req, res, next, ctx);
					} finally {
						Once.init_leave (&_once_init, 1);
					}
				} else {
					return next ();
				}
			}));
		}

		/**
		 * Mount a handling middleware on the routing queue.
		 */
		[Version (since = "0.3")]
		public void use (owned HandlerCallback cb) {
			route (new MatcherRoute (Method.ANY, () => { return true; }, (owned) cb));
		}

		/**
		 * Bind a callback to handle asterisk '*' URI.
		 *
		 * Typically, this is used with {@link Valum.Method.OPTIONS} to provide
		 * general information about the service.
		 */
		[Version (since = "0.3")]
		public void asterisk (Method method, owned HandlerCallback cb) {
			route (new AsteriskRoute (method, (owned) cb));
		}

		/**
		 * Since the {@link Valum.Method.GET} flag is used, 'HEAD' will be
		 * provided as well.
		 */
		[Version (since = "0.1")]
		public new void @get (string rule, owned HandlerCallback cb, string? name = null) {
			this.rule (Method.GET, rule, (owned) cb, name);
		}

		[Version (since = "0.1")]
		public void post (string rule, owned HandlerCallback cb, string? name = null) {
			this.rule (Method.POST, rule, (owned) cb, name);
		}

		[Version (since = "0.1")]
		public void put (string rule, owned HandlerCallback cb, string? name = null) {
			this.rule (Method.PUT, rule, (owned) cb, name);
		}

		[Version (since = "0.1")]
		public void @delete (string rule, owned HandlerCallback cb, string? name = null) {
			this.rule (Method.DELETE, rule, (owned) cb, name);
		}

		[Version (since = "0.1")]
		public void head (string rule, owned HandlerCallback cb, string? name = null) {
			this.rule (Method.HEAD, rule, (owned) cb, name);
		}

		[Version (since = "0.1")]
		public void options (string rule, owned HandlerCallback cb, string? name = null) {
			this.rule (Method.OPTIONS, rule, (owned) cb);
		}

		[Version (since = "0.1")]
		public void trace (string rule, owned HandlerCallback cb, string? name = null) {
			this.rule (Method.TRACE, rule, (owned) cb, name);
		}

		[Version (since = "0.1")]
		public new void connect (string rule, owned HandlerCallback cb, string? name = null) {
			this.rule (Method.CONNECT, rule, (owned) cb, name);
		}

		/**
		 * [[http://tools.ietf.org/html/rfc5789]]
		 */
		[Version (since = "0.1")]
		public void patch (string rule, owned HandlerCallback cb, string? name = null) {
			this.rule (Method.PATCH, rule, (owned) cb, name);
		}

		/**
		 * Bind a callback to a given method and rule.
		 *
		 * The actual rule is scoped, anchored and compiled down to a
		 * {@link GLib.Regex}.
		 *
		 * The method will be marked as provided with the {@link Valum.Method.PROVIDED}
		 * flag.
		 *
		 * @param method flag for allowed HTTP methods
		 * @param rule   rule matching the request path
		 * @param cb     callback used to process the pair of request and response
		 */
		[Version (since = "0.3")]
		public void rule (Method method, string rule, owned HandlerCallback cb, string? name = null) {
			var pattern = new StringBuilder ();

			// scope the route
			foreach (var scope in scopes.head) {
				pattern.append (scope);
			}

			pattern.append (rule);

			try {
				route (new RuleRoute (method | Method.PROVIDED, pattern.str, types, (owned) cb), name);
			} catch (RegexError err) {
				error ("%s (%s, %d)", err.message, err.domain.to_string (), err.code);
			}
		}

		/**
		 * Bind a callback to a given method and regular expression.
		 *
		 * The providen regular expression pattern will be extracted, scoped,
		 * anchored and optimized. This means you must not anchor the regex yourself
		 * with '^' and '$' characters and providing a pre-optimized {@link GLib.Regex}
		 * is useless.
		 *
		 * The method will be marked as provided with the {@link Valum.Method.PROVIDED}
		 * flag.
		 *
		 * @param method flag for allowed HTTP methods
		 * @param regex  regular expression matching the request path
		 * @param cb     callback used to process the pair of request and response
		 */
		[Version (since = "0.1")]
		public void regex (Method method, Regex regex, owned HandlerCallback cb) {
			var pattern = new StringBuilder ();

			pattern.append ("^");

			// scope the route
			foreach (var scope in scopes.head) {
				pattern.append (Regex.escape_string (scope));
			}

			pattern.append (regex.get_pattern ());

			pattern.append ("$");

			try {
				route (new RegexRoute (method | Method.PROVIDED, new Regex (pattern.str, RegexCompileFlags.OPTIMIZE), (owned) cb));
			} catch (RegexError err) {
				error ("%s (%s, %d)", err.message, err.domain.to_string (), err.code);
			}
		}

		/**
		 * Bind a callback to a given method and path.
		 *
		 * While {@link Valum.Router.rule} can be as well used for exact path
		 * matches, this helper is more efficient as it does rely on regex
		 * matching under the hood.
		 *
		 * @param method  flag for allowed HTTP methods
		 * @param path    the path which must be satisfied by the request
		 * @param handler callback applied on the pair of request and response
		 *                objects if the method and path are satisfied
		 */
		[Version (since = "0.3")]
		public void path (Method method, string path, owned HandlerCallback handler, string? name = null) {
			var path_builder = new StringBuilder ();

			foreach (var scope in scopes.head) {
				path_builder.append (scope);
			}

			path_builder.append (path);

			route (new PathRoute (method | Method.PROVIDED, path_builder.str, (owned) handler), name);
		}

		/**
		 * Bind a callback to a given method and a matcher callback.
		 *
		 * The method will be marked as provided with the {@link Valum.Method.PROVIDED}
		 * flag.
		 *
		 * @param method  HTTP method or 'null' for any
		 * @param matcher callback used to match the request
		 * @param cb      callback used to process the pair of request and response.
		 */
		[Version (since = "0.1")]
		public void matcher (Method method, owned MatcherCallback matcher, owned HandlerCallback cb) {
			route (new MatcherRoute (method | Method.PROVIDED, (owned) matcher, (owned) cb));
		}

		private HashTable<string, Route> _named_routes = new HashTable<string, Route> (str_hash, str_equal);

		/**
		 * Append a {@link Route} object on the routing sequence.
		 *
		 * @param route an instance of Route defining the matching process and
		 *              the callback.
		 */
		[Version (since = "0.3")]
		public void route (Route route, string? name = null) {
			routes.append (route);
			if (name != null) {
				_named_routes.insert (name, route);
			}
		}

		/**
		 * Reverse an URL for a named {@link Valum.Route}.
		 *
		 * @param name
		 * @param ...  parameters for the {@link Valum.Route.to_url} call
		 *
		 * @return 'null' if the route is not found otherwise the return value
		 *         of {@link Valum.Route.to_url}
		 */
		[Version (since = "0.3")]
		public string url_for_hash (string name, HashTable<string, string>? @params = null) {
			if (!_named_routes.contains (name)) {
				error ("No such route named '%s'.", name);
			}
			return _named_routes.lookup (name).to_url_from_hash (@params);
		}

		/**
		 * Reverse an URL for a named {@link Valum.Route} using a varidic
		 * arguments list.
		 */
		[Version (since = "0.3")]
		public string url_for_valist (string name, va_list list) {
			if (!_named_routes.contains (name)) {
				error ("No such route named '%s'.", name);
			}
			return _named_routes.lookup (name).to_url_from_valist (list);
		}

		/**
		 * Reverse an URL for a named {@link Valum.Route} using varidic
		 * arguments.
		 */
		[Version (since = "0.3")]
		public string url_for (string name, ...) {
			return url_for_valist (name, va_list ());
		}

		/**
		 * Add a fragment to the scope stack and nest a router in this new
		 * environment.
		 *
		 * Scoping will only work with rules and regular expressions.
		 *
		 * @param fragment fragment to push on the scopes stack
		 * @param loader   nests a router in the new scoped environment
		 */
		[Version (since = "0.1")]
		public void scope (string fragment, owned LoaderCallback loader) {
			this.scopes.push_tail (fragment);
			loader (this);
			this.scopes.pop_tail ();
		}

		/**
		 * Perform the routing given a specific sequence of routes.
		 *
		 * @param routes  sequence of routes to traverse
		 * @param req     request
		 * @param res     response
		 * @param next    invoked when all the routes has been traversed without
		 *                success
		 * @param context routing context passed to match and fire
		 *
		 * @return 'true' if any of the route's matcher in the sequence has
		 *         matched, otherwise the result of the 'next' continuation
		 */
		private bool perform_routing (SequenceIter<Route> routes,
		                              Request req,
		                              Response res,
		                              NextCallback next,
		                              Context context) throws Informational,
		                                                      Success,
		                                                      Redirection,
		                                                      ClientError,
		                                                      ServerError,
		                                                      Error {
			for (SequenceIter<Route> node = routes; !node.is_end (); node = node.next ()) {
				var req_method = Method.from_string (req.headers.get_one ("X-Http-Method-Override") ?? req.method);
				var local_context = new Context.with_parent (context);
				if (req_method in node.@get ().method && node.@get ().match (req, local_context)) {
					return node.@get ().fire (req, res, () => {
						// keep routing if there are more routes to explore
						if (node.next ().is_end ()) {
							return next ();
						} else {
							return perform_routing (node.next (), req, res, next, local_context);
						}
					}, local_context);
				}
			}
			return next ();
		}

		/**
		 * Perform the routing of a pair of request and response objects.
		 *
		 * If the request method is {@link VSGI.Request.TRACE}, a
		 * representation of the request will be produced in the response.
		 *
		 * If nothing matches, the one of the following error will be thrown at
		 * the bottom of the routing:
		 *
		 * * a {@link Valum.ClientError.METHOD_NOT_ALLOWED} if alternate methods exist
		 * * a {@link Valum.ClientError.NOT_FOUND} otherwise
		 *
		 * If the request method is {@link VSGI.Request.OPTIONS}, a success
		 * message will be produced with the 'Allow' header set accordingly. No
		 * error will be thrown.
		 *
		 * Parameters and return values are complying with {@link VSGI.ApplicationCallback}
		 * and meant to be used as such.
		 */
		[Version (since = "0.1")]
		public bool handle (Request req, Response res) throws Error {
			return perform_routing (this.routes.get_begin_iter (), req, res, () => {
				if (req.method == Request.TRACE) {
					var head = new StringBuilder ();

					head.append_printf ("%s %s HTTP/%s\r\n", req.method,
					                                         req.uri.to_string (true),
					                                         req.http_version == Soup.HTTPVersion.@1_0 ? "1.0" : "1.1");

					req.headers.@foreach ((name, header) => {
						head.append_printf ("%s: %s\r\n", name, header);
					});

					head.append ("\r\n");

					res.status = Soup.Status.OK;
					res.headers.set_content_type ("message/http", null);
					return res.expand_utf8 (head.str);
				}

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

					// always provided methods
					allowed |= Method.TRACE;

					do {
						unowned FlagsValue flags_value = method_class.get_first_value (allowed);
						allowed  &= ~flags_value.@value;
						allowedv += flags_value.value_nick == "only-get" ? "GET" : flags_value.value_nick.up ();
					} while (allowed > 0);

					if (req.method == Request.OPTIONS) {
						res.status = Soup.Status.OK;
						res.headers.append ("Allow", string.joinv (", ", allowedv));
						return res.expand_utf8 (""); // result in 'Content-Length: 0' as specified
					}

					else {
						throw new ClientError.METHOD_NOT_ALLOWED (string.joinv (", ", allowedv));
					}
				}

				throw new ClientError.NOT_FOUND ("The request URI '%s' was not found.", req.uri.to_string (true));
			}, new Context.with_parent (context));
		}
	}
}
