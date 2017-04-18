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
		 * Create the file and splice its content asynchronously.
		 *
		 * @since 0.3
		 */
		ASYNC
	}

	/**
	 * Invoked when a file has been successfully uploaded.
	 *
	 * @since 0.3
	 *
	 * @param uploaded_file
	 */
	public delegate void UploadCompleteCallback (Request req,
	                                             Response res,
	                                             NextCallback next,
	                                             Context ctx,
	                                             File uploaded_file);

	/**
	 * Upload the {@link VSGI.Request} body according to its 'Content-Disposition'
	 * header.
	 *
	 * If the 'Content-Disposition' is set to something different than 'attachement',
	 * it will be forwarded to the next middleware.
	 *
	 * If the context contains a 'filename' key, its corresponding value will be
	 * used as the name for the uploaded file.
	 *
	 * @since 0.3
	 */
	public HandlerCallback upload (File dest, UploadCompleteCallback upload_complete, UploadFlags flags) {
		return (req, res, next, ctx) => {
			string disposition;
			HashTable<string, string> @params;
			File file;
			if (req.headers.get_content_disposition (out disposition, out @params)) {
				if (!Soup.str_case_equal (disposition, "attachment")) {
					next (req, res);
					return;
				}
				file = dest.resolve_relative_path (ctx["filename"].get_string () ?? @params["filename"] ?? ""); // TODO: guess filename
			} else {
				file = dest.resolve_relative_path (ctx["filename"].get_string () ?? ""); // TODO: guess filename
			}

			// do not use 'disposition' or '@params' any further
			if (UploadFlags.ASYNC in flags) {
				file.create_async.begin (FileCreateFlags.REPLACE_DESTINATION,
										 Priority.DEFAULT,
										 null,
										 (obj, result) => {
					try {
						var @out = file.create_async.end (result);
						@out.splice_async.begin (req.body,
												 OutputStreamSpliceFlags.CLOSE_TARGET,
												 Priority.DEFAULT,
												 null, (obj, result) => {
							try {
								@out.splice_async.end (result);
								upload_complete (req, res, next, ctx, file);
							} catch (IOError err) {
								warning (err.message);
							}
						});
					} catch (Error err) {
						warning (err.message);
					}
				});
			} else {
				dest.create (FileCreateFlags.REPLACE_DESTINATION, null).splice (req.body,
                                                                                OutputStreamSpliceFlags.CLOSE_TARGET);
				upload_complete (req, res, next, ctx, file);
			}
		};
	}
}
