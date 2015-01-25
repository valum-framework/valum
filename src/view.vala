using Gee;

namespace Valum {
	/**
	 *
	 */
	public class View {

		private static Ctpl.Value ctpl_value_from_value (Value? val) {
			return new Ctpl.Value ();
		}

		private unowned Ctpl.Token tree;

		/**
		 *
		 */
		public Ctpl.Environ environment = new Ctpl.Environ ();

		public View.from_path (string path) throws Error {
			this.tree = Ctpl.lexer_lex_path (path);
		}

		public View.from_string(string template) throws Error {
			this.tree = Ctpl.lexer_lex_string(template);
		}

		public void push_strings (string key, string[] val) {
			var v = new Ctpl.Value ();

			v.set_array_stringv (val.length, val);

			this.environment.push (key, v);
		}

		public void push_ints (string key, int[] val) {
			var v = new Ctpl.Value ();

			v.set_array_intv (val.length, val);

			this.environment.push (key, v);
		}

		public void push_floats (string key, float[] val) {
			var v = new Ctpl.Value ();

			v.set_array_floatv (val.length, val);

			this.environment.push (key, v);
		}

		/**
		 * Push a Gee.Collection into the environment.
		 */
		public void push_collection (string key, Collection collection) {
			var v = new Ctpl.Value ();

			this.environment.push (key, v);
		}

		/**
		 * Map are bound by composing the key with the entry key.
		 */
		public void push_map (string key, Map<string, Value?> map) {
			map.foreach((e) => {
				this.environment.push ("%s.%s".printf(key, e.key), View.ctpl_value_from_value (e.value));
				return true;
			});
		}

		/**
		 * MultiMap are bound by composing the key with the entry key and associate
		 * that value to an array.
		 */
		public void push_multimap (string key, MultiMap<string, Value?> multimap) {
			foreach (var k in multimap.get_keys ()) {
				this.push_collection ("%s.%s".printf (key, k), multimap[k]);
			}
		}

		public void push_list (string key, GLib.List lst) {
			var v = new Ctpl.Value ();

			this.environment.push (key, v);
		}

		public void push_hashtable (string key, GLib.HashTable<string, Value?> ht) {
			ht.foreach((k, v) => {
				this.environment.push ("%s.%s".printf(key, k), View.ctpl_value_from_value (v));
			});
		}

		/**
		 * Push an arbitrary value into the environment.
		 * This might have an unexpected result.
		 */
		public void push_value (string key, Value? val) {
			this.environment.push (key, View.ctpl_value_from_value (val));
		}

		/**
		 * Stream the view in the given output stream.
		 */
		public void stream (OutputStream output) {
			Ctpl.parser_parse (this.tree, this.environment, new Ctpl.OutputStream (output));
		}

		/**
		 * Renders the view as a string.
		 */
		public string render () {
			try {
				var mem_stream = new MemoryOutputStream (null, realloc, free);

				this.stream (mem_stream);

				return (string) mem_stream.get_data();

			} catch (Error e) {
				warning (e.message);
				return e.message;
			}
		}


	}
}
