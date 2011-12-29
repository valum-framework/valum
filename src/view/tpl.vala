using Gee;

namespace Valum {
	namespace View {
		public class Tpl : Object, IView {

			public string path { get; set; }
			public unowned Ctpl.Token tree;

			public Tpl() {
				this.tree = null;
			}

			public void read(string? path) {
				string output = "";
				ulong len = 0;
				try {
					FileUtils.get_contents(path, out output, out len);
				} catch (FileError e) {
					print(e.message);
				}
			}

			public void from_string(string template) {
				try {
					this.tree = Ctpl.lexer_lex_string(template);
				} catch(Error e) {
					print(e.message);
				}
			}

			public string? render(HashMap<string, Value?>? vars) {
				try {
					var mem_stream = new MemoryOutputStream (null, realloc, free);
					var output = new Ctpl.OutputStream (mem_stream);

					try {
						var env = prepare_environment(vars);
						Ctpl.parser_parse(this.tree, env, output);
					} catch (Error e) {
						print(e.message);
						return null;
					}

					return (string) mem_stream.get_data();
				} catch (Error e) {
					print(e.message);
					return null;
				}
			}

			private Ctpl.Environ prepare_environment(HashMap<string, Value?>? vars) {
				var env = new Ctpl.Environ();

				foreach (var e in vars.entries) {
					switch (e.value.type_name()) {
					case "gchararray":
						var val = new Ctpl.Value();
						val.set_string((string) e.value);
						env.push((string) e.key, val);
						break;
					case "GeeArrayList":
						var val = array_list_to_ctpl_value ((ArrayList<Value?>) e.value);
						env.push((string) e.key, val);
						break;
					default:
						// message("Cannot create env var of type %s", e.value.type_name());
						break;
					}
				}

				return env;
			}

			private Ctpl.Value array_list_to_ctpl_value(ArrayList<Value?> arr) {
				var val = new Ctpl.Value();
				// FIXME: need a way to set value type to array without passing va_list
				// TODO: notify upstream
				// https://live.gnome.org/GObjectIntrospection/WritingBindingableAPIs
				message("%d", arr.size);
				val.set_array(Ctpl.ValueType.STRING, arr.size, "");
				foreach (Value v in arr) {
					val.array_append_string((string) v);
					// message("%s", (string) v);
				}
				return val;
			}

		}
	}
}
