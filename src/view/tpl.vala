using Gee;
using Soup;

namespace Valum {
	// Use Soup MessageBody as OutputStream
	public class MessageBodyOutputStream : OutputStream {

		public MessageBody body { construct; get; }

		public MessageBodyOutputStream(MessageBody body) {
			Object(body: body);
		}

		public override bool close(Cancellable? cancellable = null) {
			this.body.complete();
			return true;
		}

		public override ssize_t write(uint8[] buffer, Cancellable? cancellable = null) {
			this.body.append_take(buffer);
			return buffer.length;
		}
	}
	namespace View {
		public class Tpl : View {

			private unowned Ctpl.Token tree;

			public Tpl.from_path(string path) {
				try {
					this.tree = Ctpl.lexer_lex_path(path);
				} catch (Error e) {
					error(e.message);
				}
			}

			public Tpl.from_string(string template) {
				try {
					this.tree = Ctpl.lexer_lex_string(template);
				} catch(Error e) {
					error(e.message);
				}
			}

			public override string render () {
				try {
					var mem_stream = new MemoryOutputStream (null, realloc, free);
					var output = new Ctpl.OutputStream (mem_stream);

					try {
						var env = prepare_environment(this.vars);
						Ctpl.parser_parse(this.tree, env, output);
					} catch (Error e) {
						return e.message;
					}

					return (string) mem_stream.get_data();
				} catch (Error e) {
					warning(e.message);
					return e.message;
				}
			}

			// stream the template in the given OutputStream
			public void stream (OutputStream stream) {
				var output = new Ctpl.OutputStream (stream);

				var env = prepare_environment(this.vars);

				Ctpl.parser_parse(this.tree, env, output);
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
							warning("Cannot create env var of type %s", e.value.type_name());
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
