
[CCode (cprefix = "Ruby")]
namespace Ruby {
	[SimpleType]
 	[CCode (cname = "ID", cheader_filename = "ruby.h")]
	public struct ID {
	}

	[SimpleType]
 	[CCode (cname = "VALUE", cheader_filename = "ruby.h")]
	public struct Value {
// 		[CCode (cname = "rb_define_method")]
// 		public void define_method (string name, Ruby.Callback func, int argc);
		[CCode (cname = "rb_respond_to")]
		public int respond_to (Ruby.ID method);
		[CCode (cname = "rb_funcall")]
		[PrintfLike]
			public Value send(Ruby.ID method, int num_args, ...);
	}

	
	[SimpleType]
	[CCode (cname = "VALUE", cheader_filename = "ruby.h")]
	public struct Class : Value {
	}
	
	[SimpleType]
 	[CCode (cname = "VALUE", cheader_filename = "ruby.h")]
// 	public struct Array : Value, Gee.Iterable<Ruby.Value> {
	public struct Array : Value {
		[CCode (cname = "RARRAY_LEN", cheader_filename = "ruby.h")]
		public weak int length();
		[CCode (cname = "rb_ary_store", cheader_filename = "ruby.h")]
		public weak void store(int index, Ruby.Value value);
		[CCode (cname = "rb_ary_push", cheader_filename = "ruby.h")]
		public weak Ruby.Value push(Ruby.Value value);
		[CCode (cname = "rb_ary_pop", cheader_filename = "ruby.h")]
		public weak Ruby.Value pop();
		[CCode (cname = "rb_ary_shift", cheader_filename = "ruby.h")]
		public weak Ruby.Value shift();
		[CCode (cname = "rb_ary_unshift", cheader_filename = "ruby.h")]
		public weak Ruby.Value unshift(Ruby.Value value);
		[CCode (cname = "rb_ary_entry", cheader_filename = "ruby.h")]
		public weak Ruby.Value entry(int index);

		[CCode (cname = "rb_ary_new", cheader_filename = "ruby.h")]
		public static weak Ruby.Array new();
	}

	[SimpleType]
 	[CCode (cname = "VALUE", cheader_filename = "ruby.h")]
	public struct Hash : Value {
		[CCode (cname = "rb_hash_aref", cheader_filename = "ruby.h")]
		public weak Ruby.Value @get(Ruby.Value key);
		[CCode (cname = "rb_hash_aset", cheader_filename = "ruby.h")]
		public weak Ruby.Value @set(Ruby.Value key, Ruby.Value obj);

		[CCode (cname = "rb_hash_new", cheader_filename = "ruby.h")]
		public static weak Ruby.Hash new();
	}

	[SimpleType]
 	[CCode (cname = "VALUE", cheader_filename = "ruby.h")]
	public struct String : Value {
		[CCode (cname = "RSTRING_LEN", cheader_filename = "ruby.h")]
		public weak int length();
		[CCode (cname = "RSTRING_PTR", cheader_filename = "ruby.h")]
		public weak string to_vala();

		[CCode (cname = "rb_str_new2", cheader_filename = "ruby.h")]
		public static weak Ruby.String new(string src);
	}

	[SimpleType]
 	[CCode (cname = "VALUE", cheader_filename = "ruby.h")]
	public struct Number : Value {
		[CCode (cname = "NUM2INT", cheader_filename = "ruby.h")]
		public int to_vala();
	}

	[SimpleType]
 	[CCode (cname = "VALUE", cheader_filename = "ruby.h")]
	public struct Int : Number {
		[CCode (cname = "NUM2INT", cheader_filename = "ruby.h")]
		public int to_vala();
	}

	[SimpleType]
 	[CCode (cname = "VALUE", cheader_filename = "ruby.h")]
	public struct Float : Number {
	}

	[SimpleType]
 	[CCode (cname = "VALUE", cheader_filename = "ruby.h")]
	public struct Bool : Value {
	}

	[CCode (cname = "rb_cObject")]
	public const Class cObject;
	[CCode (cname = "Qnil")]
	public const Value Nil;
	[CCode (cname = "Qtrue")]
	public const Bool True;
	[CCode (cname = "Qfalse")]
	public const Bool False;

	// Type conversions
	[CCode (cname = "INT2FIX", cheader_filename = "ruby.h")]
	public static weak Ruby.Value int2fix(int v);
	[CCode (cname = "LONG2FIX", cheader_filename = "ruby.h")]
	public static weak Ruby.Value long2fix(long v);
	[CCode (cname = "rb_intern", cheader_filename = "ruby.h")]
	public static weak Ruby.ID id(string name);


	public static void init();
	public static void init_loadpath();
	public static void script(string name);
	[CCode (cname = "rb_eval_string")]
	public static Ruby.Value eval(string code);
	[CCode (cname = "rb_require")]
	public static Ruby.Bool require(string filename);
	[CCode (cname = "rb_class_new_instance")]
	public static Ruby.Value class_new_instance(int a, int b, Ruby.Class klass);
	[CCode (cname = "rb_const_get")]
	public static Ruby.Class const_get(Ruby.Class top, Ruby.ID name);
	public static void finalize();



	// these don't work don't use them:
// 	public static delegate weak Value Callback(Ruby.Value self, void* varargs);

// 	[CCode (cname = "rb_define_class", cheader_filename = "ruby.h")]
// 	public static weak Ruby.Value define_class (string name, Ruby.Value superclass);
// 	[CCode (cname = "rb_define_alloc_func", cheader_filename = "ruby.h")]
// 	public static weak Ruby.Value define_alloc_func (Ruby.Value classmod, Ruby.Callback func);
// 	[CCode (cname = "rb_define_class_under", cheader_filename = "ruby.h")]
// 	public static weak Ruby.Value define_class_under (Ruby.Value under, string name, Ruby.Value superclass);
// 	[CCode (cname = "rb_define_module", cheader_filename = "ruby.h")]
// 	public static weak Ruby.Value define_module (string name);
// 	[CCode (cname = "Data_Wrap_Struct", cheader_filename = "ruby.h")]
// 	public static weak Ruby.Value data_wrap_struct (Ruby.Value klass, Ruby.Callback mark, Ruby.Callback free, void* ptr);

}
