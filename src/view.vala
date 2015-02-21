using Gee;

namespace Valum {
	/**
	 * View based on {@link Ctpl} templating engine.
	 *
	 * Provide helpers for pushing common types into the template environment
	 * such as Gee.Collection, Gee.Map, array of primitive and much more.
	 *
	 * This implementation include two rendering functions: {@link View.render}
	 * and {@link View.splice}. The latter integrates very well with the
	 * framework since {@link VSGI.Response} inherit from {@link OutputStream}.
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
		 * @see   Ctpl.lexer_lex_path
		 * @since 0.1
		 */
		public View.from_path (string path) throws IOError, Ctpl.LexerError {
			this.tree = Ctpl.lexer_lex_path (path);
		}

		/**
		 * Create a CTPL template from a string.
		 *
		 * @see   Ctpl.lexer_lex_string
		 * @since 0.0.1
		 */
		public View.from_string (string template) throws Ctpl.LexerError {
			this.tree = Ctpl.lexer_lex_string (template);
		}

		/**
		 * Create a CTPL template from an input stream.
		 *
		 * @see   Ctpl.lexer_lex_string
		 * @since 0.1
		 */
		public View.from_stream (InputStream input) throws IOError, Ctpl.LexerError {
			this.tree = Ctpl.lexer_lex (new Ctpl.InputStream (input, null));
		}

		/**
		 * @see   Ctpl.Environ.push_string
		 * @since 0.1
		 */
		public void push_string (string key, string val) {
			this.environment.push_string (key, val);
		}

		/**
		 * @see   Ctpl.Environ.push_int
		 * @since 0.1
		 */
		public void push_int (string key, long val) {
			this.environment.push_int (key, val);
		}

		/**
		 * @see   Ctpl.Environ.push_float
		 * @since 0.1
		 */
		public void push_float (string key, double val) {
			this.environment.push_float (key, val);
		}

		/**
		 * Push an array of string into the environment.
		 *
		 * @since 0.1
		 */
		public void push_strings (string key, string[] strings) {
			var val = new Ctpl.Value.array (Ctpl.ValueType.STRING, 0);

			foreach (var str in strings) {
				val.array_append_string (str);
			}

			this.environment.push (key, val);
		}

		/**
		 * Push an array of long into the environment.
		 *
		 * @since 0.1
		 */
		public void push_ints (string key, long[] longs) {
			var val = new Ctpl.Value.array (Ctpl.ValueType.INT, 0);

			foreach (var i in longs) {
				val.array_append_int (i);
			}

			this.environment.push (key, val);
		}

		/**
		 * Push an array of double into the environment.
		 *
		 * @since 0.1
		 */
		public void push_floats (string key, double[] floats) {
			var val = new Ctpl.Value.array (Ctpl.ValueType.FLOAT, 0);

			foreach (var f in floats) {
				val.array_append_float (f);
			}

			this.environment.push (key, val);
		}

		/**
		 * Push a {@link Gee.Collection} into the environment.
         *
		 * The element type can be either string, long or double.
		 *
		 * @since 0.1
		 */
		public void push_collection (string key, Collection collection) {
			if (Value.type_compatible (collection.element_type, typeof(long))) {
				this.push_ints (key, ((Collection<long>) collection).to_array ());
			}

			else if (Value.type_compatible (collection.element_type, typeof(double))) {
				this.push_floats (key, ((Collection<double>) collection).to_array ());
			}

			else if (Value.type_compatible (collection.element_type, typeof(string))) {
				this.push_strings (key, ((Collection<string>) collection).to_array ());
			}

			else {
				this.environment.push_string (key, "could not infer type %s of %s".printf (collection.element_type.name (), key));
			}
		}

		/**
		 * Push a {@link Gee.Map} into the environment.
		 *
		 * Value is infered using {@link View.push_value}.
		 *
		 * @since 0.1
		 */
		public void push_map (string key, Map<string, Value?> map) {
			map.map_iterator().foreach((k, v) => {
				this.push_value ("%s_%s".printf(key, k), v);
				return true;
			});
		}

		public void push_string_map (string key, Map<string, string> map) {
			map.map_iterator().foreach((k, v) => {
				this.push_string ("%s_%s".printf(key, k), v);
				return true;
			});
		}

		public void push_int_map (string key, Map<string, long> map) {
			map.map_iterator().foreach((k, v) => {
				this.push_int ("%s_%s".printf(key, k), v);
				return true;
			});
		}

		/**
		 * Push a {@link Gee.MultiMap} of string into the environment.
		 *
		 * MultiMap are bound by composing the key with the entry key and associate
		 * that value to an array.
		 *
		 * @since 0.1
		 */
		public void push_string_multimap (string key, MultiMap<string, string> multimap) {
			foreach (var k in multimap.get_keys ()) {
				this.push_strings ("%s_%s".printf (key, k), multimap[k].to_array ());
			}
		}

		/**
		 * Push a {@link Gee.MultiMap} of int into the environment.
		 *
		 * @since 0.1
		 */
		public void push_int_multimap (string key, MultiMap<string, long> multimap) {
			foreach (var k in multimap.get_keys ()) {
				this.push_ints ("%s_%s".printf (key, k), multimap[k].to_array ());
			}
		}

		/**
		 * Push a {@link GLib.HashTable} into the environment.
		 *
		 * Value is infered using {@link View.push_value}.
		 *
		 * @see   View.push_map
		 * @since 0.1
		 */
		public void push_hashtable (string key, GLib.HashTable<string, Value?> ht) {
			ht.foreach((k, v) => {
				this.push_value ("%s_%s".printf (key, k), v);
			});
		}

		public void push_string_hashtable (string key, GLib.HashTable<string, string> ht) {
			ht.foreach((k, v) => {
				this.push_string ("%s_%s".printf (key, k), v);
			});
		}

		public void push_int_hashtable (string key, GLib.HashTable<string, long> ht) {
			ht.foreach((k, v) => {
				this.push_int ("%s_%s".printf (key, k), v);
			});
		}

		/**
		 * Push an arbitrary {@link GLib.Value} into the environment.
		 *
		 * Support is limited to what the environment can hold and the predefined
		 * functions of this class.
		 *
		 * * null
		 * * string
		 * * long
		 * * double
		 * * string[]
		 * * double[]
		 * * long[]
		 *
		 * @since 0.1
		 *
		 * @param key   key for the value pushed in the environment
		 * @param value value that must respec one of the supported type
		 */
		public void push_value (string key, Value? val) {
			// cover the null case
			if (val == null) {
				this.environment.push_string (key, "null");
			}

			else if (Value.type_compatible (val.type (), typeof(string))) {
				this.environment.push_string (key, val.get_string ());
			}

			else if (Value.type_compatible (val.type (), typeof(long))) {
				this.environment.push_int (key, val.get_int ());
			}

			else if (Value.type_compatible (val.type (), typeof(double))) {
				this.environment.push_float (key, val.get_double ());
			}

			else if (Value.type_compatible (val.type (), typeof(string[]))) {
				this.push_strings (key, (string[]) val.get_pointer ());
			}

			else if (Value.type_compatible (val.type (), typeof(long[]))) {
				this.push_ints (key, (long[]) val.get_pointer ());
			}

			else if (Value.type_compatible (val.type (), typeof(double[]))) {
				this.push_floats (key, (double[]) val.get_pointer ());
			}

			else {
				this.environment.push_string (key, "unknown type %s for key %s".printf (val.type_name (), key));
			}
		}

		/**
		 * Splice the template into a given OutputStream.
		 *
		 * This is used to render a template directly into a stream and avoid
		 * memory overhead if the template is heavy.
		 *
		 * @since 0.1
		 *
		 * @param output OutputStream into which the template will be spliced.
		 */
		public void splice (OutputStream output) throws IOError, Ctpl.IOError {
			Ctpl.parser_parse (this.tree, this.environment, new Ctpl.OutputStream (output));
		}

		/**
		 * Stream the template into a {@link MemoryOutputStream} and return the
		 * rendered string.
		 *
		 * @since 0.0.1
		 */
		public string render () throws IOError, Ctpl.IOError {
			var mem_stream = new MemoryOutputStream (null, realloc, free);

			this.splice (mem_stream);

			return (string) mem_stream.get_data();
		}
	}
}
