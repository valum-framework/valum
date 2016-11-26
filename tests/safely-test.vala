using GLib;
using Valum;
using VSGI;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/safely/next_errors_thrown_upstream", () => {
		var req = new Request.with_method ("GET", new Soup.URI ("http://localhost/"));
		var res = new Response (req);

		try {
			safely ((req, res, next) => {
				try {
					return next ();
				} catch (Error err) {
					assert_not_reached ();
				}
			}) (req, res, () => {
				throw new IOError.FAILED ("test");
			}, new Context ());
		} catch (IOError err) {
			assert ("test" == err.message);
		} catch (Error err) {
			assert_not_reached ();
		}
	});

	return Test.run ();
}
