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

/**
 * Loader for VSGI-compliant application written as GModule.
 *
 * The only requirement is to provide a {@link VSGI.ApplicationCallback}
 * compatible symbol in the shared library.
 *
 * Only active implementations like {@link VSGI.Soup}, {@link VSGI.SCGI} and
 * {@link VSGI.FastCGI} are supported.
 *
 * @since 0.3
 */
namespace VSGI {

	private string? directory;
	private string  server;
	private bool    live_reload;

	private const OptionEntry[] options = {
		{"directory",   'd', 0, OptionArg.FILENAME, ref directory,   "Directory used to resolve MODULE"},
		{"server",      'i', 0, OptionArg.STRING,   ref server,      "VSGI server implementation to use", "http"},
		{"live-reload", 'r', 0, OptionArg.NONE,     ref live_reload, "Enable live reloading"},
		{null}
	};

	public int main (string[] args) {
		// default options
		directory   = null;
		server      = "http";
		live_reload = false;

		try {
			var parser = new OptionContext ("MODULE [-- SERVER_OPTION...]");
			parser.set_summary ("Load a VSGI application written as a GModule and serve it using a supported\n" +
					            "technology.\n" +
								"\n" +
								"Only active server technologies such as libsoup-2.4, FastCGI and SCGI are \n" +
								"supported for the '--server' option. They correspond to 'http', 'fastcgi' and\n" +
								"'scgi' values respectively.\n" +
								"\n" +
								"MODULE is the shared library name without the 'lib' prefix and extension suffix.\n" +
								"\n" +
								"SERVER_OPTION is forwarded to the server and must be separated from other\n" +
								"arguments by a '--' delimiter.");
			parser.add_main_entries (options, null);
			parser.parse (ref args);
		} catch (OptionError err) {
			stderr.printf ("%s, specify '--help' for all available options.\n", err.message);
			return 1;
		}

		// count the remaining arguments once parsed
		if (args.length < 2) {
			stderr.printf ("Module is missing, specify '--help' for detailed usage.\n");
			return 1;
		}

		if (!Module.supported ()) {
			stderr.printf ("Loading modules is not supported.");
			return 1;
		}

		var app_module = new HandlerModule (directory, args[1]);

		if (!app_module.load ()) {
			stderr.printf ("Could not load the handler module.");
			return 1;
		}

		// use the module:symbol as zeroth argument
		string[] server_args = {args[1]};

		// append args following the '--'
		if (args.length > 2 && args[2] == "--")
			foreach (var arg in args[3:args.length])
				server_args += arg;

		var server = Server.new (server);

		try {
			if (app_module.handler_type.is_a (typeof (Initable))) {
				server.handler = Initable.new (app_module.handler_type) as Handler;
			} else {
				server.handler = Object.new (app_module.handler_type) as Handler;
			}
		} catch (Error err) {
			stderr.printf ("Could not initialize the handler: %s (%s, %d).", err.message,
			                                                                 err.domain.to_string (),
			                                                                 err.code);
			return 1;
		}

		if (live_reload) {
			try {
				// setup live reloading
				var file    = File.new_for_path (app_module.path);
				var monitor = file.monitor(FileMonitorFlags.NONE);

				Idle.add (() => {
					message ("Monitoring '%s'...", file.get_path ());
					monitor.changed.connect ((a, b, event) => {
						if (event == FileMonitorEvent.CHANGES_DONE_HINT) {
							message ("Reloading '%s'...", file.get_path ());
							app_module.unload ();
							if (app_module.load ()) {
								try {
									if (app_module.handler_type.is_a (typeof (Initable))) {
										server.handler = Initable.new (app_module.handler_type) as Handler;
									} else {
										server.handler = Object.new (app_module.handler_type) as Handler;
									}
									message ("Reloaded '%s'.", file.get_path ());
								} catch (Error err) {
									critical ("Could not initialize the reloaded handler: %s (%s, %d).", err.message,
									                                                                     err.domain.to_string (),
									                                                                     err.code);
								}
							} else {
								critical ("Could not reload the handler.");
							}
						}
					});
					return false;
				});
			} catch (Error err) {
				stderr.printf ("Could not setup live reloading: %s.", err.message);
				return 1;
			}
		}

		return server.run (server_args);
	}
}
