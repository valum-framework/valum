using Gee;

namespace Valum {
	/**
	 *
	 */
	public class View {

		/**
		 *
		 */
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
         *
		 * The collection type can be string, int, float or collection.
		 */
		public void push_collection (string key, Collection collection) {
			var arr = collection.to_array ();

			if (collection.element_type.name () == "gint") {
				this.push_ints (key, (int[]) arr);
			}

			if (collection.element_type.name () == "gdouble") {
				this.push_floats (key, (float[]) arr);
			}

			if (collection.element_type.name () == "gchararray") {
				this.push_strings (key, (string[]) arr);
			}

			this.environment.push_string (key, "could not infer type %s of %s".printf (collection.element_type.name (), key));
		}

		/**
		 * Map are bound by composing the key with the entry key.
		 */
		public void push_map (string key, Map<string, Value?> map) {
			map.foreach((e) => {
				this.push_value ("%s_%s".printf(key, e.key), e.value);
				return true;
			});
		}

		/**
		 * MultiMap are bound by composing the key with the entry key and associate
		 * that value to an array.
		 */
		public void push_multimap (string key, MultiMap<string, Value?> multimap) {
			foreach (var k in multimap.get_keys ()) {
				this.push_collection ("%s_%s".printf (key, k), multimap[k]);
			}
		}

		public void push_hashtable (string key, GLib.HashTable<string, Value?> ht) {
			ht.foreach((k, v) => {
				this.push_value ("%s_%s".printf (key, k), v);
			});
		}

		/**
		 * Push an arbitrary value into the environment.
		 * This might have an unexpected result.
		 */
		public void push_value (string key, Value? val) {

			// coverts all Gee collections
			if (val.get_object () is Collection) {
				this.push_collection (key, (Collection) val);
			}

			// converts all Gee maps
			else if (val.get_object () is Map) {
				this.push_map (key, (Map) val);
			}

			else if (val.get_object () is HashTable) {
				this.push_hashtable (key, (HashTable) val);
			}

			else if (val.type_name() == "gchararray") {
				this.environment.push_string (key, val.get_string ());
			}

			else if (val.type_name() == "gdouble") {
				this.environment.push_float (key, val.get_double ());
			}

			else if (val.type_name() == "gint") {
				this.environment.push_int (key, val.get_int ());
			}

			else {
				this.environment.push_string (key, "unknown type %s for key %s".printf (val.type_name (), key));
			}
		}

		/**
		 * Stream the view in the given output stream.
		 */
		public void stream (OutputStream output) throws Error {
			Ctpl.parser_parse (this.tree, this.environment, new Ctpl.OutputStream (output));
		}

		/**
		 * Renders the view as a string.
		 */
		public string render () throws Error {
			var mem_stream = new MemoryOutputStream (null, realloc, free);

			this.stream (mem_stream);

			return (string) mem_stream.get_data();
		}
	}
}
