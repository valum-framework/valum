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

/**
 * Utilities to serve static resources.
 *
 * @since 0.3
 */
[CCode (gir_namespace = "Valum.Static", gir_version = "0.3")]
namespace Valum.Static {

	/**
	 * Flags used to enble or disable options for serving static resources.
	 *
	 * @since 0.3
	 */
	[Flags]
	public enum ServeFlags {
		/**
		 * Produce a 'ETag' header and raise {@link Valum.Redirection.NOT_MODIFIED}
		 * if the resource has already been transmitte.
		 *
		 * @since 0.3
		 */
		ETAG,
		/**
		 * Sane defaults for serving files and resources.
		 *
		 * @since 0.3
		 */
		DEFAULT = ETAG
	}

	/**
	 * Serve static files relative to a given root.
	 *
	 * The path to relative to the root is expected on the top of the routing
	 * stack.
	 *
	 * The path can be local or remote given that GVFS can be used.
	 *
	 * The 'ETag' header is obtained from {@link GLib.FileAttribute.ETAG_VALUE}.
	 *
	 * If the file is not found, the request is delegated to the next
	 * middleware.
	 *
	 * @since 0.3
	 *
	 * @param root        path from which resources are resolved
	 * @param serve_flags
	 */
	public HandlerCallback serve_from_path (File root, ServeFlags serve_flags = ServeFlags.DEFAULT) {
		return (req, res, next, stack) => {
			var file = root.resolve_relative_path (stack.pop_tail ().get_string ());

			try {
				if (ServeFlags.ETAG in serve_flags) {
					var etag = "\"%s\"".printf (file.query_info (FileAttribute.ETAG_VALUE,
					                                             FileQueryInfoFlags.NONE).get_etag ());

					res.headers.replace ("ETag", etag);

					if (etag == req.headers.get_one ("If-None-Match"))
						throw new Redirection.NOT_MODIFIED ("");
				}

				var file_read_stream = file.read ();

				// read 128 bytes for the content-type guess
				var contents = new uint8[128];
				file_read_stream.read_all (contents, null);

				// reposition the stream
				file_read_stream.seek (0, SeekType.SET);

				bool uncertain;
				res.headers.set_content_type (ContentType.guess (file.get_path (), contents, out uncertain), null);

				if (uncertain)
					warning ("could not infer content type of file '%s' with certainty", file.get_path ());

				// transfer the file
				res.body.splice_async.begin (file_read_stream,
						OutputStreamSpliceFlags.CLOSE_SOURCE | OutputStreamSpliceFlags.CLOSE_TARGET,
						Priority.DEFAULT,
						null,
				        (obj, result) => {
							try {
								res.body.splice_async.end (result);
							} catch (IOError ioe) {
								warning ("could not serve file '%s'", file.get_path ());
							}
				});
			} catch (FileError.NOENT fe) {
				next (req, res);
			}
		};
	}

	/**
	 * Serve files from a {@link GLib.Resource} bundle.
	 *
	 * The 'ETag' header is obtained from a SHA1 checksum.
	 *
	 * [[http://valadoc.org/#!api=gio-2.0/GLib.Resource]]
	 *
	 * @see Valum.Static.serve_from_path
	 * @see GLib.resources_open_stream
	 * @see GLib.resources_lookup_data
	 *
	 * @since 0.3
	 *
	 * @param resourcea   resource bundle to serve or the global one if null
	 * @param prefix      prefix from which resources are resolved in the
	 *                    resource bundle; a valid prefix begin and start with a
	 *                    '/' character
	 * @param serve_flags
	 */
	public HandlerCallback serve_from_resource (Resource? resource = null,
	                                            string prefix = "/",
												ServeFlags serve_flags = ServeFlags.DEFAULT) {
		// cache for already computed 'ETag' values
		var etag_cache = new HashTable <string, string> (str_hash, str_equal);

		return (req, res, next, stack) => {
			var path = "%s%s".printf (prefix, stack.pop_tail ().get_string ());

			var lookup = resource == null ?
				resources_lookup_data (path, ResourceLookupFlags.NONE) :
				resource.lookup_data (path, ResourceLookupFlags.NONE);

			if (ServeFlags.ETAG in serve_flags) {
				var etag = path in etag_cache ?
					etag_cache[path] :
					"\"%s\"".printf (Checksum.compute_for_bytes (ChecksumType.SHA1, lookup));

				etag_cache[path] = etag;

				res.headers.replace ("ETag", etag);

				if (etag == req.headers.get_one ("If-None-Match"))
					throw new Redirection.NOT_MODIFIED ("");
			}

			// set the content-type based on a good guess
			bool uncertain;
			res.headers.set_content_type (ContentType.guess (path, lookup.get_data (), out uncertain), null);
			res.headers.set_content_length (lookup.get_size ());

			if (uncertain)
				warning ("could not infer content type of file '%s' with certainty", path);

			var file = resource == null ?
				resources_open_stream (path, ResourceLookupFlags.NONE) :
				resource.open_stream (path, ResourceLookupFlags.NONE);

			// transfer the file
			res.body.splice_async.begin (file,
					OutputStreamSpliceFlags.CLOSE_SOURCE | OutputStreamSpliceFlags.CLOSE_TARGET,
					Priority.DEFAULT,
					null,
					(obj, result) => {
						try {
							res.body.splice_async.end (result);
						} catch (IOError ioe) {
							warning ("could not serve static resource '%s'", path);
						}
			});
		};
	}
}
