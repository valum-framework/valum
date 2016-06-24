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
		 * Global routing context.
		 *
		 * @since 0.3
		 */
		public Context context { get; construct; default = new Context (); }

		/**
		 * Sequence of {@link Valum.Route} object defining this.
		 *
		 * @since 0.3
		 */
		public Sequence<Route> routes { get; owned construct; }

		private HashTable<string, Regex> types  = new HashTable<string, Regex> (str_hash, str_equal);
		private Queue<string>            scopes = new Queue<string>   ();

		construct {
			context = new Context (); // FIXME: the property should only be initialized in 'default'
			routes  = new Sequence<Route> ();
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
		 */
		public void register_type (string name, Regex pattern) {
			types[name] = pattern;
		}

		/**
		 * Mount a handling middleware on the routing queue.
		 *
		 * @since 0.3
		 */
		public void use (owned HandlerCallback cb) {
			route (new MatcherRoute (Method.ANY, () => { return true; }, (owned) cb));
		}

		/**
		 * Bind a callback to handle asterisk '*'.
		 *
		 * Typically, this is used with {@link Valum.Method.OPTIONS} to provide
		 * general information about the service.
		 *
		 * @since 0.3
		 */
		public void asterisk (Method method, owned HandlerCallback cb) {
			route (new AsteriskRoute (method, (owned) cb));
		}

		/**
		 * @since 0.0.1
		 */
		public new void @get (string rule, owned HandlerCallback cb) {
			this.rule (Method.GET, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void post (string rule, owned HandlerCallback cb) {
			this.rule (Method.POST, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void put (string rule, owned HandlerCallback cb) {
			this.rule (Method.PUT, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void @delete (string rule, owned HandlerCallback cb) {
			this.rule (Method.DELETE, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void head (string rule, owned HandlerCallback cb) {
			this.rule (Method.HEAD, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void options (string rule, owned HandlerCallback cb) {
			this.rule (Method.OPTIONS, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public void trace (string rule, owned HandlerCallback cb) {
			this.rule (Method.TRACE, rule, (owned) cb);
		}

		/**
		 * @since 0.0.1
		 */
		public new void connect (string rule, owned HandlerCallback cb) {
			this.rule (Method.CONNECT, rule, (owned) cb);
		}

		/**
		 * [[http://tools.ietf.org/html/rfc5789]]
		 *
		 * @since 0.0.1
		 */
		public void patch (string rule, owned HandlerCallback cb) {
			this.rule (Method.PATCH, rule, (owned) cb);
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
		public void rule (Method method, string rule, owned HandlerCallback cb) {
			var pattern = new StringBuilder ();

			// scope the route
			foreach (var scope in scopes.head) {
				pattern.append (scope);
			}

			pattern.append (rule);

			try {
				route (new RuleRoute (method | Method.PROVIDED, pattern.str, types, (owned) cb));
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
		public void matcher (Method method, owned MatcherCallback matcher, owned HandlerCallback cb) {
			route (new MatcherRoute (method | Method.PROVIDED, (owned) matcher, (owned) cb));
		}

		/**
		 * Bind a {@link Route} to a custom HTTP method.
		 *
		 * @since 0.3
		 *
		 * @param route an instance of Route defining the matching process and
		 *              the callback.
		 */
		public void route (Route route) {
			this.routes.append (route);

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
		 * @param next    invoked when all the routes has been traversed without
		 *                success
		 * @param context routing context passed to match and fire
		 * @return tells if something matched during the routing process
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
		 * Perform the routing of the request by calling {@link Valum.Router.invoke}.
		 *
		 * If nothing matches the request, look for alternate HTTP methods and
		 * raise a {@link Valum.ClientError.METHOD_NOT_ALLOWED}, otherwise
		 * raise a {@link Valum.ClientError.NOT_FOUND} exception.
		 *
		 * @since 0.1
		 */
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
