using Lua;

namespace Valum {
	namespace Script {
		public class Lua {
			private LuaVM vm;

			public Lua() {
				this.vm = new LuaVM ();
				this.vm.open_libs ();
			}

			// Eval lua `code` and cast result to string
			public string eval (string code) {
				this.vm.do_string(code);
				return this.vm.to_string(-1);
			}

			// Eval lua file and cast result to string
			public string run (string filename) {
				this.vm.do_file(filename); // TODO: Conventions!
				return this.vm.to_string(-1);
			}
		}
	}
}
