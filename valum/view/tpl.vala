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

			public string? render(Gee.HashMap<string, Value?>? vars) {
				try {
					var env = new Ctpl.Environ();

					foreach (var e in vars.entries) {
						var str = "%s = \"%s\";".printf(e.key, (string)e.value);
						env.add_from_string(str);
					}

					var mem_stream = new MemoryOutputStream (null, realloc, free);
					var output = new Ctpl.OutputStream (mem_stream);

					try {
						Ctpl.parser_parse(this.tree, env, output);
					} catch (Error e) {
						print(e.message);
						return null;
					}

					return (string)mem_stream.get_data();
				} catch (Error e) {
					print(e.message);
					return null;
				}
			}
		}
	}
}
