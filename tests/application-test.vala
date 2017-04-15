using GLib;
using VSGI;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/application", () => {
		if (Test.subprocess ()) {
			var app = new VSGI.Application (Server.new ("http"));

			Idle.add (() => {
				app.quit ();
				return false;
			});

			app.run ();

			return;
		}

		Test.trap_subprocess (null, 0, 0);
		Test.trap_assert_passed ();
		Test.trap_assert_stderr ("*Listening on 'http://127.0.0.1:3003/'.*");
	});

#if GLIB_2_50 || LIBSYSTEMD
	Test.add_func ("/application/log-writer/journald", () => {
		if (Test.subprocess ()) {
			var app = new VSGI.Application (Server.new ("http"));

			Idle.add (() => {
				app.quit ();
				return false;
			});

			app.run ({"app", "--log-writer", "journald"});

			return;
		}

		Test.trap_subprocess (null, 0, 0);
		Test.trap_assert_passed ();
		Test.trap_assert_stderr ("");
	});
#endif

	return Test.run ();
}
