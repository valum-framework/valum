[CCode (cprefix = "Ctpl", lower_case_cprefix = "ctpl_")]
namespace Ctpl {

	[Compact]
	[CCode (ref_function = "ctpl_environ_ref", unref_function = "ctpl_environ_unref", cheader_filename = "ctpl/ctpl.h")]
	public class Environ {
		public weak GLib.HashTable symbol_table;
		[CCode (has_construct_function = false)]
		public Environ ();

		public bool add_from_path (string path) throws GLib.Error;
		public bool add_from_stream (Ctpl.InputStream stream) throws GLib.Error;
		public bool add_from_string (string str) throws GLib.Error;
		public static GLib.Quark error_quark ();
		public void @foreach (Ctpl.EnvironForeachFunc func);
		public unowned Ctpl.Value lookup (string symbol);
		public void merge (Ctpl.Environ source, bool merge_symbols);
		public bool pop (string symbol, ref Ctpl.Value? popped_value);
		public void push (string symbol, Ctpl.Value value);
		public void push_float (string symbol, double value);
		public void push_int (string symbol, long value);
		public void push_string (string symbol, string value);
	}

	[Compact]
	[CCode (ref_function = "ctpl_input_stream_ref", unref_function = "ctpl_input_stream_unref", cheader_filename = "ctpl/ctpl.h")]
	public class InputStream {
		public size_t buf_pos;
		public size_t buf_size;
		public weak string buffer;
		public uint line;
		public weak string name;
		public uint pos;
		public int ref_count;
		public weak GLib.InputStream stream;
		[CCode (has_construct_function = false)]
		public InputStream (GLib.InputStream stream, string name);
		public bool eof () throws GLib.Error;
		public bool eof_fast ();
		[CCode (has_construct_function = false)]
		public InputStream.for_gfile (GLib.File file) throws GLib.Error;
		[CCode (has_construct_function = false)]
		public InputStream.for_memory (string data, ssize_t length, GLib.DestroyNotify destroy, string name);
		[CCode (has_construct_function = false)]
		public InputStream.for_path (string path) throws GLib.Error;
		[CCode (has_construct_function = false)]
		public InputStream.for_uri (string uri) throws GLib.Error;
		public char get_c () throws GLib.Error;
		public ssize_t peek (void* buffer, size_t count) throws GLib.Error;
		public char peek_c () throws GLib.Error;
		public unowned string peek_symbol_full (ssize_t max_len, size_t length) throws GLib.Error;
		public unowned string peek_word (string accept, ssize_t accept_len, ssize_t max_len, size_t length) throws GLib.Error;
		public ssize_t read (void* buffer, size_t count) throws GLib.Error;
		public double read_double () throws GLib.Error;
		public long read_long () throws GLib.Error;
		public bool read_number (Ctpl.Value value) throws GLib.Error;
		public unowned string read_string_literal () throws GLib.Error;
		public unowned string read_symbol_full (ssize_t max_len, size_t length) throws GLib.Error;
		public unowned string read_word (string accept, ssize_t accept_len, ssize_t max_len, size_t length) throws GLib.Error;
		public void set_error (GLib.Quark domain, int code, string format) throws GLib.Error;
		public ssize_t skip (size_t count) throws GLib.Error;
		public ssize_t skip_blank () throws GLib.Error;
		public ssize_t skip_word (string reject, ssize_t reject_len) throws GLib.Error;
	}

	[Compact]
	[CCode (ref_function = "ctpl_output_stream_ref", unref_function = "ctpl_output_stream_unref", cheader_filename = "ctpl/ctpl.h")]
	public class OutputStream {
		[CCode (cname="ctpl_output_stream_new")]
		public static OutputStream (GLib.OutputStream stream);
		public bool put_c (char c) throws GLib.Error;
		public bool write (string data, ssize_t length) throws GLib.Error;
	}

	[Compact]
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public class Token {
		public weak Ctpl.Token last;
		public weak Ctpl.Token next;
		public weak Ctpl.TokenValue token;
		public Ctpl.TokenType type;
		public void append (Ctpl.Token brother);
		[CCode (has_construct_function = false)]
		public Token.data (string data, ssize_t len);
		public void dump (bool chain);
		[CCode (has_construct_function = false)]
		public Token.expr (Ctpl.TokenExpr expr);
		[CCode (has_construct_function = false)]
		public Token.@for (string array, string iterator, Ctpl.Token children);
		[CCode (has_construct_function = false)]
		public Token.@if (Ctpl.TokenExpr condition, Ctpl.Token if_children, Ctpl.Token else_children);
		public void prepend (Ctpl.Token brother);
	}

	[Compact]
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public class TokenExpr {
		public weak Ctpl.TokenExprValue token;
		public Ctpl.TokenExprType type;
		public void dump ();
		[CCode (has_construct_function = false)]
		public TokenExpr.float (double real);
		[CCode (has_construct_function = false)]
		public TokenExpr.integer (long integer);
		[CCode (has_construct_function = false)]
		public TokenExpr.operator (Ctpl.Operator operator, Ctpl.TokenExpr loperand, Ctpl.TokenExpr roperand);
		[CCode (has_construct_function = false)]
		public TokenExpr.symbol (string symbol, ssize_t len);
	}

	[Compact]
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public class TokenExprOperator {
		public weak Ctpl.TokenExpr loperand;
		public Ctpl.Operator operator;
		public weak Ctpl.TokenExpr roperand;
	}

	[Compact]
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public class TokenExprValue {
		public double t_float;
		public long t_integer;
		public weak Ctpl.TokenExprOperator t_operator;
		public weak string t_symbol;
	}
	[Compact]
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public class TokenFor {
		public weak string array;
		public weak Ctpl.Token children;
		public weak string iter;
	}
	[Compact]
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public class TokenIf {
		public weak Ctpl.TokenExpr condition;
		public weak Ctpl.Token else_children;
		public weak Ctpl.Token if_children;
	}
	[Compact]
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public class TokenValue {
		public weak string t_data;
		public weak Ctpl.TokenExpr t_expr;
		public weak Ctpl.TokenFor t_for;
		public weak Ctpl.TokenIf t_if;
	}
	[Compact]
	[CCode (copy_function = "ctpl_value_copy", cheader_filename = "ctpl/ctpl.h")]
	public class Value {
		public global::int type;
		public void* value;
		[CCode (has_construct_function = false)]
		public Value ();
		[CCode (has_construct_function = false)]
		public Value.array (Ctpl.ValueType type, size_t count, ...);
		public void array_append (Ctpl.Value val);
		public void array_append_float (double val);
		public void array_append_int (long val);
		public void array_append_string (global::string val);
		public size_t array_length ();
		public void array_prepend (Ctpl.Value val);
		public void array_prepend_float (double val);
		public void array_prepend_int (long val);
		public void array_prepend_string (global::string val);
		[CCode (has_construct_function = false)]
		public Value.arrayv (Ctpl.ValueType type, size_t count, va_list ap);
		public bool convert (Ctpl.ValueType vtype);
		public void copy (Ctpl.Value dst_value);
		public unowned Ctpl.Value dup ();
		[CCode (has_construct_function = false)]
		public Value.float (double val);
		public void free_value ();
		public unowned GLib.SList get_array ();
		public double[] get_array_float ();
		public long[] get_array_int ();
		public unowned global::string[] get_array_string ();
		public double get_float ();
		public Ctpl.ValueType get_held_type ();
		public long get_int ();
		public unowned global::string get_string ();
		public void init ();
		[CCode (has_construct_function = false)]
		public Value.int (long val);
		public void set_array (Ctpl.ValueType type, size_t count, va_list ap);
		public void set_array_float (size_t count);
		public void set_array_floatv (size_t count, va_list ap);
		public void set_array_int (size_t count);
		public void set_array_intv (size_t count, va_list ap);
		public void set_array_string (size_t count);
		public void set_array_stringv (size_t count, va_list ap);
        public void set_arrayv (Ctpl.ValueType type, size_t count, va_list ap);
		public void set_float (double val);
		public void set_int (long val);
		public void set_string (global::string val);
		[CCode (has_construct_function = false)]
		public Value.string (global::string val);
		public unowned global::string to_string ();
		public static unowned global::string type_get_name (Ctpl.ValueType type);
	}
	[CCode (cprefix = "CTPL_ENVIRON_ERROR_", has_type_id = false, cheader_filename = "ctpl/ctpl.h")]
	public enum EnvironError {
		LOADER_MISSING_SYMBOL,
		LOADER_MISSING_VALUE,
		LOADER_MISSING_SEPARATOR,
		FAILED
	}
	[CCode (cprefix = "CTPL_EVAL_ERROR_", has_type_id = false, cheader_filename = "ctpl/ctpl.h")]
	public enum EvalError {
		INVALID_OPERAND,
		SYMBOL_NOT_FOUND,
		FAILED
	}
	[CCode (cprefix = "CTPL_IO_ERROR_", has_type_id = false, cheader_filename = "ctpl/ctpl.h")]
	public enum IOError {
		EOF,
		INVALID_NUMBER,
		INVALID_STRING,
		RANGE,
		NOMEM,
		FAILED
	}
	[CCode (cprefix = "CTPL_LEXER_ERROR_", has_type_id = false, cheader_filename = "ctpl/ctpl.h")]
	public enum LexerError {
		SYNTAX_ERROR,
		FAILED
	}
	[CCode (cprefix = "CTPL_LEXER_EXPR_ERROR_", has_type_id = false, cheader_filename = "ctpl/ctpl.h")]
	public enum LexerExprError {
		MISSING_OPERAND,
		MISSING_OPERATOR,
		SYNTAX_ERROR,
		FAILED
	}
	[CCode (cprefix = "CTPL_OPERATOR_", has_type_id = false, cheader_filename = "ctpl/ctpl.h")]
	public enum Operator {
		PLUS,
		MINUS,
		DIV,
		MUL,
		EQUAL,
		INF,
		SUP,
		MODULO,
		SUPEQ,
		INFEQ,
		NEQ,
		AND,
		OR,
		NONE
	}
	[CCode (cprefix = "CTPL_PARSER_ERROR_", has_type_id = false, cheader_filename = "ctpl/ctpl.h")]
	public enum ParserError {
		INCOMPATIBLE_SYMBOL,
		SYMBOL_NOT_FOUND,
		FAILED
	}
	[CCode (cprefix = "CTPL_TOKEN_EXPR_TYPE_", has_type_id = false, cheader_filename = "ctpl/ctpl.h")]
	public enum TokenExprType {
		OPERATOR,
		INTEGER,
		FLOAT,
		SYMBOL
	}
	[CCode (cprefix = "CTPL_TOKEN_TYPE_", has_type_id = false, cheader_filename = "ctpl/ctpl.h")]
	public enum TokenType {
		DATA,
		FOR,
		IF,
		EXPR
	}
	[CCode (cprefix = "CTPL_VTYPE_", has_type_id = false, cheader_filename = "ctpl/ctpl.h")]
	public enum ValueType {
		INT,
		FLOAT,
		STRING,
		ARRAY
	}
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public delegate bool EnvironForeachFunc (Ctpl.Environ env, string symbol, Ctpl.Value value);
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public const string BLANK_CHARS;
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public const int EOF;
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public const string EXPR_CHARS;
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public const string OPERAND_CHARS;
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public const string OPERATOR_CHARS;
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public const string SYMBOL_CHARS;
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static bool eval_bool (Ctpl.TokenExpr expr, Ctpl.Environ env, bool _result) throws GLib.Error;
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static GLib.Quark eval_error_quark ();
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static bool eval_value (Ctpl.TokenExpr expr, Ctpl.Environ env, Ctpl.Value value) throws GLib.Error;
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static GLib.Quark io_error_quark ();
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static void lexer_dump_tree (Ctpl.Token root);
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static GLib.Quark lexer_error_quark ();
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static GLib.Quark lexer_expr_error_quark ();
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static unowned Ctpl.TokenExpr lexer_expr_lex (Ctpl.InputStream stream) throws GLib.Error;
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static unowned Ctpl.TokenExpr lexer_expr_lex_full (Ctpl.InputStream stream, bool lex_all) throws GLib.Error;
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static unowned Ctpl.TokenExpr lexer_expr_lex_string (string expr, ssize_t len) throws GLib.Error;
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static void lexer_free_tree (Ctpl.Token root);
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static unowned Ctpl.Token lexer_lex (Ctpl.InputStream stream) throws GLib.Error;
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static unowned Ctpl.Token lexer_lex_path (string path) throws GLib.Error;
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static unowned Ctpl.Token lexer_lex_string (string template) throws GLib.Error;
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static Ctpl.Operator operator_from_string (string str, ssize_t len, size_t operator_len);
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static unowned string operator_to_string (Ctpl.Operator op);
	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static GLib.Quark parser_error_quark ();

	[CCode (cheader_filename = "ctpl/ctpl.h")]
	public static bool parser_parse (Ctpl.Token tree, Ctpl.Environ env, Ctpl.OutputStream output) throws GLib.Error;
}
