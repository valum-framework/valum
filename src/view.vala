using Gee;

namespace Valum {
	/**
	 * View based on CTPL templating engine.
	 *
	 * @since 0.1
	 */
	public class View {

		private unowned Ctpl.Token tree;

		/**
		 * Provides low-level access to the view environment.
		 *
		 * @since 0.1
		 */
		public Ctpl.Environ environment = new Ctpl.Environ ();

		/**
		 * Create a CTPL template from a path.
		 *
		 * @since 0.1
		 */
		public View.from_path (string path) throws IOError, Ctpl.LexerError {
			this.tree = Ctpl.lexer_lex_path (path);
		}

		/**
		 * Create a CTPL template from a string.
		 *
		 * @since 0.0.1
		 */
		public View.from_string (string template) throws Ctpl.LexerError {
			this.tree = Ctpl.lexer_lex_string (template);
		}

		/**
		 * @since 0.1
		 */
		public void push_string (string key, string val) {
			this.environment.push_string (key, val);
		}

		/**
		 * @since 0.1
		 */
		public void push_int (string key, long val) {
			this.environment.push_int (key, val);
		}

		/**
		 * @since 0.1
		 */
		public void push_float (string key, double val) {
			this.environment.push_float (key, val);
		}

		/**
		 * @since 0.1
		 */
		public void push_strings (string key, string[] val) {
			var arr = new Ctpl.Value.array (Ctpl.ValueType.STRING);

			foreach (var e in val) {
				arr.array_append_string (e);
			}

			this.environment.push (key, arr);
		}

		/**
		 * @since 0.1
		 */
		public void push_ints (string key, long[] val) {
			var arr = new Ctpl.Value.array (Ctpl.ValueType.INT);

			foreach (var e in val) {
				arr.array_append_int (e);
			}

			this.environment.push (key, arr);
		}

		/**
		 * @since 0.1
		 */
		public void push_floats (string key, double[] val) {
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
		 *
		 * TODO: this thing SEGFAULTs..
		 *
		 * @since 0.1
		 */
		public void push_collection (string key, Collection collection) {
			var arr = collection.to_array ();

			if (Value.type_transformable(collection.element_type, typeof(long[]))) {
				this.push_ints (key, (long[]) arr);
			}

			else if (Value.type_transformable(collection.element_type, typeof(double[]))) {
				this.push_floats (key, (double[]) arr);
			}

			else if (collection.element_type == typeof(string[])) {
				this.push_strings (key, (string[]) arr);
			}

			else {
				this.environment.push_string (key, "could not infer type %s of %s".printf (collection.element_type.name (), key));
			}
		}

		/**
		 * Map are bound by composing the key with the entry key.
		 *
		 * @since 0.1
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
		 *
		 * @since 0.1
		 */
		public void push_multimap (string key, MultiMap<string, Value?> multimap) {
			foreach (var k in multimap.get_keys ()) {
				this.push_collection ("%s_%s".printf (key, k), multimap[k]);
			}
		}

		/**
		 * @since 0.1
		 */
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
		 * @since 0.1
		 *
		 * @param key   key for the value pushed in the environment
		 * @param value value that must respec one of the supported type
		 */
		public void push_value (string key, Value? val) {
			if (val == null) {
				this.environment.push_string (key, "null");
				return;
			}

			var v = /* (Value) does not compile.. */ val;

			// coverts all Gee collections
			if (Value.type_compatible (v.type (), typeof(Collection))) {
				this.push_collection (key, (Collection) v.get_object ());
			}

			// converts all Gee maps
			else if (Value.type_compatible (v.type (), typeof(Map))) {
				this.push_map (key, (Map) v.get_object ());
			}

			else if (Value.type_compatible (v.type (), typeof(HashTable))) {
				this.push_hashtable (key, (HashTable) v.get_object ());
			}

			else if (v.type() == typeof(string)) {
				this.environment.push_string (key, v.get_string ());
			}

			else if (Value.type_transformable(v.type (), typeof(double))) {
				this.environment.push_float (key, v.get_double ());
			}

			else if (Value.type_transformable(v.type (), typeof(long))) {
				this.environment.push_int (key, v.get_int ());
			}

			else {
				this.environment.push_string (key, "unknown type %s for key %s".printf (v.type_name (), key));
			}
		}

		/**
		 * Stream the view in the given output stream.
		 *
		 * @since 0.1
		 */
		public void stream (OutputStream output) throws IOError, Ctpl.IOError {
			Ctpl.parser_parse (this.tree, this.environment, new Ctpl.OutputStream (output));
		}

		/**
		 * Stream the template into a MemoryOutputStream and return the rendered
		 * string.
		 *
		 * @since 0.0.1
		 */
		public string render () throws IOError, Ctpl.IOError {
			var mem_stream = new MemoryOutputStream.resizable ();

			this.stream (mem_stream);

			return (string) mem_stream.get_data();
		}
	}
}
