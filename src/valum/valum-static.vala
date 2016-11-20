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
 */
[CCode (gir_namespace = "Valum", gir_version = "0.3")]
namespace Valum.Static {

	/**
	 * Flags used to enble or disable options for serving static resources.
	 */
	[Flags]
	[Version (since = "0.3")]
	public enum ServeFlags {
		[Version (since = "0.3")]
		NONE,
		/**
		 * Produce an 'ETag' header and raise a {@link Valum.Redirection.NOT_MODIFIED}
		 * if the resource has already been transmitted. If not available, it
		 * will fallback on either {@link Valum.Static.ServeFlags.ENABLE_LAST_MODIFIED}
		 * or no caching at all.
		 */
		[Version (since = "0.3")]
		ENABLE_ETAG,
		/**
		 * Produce a 'Last-Modified' header and raise a {@link Valum.Redirection.NOT_MODIFIED}
		 * if the resource has already been transmitted.
		 *
		 * If {@link Valum.Static.ServeFlags.ENABLE_ETAG} is specified and available,
		 * it will be used instead.
		 */
		[Version (since = "0.3")]
		ENABLE_LAST_MODIFIED,
		/**
		 * Raise a {@link ClientError.FORBIDDEN} if rights are missing on the
		 * resource rather than calling 'next'.
		 */
		[Version (since = "0.3")]
		FORBID_ON_MISSING_RIGHTS,
		/**
		 * If supported, generate a 'X-Sendfile' header instead of delivering
		 * the actual resource in the response body.
		 *
		 * The absolute path as provided by {@link GLib.File.get_path} will be
		 * produced in the 'X-Sendfile' header. It must therefore be accessible
		 * for the HTTP server, otherwise it will silently fallback to serve the
		 * resource directly.
		 */
		[Version (experimental = true)]
		X_SENDFILE
	}

	/**
	 * Serve static files relative to a given root.
	 *
	 * The path to relative to the root is expected to be associated to the
	 * 'path' key in the routing context.
	 *
	 * The path can be local or remote given that GVFS can be used.
	 *
	 * The 'ETag' header is obtained from {@link GLib.FileAttribute.ETAG_VALUE}.
	 *
	 * If the file is not found, the request is delegated to the next
	 * middleware.
	 *
	 * If the file is not readable, a '403 Forbidden' is raised.
	 *
	 * @param root        path from which resources are resolved
	 * @param serve_flags flags for serving the resources
	 */
	[Version (since = "0.3")]
	public HandlerCallback serve_from_file (File root, ServeFlags serve_flags = ServeFlags.NONE, ForwardCallback<GLib.File> forward = Valum.forward) {
		return (req, res, next, ctx) => {
			var file = root.resolve_relative_path (ctx["path"].get_string ());

			try {
				var file_info = file.query_info ("%s,%s,%s".printf (FileAttribute.ETAG_VALUE,
				                                                    FileAttribute.TIME_MODIFIED,
				                                                    FileAttribute.STANDARD_SIZE),
				                                 FileQueryInfoFlags.NONE);

				var etag          = file_info.get_etag ();
				var last_modified = file_info.get_modification_time ();

				if (etag != null && ServeFlags.ENABLE_ETAG in serve_flags) {
					if (etag == req.headers.get_one ("If-None-Match"))
						throw new Redirection.NOT_MODIFIED ("");
					res.headers.replace ("ETag", etag);
				}

				else if (last_modified.tv_sec > 0 && ServeFlags.ENABLE_LAST_MODIFIED in serve_flags) {
					var if_modified_since = req.headers.get_one ("If-Modified-Since");
					if (if_modified_since != null && new Soup.Date.from_string (if_modified_since).to_timeval ().tv_sec >= last_modified.tv_sec)
						throw new Redirection.NOT_MODIFIED ("");
					res.headers.replace ("Last-Modified", new Soup.Date.from_time_t (last_modified.tv_sec).to_string (Soup.DateFormat.HTTP));
				}

				var file_read_stream = file.read ();

				// read 128 bytes for the content-type guess
				var contents = new uint8[128];
				file_read_stream.read_all (contents, null);

				// reposition the stream
				file_read_stream.seek (0, SeekType.SET);

				bool uncertain;
				res.headers.set_content_type (ContentType.guess (file.get_basename (), contents, out uncertain), null);
				if (res.headers.get_list ("Content-Encoding") == null)
					res.headers.set_content_length (file_info.get_size ());

				if (uncertain) {
					res.headers.append ("Warning", "%u, %s, \"%s\", \"%s\"".printf (199,
					                                                                req.uri.host + (req.uri.uses_default_port () ? "" : ":" + req.uri.port.to_string ()),
					                                                                "The 'Content-Type' header could not be infered with certainty.",
					                                                                new Soup.Date.from_now (0).to_string (Soup.DateFormat.HTTP)));
				}

				return forward (req, res, () => {
					if (ServeFlags.X_SENDFILE in serve_flags && file.get_path () != null) {
						res.headers.set_encoding (Soup.Encoding.NONE);
						res.headers.replace ("X-Sendfile", file.get_path ());
						return res.end ();
					}

					if (req.method == Request.HEAD)
						return res.end ();

					return res.expand_stream (file_read_stream);
				}, ctx, file);
			} catch (FileError.ACCES fe) {
				if (ServeFlags.FORBID_ON_MISSING_RIGHTS in serve_flags) {
					throw new ClientError.FORBIDDEN ("You cannot access this resource.");
				} else {
					return next ();
				}

			} catch (IOError.NOT_FOUND ioe) {
				return next ();
			} catch (FileError.NOENT fe) {
				return next ();
			}
		};
	}

	[Version (since = "0.3")]
	public HandlerCallback serve_from_path (string                      path,
	                                        ServeFlags                  serve_flags = ServeFlags.NONE,
	                                        owned ForwardCallback<File> forward     = Valum.forward) {
		return serve_from_file (File.new_for_path (path), serve_flags, (owned) forward);
	}

	[Version (since = "0.3")]
	public HandlerCallback serve_from_uri (string                      uri,
	                                       ServeFlags                  serve_flags = ServeFlags.NONE,
	                                       owned ForwardCallback<File> forward     = Valum.forward) {
		return serve_from_file (File.new_for_uri (uri), serve_flags, (owned) forward);
	}

	/**
	 * Serve files from the provided {@link GLib.Resource} bundle.
	 *
	 * The 'ETag' header is obtained from a SHA1 checksum.
	 *
	 * [[http://valadoc.org/#!api=gio-2.0/GLib.Resource]]
	 *
	 * @see Valum.Static.serve_from_file
	 * @see GLib.resources_open_stream
	 * @see GLib.resources_lookup_data
	 *
	 * @param resource    resource bundle to serve
	 * @param prefix      prefix from which resources are resolved in the
	 *                    resource bundle; a valid prefix begin and start with a
	 *                    '/' character
	 * @param serve_flags flags for serving the resources
	 */
	[Version (since = "0.3")]
	public HandlerCallback serve_from_resource (Resource              resource,
	                                            string                prefix      = "/",
	                                            ServeFlags            serve_flags = ServeFlags.NONE,
	                                            owned HandlerCallback forward     = Valum.forward) {
		// cache for already computed 'ETag' values
		var etag_cache = new HashTable <string, string> (str_hash, str_equal);

		return (req, res, next, ctx) => {
			var path = "%s%s".printf (prefix, ctx["path"].get_string ());

			Bytes lookup;
			try {
				lookup = resource.lookup_data (path, ResourceLookupFlags.NONE);
			} catch (Error err) {
				return next ();
			}

			if (ServeFlags.ENABLE_ETAG in serve_flags) {
				var etag = path in etag_cache ?
					etag_cache[path] :
					"\"%s\"".printf (Checksum.compute_for_bytes (ChecksumType.SHA1, lookup));

				etag_cache[path] = etag;

				if (etag == req.headers.get_one ("If-None-Match"))
					throw new Redirection.NOT_MODIFIED ("");

				res.headers.replace ("ETag", etag);
			}

			// set the content-type based on a good guess
			bool uncertain;
			res.headers.set_content_type (ContentType.guess (path, lookup.get_data (), out uncertain), null);
			if (res.headers.get_list ("Content-Encoding") == null)
				res.headers.set_content_length (lookup.get_size ());

			if (uncertain) {
				res.headers.append ("Warning", "%u, %s, \"%s\", \"%s\"".printf (199,
				                                                                req.uri.host + (req.uri.uses_default_port () ? "" : ":" + req.uri.port.to_string ()),
				                                                                "The 'Content-Type' header could not be infered with certainty.",
				                                                                new Soup.Date.from_now (0).to_string (Soup.DateFormat.HTTP)));
			}

			return forward (req, res, () => {
				if (req.method == Request.HEAD)
					return res.end ();

				// transfer the file
				return res.expand_stream (resource.open_stream (path, ResourceLookupFlags.NONE));
			}, ctx);
		};
	}
}
