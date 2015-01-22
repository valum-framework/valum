using FastCGI;

namespace VSGI {

	// FastCGI implmentation
	// public class FastCGIRequest : Request {}
	// public class FastCGIResponse : Response {}

	public class FastCGIServer : VSGI.Server {

		public FastCGIServer (VSGI.Application app) {
			base (app);
		}

		public override void listen () {
			var loop = new MainLoop ();

			FastCGI.init ();

			FastCGI.request request;
			FastCGI.request.init (out request);

			var source = new TimeoutSource (0);

			source.set_callback(() => {

				message("accepting a new request...");

				// accept a new request
				var status = request.accept ();

				if (status < 0) {
					warning ("could not accept a request (code %d)", status);
					request.close ();
					loop.quit ();
					return false;
				}

				// handle the request using FastCGI handler
				var req = new VSGI.FastCGIRequest (request);
				var res = new VSGI.FastCGIResponse (request);

				this.application.handler (req, res);

				request.finish ();

				assert (request.in.is_closed);
				assert (request.out.is_closed);

				return true;
			});

			source.attach (loop.get_context ());

			loop.run ();
		}
	}
}
