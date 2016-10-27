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
 * Load custom {@link VSGI.Handler} implementations.
 */
[Version (since = "0.3")]
public class VSGI.HandlerModule : TypeModule {

	/**
	 * The directory from which the shared library will be searched, or 'null'
	 * to search in standard locations.
	 */
	[Version (since = "0.3")]
	public string? directory { construct; get; }

	/**
	 * The name of the server implementation.
	 */
	[Version (since = "0.3")]
	public string name { construct; get; }

	/**
	 * Path from which the module is loaded.
	 */
	[Version (since = "0.3")]
	public string path { construct; get; }

	/**
	 * Once loaded, this contain the type of the {@link VSGI.Handler} provided
	 * by this.
	 */
	[Version (since = "0.3")]
	public Type handler_type { get; private set; }

	private Module? module;

	[Version (since = "0.3")]
	public HandlerModule (string? directory, string name) {
		Object (directory: directory, name: name);
	}

	construct {
		path = Module.build_path (directory, name);
	}

	public override bool load () {
		module = Module.open (path, ModuleFlags.BIND_LAZY);

		if (module == null) {
			critical (Module.error ());
			return false;
		}

		void* func;
		if (!module.symbol ("handler_init", out func)) {
			critical (Module.error ());
			return false;
		}

		if (func == null) {
			critical ("No registration function was found in '%s'.", path);
			return false;
		}

		handler_type = ((HandlerInitFunc) func) (this);

		if (!handler_type.is_a (typeof (Handler))) {
			critical ("The registration function must return a type derived from '%s'",
			          typeof (Handler).name ());
			return false;
		}

		return true;
	}

	public override void unload () {
		module = null;
	}
}
