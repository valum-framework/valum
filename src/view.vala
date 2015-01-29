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
			var arr = new Ctpl.Value.array (Ctpl.ValueType.STRING);

			foreach (var e in val) {
				arr.array_append_string (e);
			}

			this.environment.push (key, arr);
		}

		public void push_ints (string key, int[] val) {
			var arr = new Ctpl.Value.array (Ctpl.ValueType.INT);

			foreach (var e in val) {
				arr.array_append_int (e);
			}

			this.environment.push (key, arr);
		}

		public void push_floats (string key, float[] val) {
			var arr = new Ctpl.Value.array (Ctpl.ValueType.FLOAT);

			foreach (var e in val) {
				arr.array_append_float (e);
			}

			this.environment.push (key, arr);
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
			map.map_iterator().foreach((k, v) => {
				this.push_value ("%s_%s".printf(key, k), v);
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
		 *
		 * Supports the following types:
		 *
		 * * string
		 * * float
		 * * int
		 * * Gee.Collection
		 * * Gee.Map
		 * * GLib.HashTable
		 *
		 * @param key   key for the value pushed in the environment
		 * @param value value that must respec one of the supported type
		 */
		public void push_value (string key, Value? val) {
			if (val == null) {
				this.environment.push_string (key, "null");
			}

			// coverts all Gee collections
			else if (Value.type_compatible (val.type (), typeof(Collection))) {
				this.push_collection (key, (Collection) val.get_object ());
			}

			// converts all Gee maps
			else if (Value.type_compatible (val.type (), typeof(Map))) {
				this.push_map (key, (Map) val.get_object ());
			}

			else if (Value.type_compatible (val.type (), typeof(HashTable))) {
				this.push_hashtable (key, (HashTable) val.get_object ());
			}

			else if (val.type() == typeof(string)) {
				this.environment.push_string (key, val.get_string ());
			}

			else if (Value.type_transformable(val.type (), typeof(double))) {
				this.environment.push_float (key, val.get_double ());
			}

			else if (Value.type_transformable(val.type (), typeof(long))) {
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
