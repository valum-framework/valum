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
	 * Describe a matching and handling process for a pair of {@link VSGI.Request}
	 * and {@link VSGI.Response} objects.
	 *
	 * It holds metadata as well to optimize the routing process.
	 */
	[Version (since = "0.1")]
	public abstract class Route : Middleware {

		/**
		 * Flag describing allowed HTTP methods.
		 */
		[Version (since = "0.2")]
		public Method method { construct; get; }

		/**
		 * Matches the given request and populate its parameters on success.
		 */
		[Version (since = "0.1")]
		public abstract bool match (Request req, Context ctx);

		private HandlerCallback _handler = null;

		[Version (since = "0.4")]
		public void set_handler_callback (owned HandlerCallback handler)
		{
			_handler = (owned) handler;
		}

		/**
		 * Apply the handler on the pair of {@link VSGI.Request} and {@link VSGI.Response}
		 * objects if the route match, otherwise invoke the {@link NextCallback}.
		 *
		 * @return the return value of either the handler callback or the next
		 *         callback depending on the match
		 */
		[Version (since = "0.1")]
		public override bool fire (Request req, Response res, NextCallback next, Context ctx) throws Success,
		                                                                                             Redirection,
		                                                                                             ClientError,
		                                                                                             ServerError,
		                                                                                             Error
		{
			if (match (req, ctx) && unlikely (_handler != null)) {
				return _handler (req, res, next, ctx);
			} else {
				return next ();
			}
		}

		/**
		 * Reverse the route into an URL.
		 *
		 * @param params parameters which are typically extract from the
		 *               {@link VSGI.Request.uri} property
		 *
		 * @return the corresponding URL if supported, otherwise 'null'
		 */
		[Version (since = "0.3")]
		public abstract string to_url_from_hash (HashTable<string, string>? @params = null);

		/**
		 * Reverse the route into an URL by building from a varidic arguments
		 * list.
		 */
		[Version (since = "0.3")]
		public string to_url_from_valist (va_list list) {
			var hash = new HashTable<string, string> (str_hash, str_equal);
			// potential compiler bug here: SEGFAULT if 'var' is used instead of 'unowned string'
			for (unowned string key = list.arg<string> (), val = list.arg<string> ();
				key != null && val != null;
				key = list.arg<string> (), val = list.arg<string> ()) {
				hash.insert (key.replace ("-", "_"), val);
			}
			return to_url_from_hash (hash);
		}

		/**
		 * Reverse the route into an URL using varidic arguments.
		 *
		 * Arguments alternate between keys and values, all assumed to be
		 * {@link string}.
		 */
		[Version (since = "0.3")]
		public string to_url (...) {
			return to_url_from_valist (va_list ());
		}
	}
}
