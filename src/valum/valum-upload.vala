using GLib;
using VSGI;

namespace Valum {

	/**
	 * @since 0.3
	 */
	public enum UploadFlags {
		/**
		 * @since 0.3
		 */
		NONE,
		/**
		 * @since 0.3
		 */
		ASYNC
	}

	/**
	 * @since 0.3
	 */
	public delegate void UploadCompleteCallback (Request req,
	                                             Response res,
	                                             NextCallback next,
	                                             Context ctx,
	                                             File uploaded_file);

	/**
	 *
	 */
	public HandlerCallback upload (File dest, UploadCompleteCallback upload_complete, UploadFlags flags) {
		return (req, res, next, ctx) => {
			string disposition;
			HashTable<string, string> @params;
			req.headers.get_content_disposition (out disposition, out @params);

			var file = dest.resolve_relative_path (@params["filename"] ?? ""); // TODO: guess filename

			if (UploadFlags.ASYNC in flags) {
				file.create_async.begin (FileCreateFlags.REPLACE_DESTINATION,
				                         Priority.DEFAULT,
				                         null,
				                         (obj, result) => {
						var @out = file.create_async.end (result);
						@out.splice_async.begin (req.body,
						                         OutputStreamSpliceFlags.CLOSE_TARGET,
						                         Priority.DEFAULT,
												 null, (obj, result) => {
							@out.splice_async.end (result);
							upload_complete (req, res, next, ctx, file);
						});
					});
			} else {
				dest.create (FileCreateFlags.REPLACE_DESTINATION, null).splice (req.body,
                                                                                OutputStreamSpliceFlags.CLOSE_TARGET);
				upload_complete (req, res, next, ctx, file);
			}
		};
	}
}
