/* libmemcached Vala Bindings
 * Copyright 2012 Evan Nemerson <evan@coeus-group.com>
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

[CCode (cheader_filename = "libmemcached/memcached.h")]
namespace Memcached {

  // defaults.h
  public const in_port_t DEFAULT_PORT;
  public const string    DEFAULT_PORT_STRING;
  public const uint      POINTS_PER_SERVER;
  public const uint      POINTS_PER_SERVER_KETAMA;
  public const uint      CONTINUUM_SIZE;
  public const uint      STRIDE;
  public const uint      DEFAULT_TIMEOUT;
  public const uint      DEFAULT_CONNECT_TIMEOUT;
  public const uint      CONTINUUM_ADDITION;
  public const uint      EXPIRATION_NOT_ADD;
  public const uint      SERVER_FAILURE_LIMIT;
  public const uint      SERVER_FAILURE_RETRY_TIMEOUT;
  public const uint      SERVER_FAILURE_DEAD_TIMEOUT;
  public const uint      SERVER_TIMEOUT_LIMIT;

  // limits.h
  public const uint   MAXIMUM_INTEGER_DISPLAY_LENGTH;
  public const uint   MAX_BUFFER;
  public const uint   MAX_HOST_SORT_LENGTH;
  public const uint   MAX_KEY;
  public const uint   PREFIX_KEY_MAX_SIZE;
  public const size_t VERSION_STRING_LENGTH;

  public const string CALLBACK_PREFIX_KEY;

  // alloc.h
  public delegate void FreeFunc (Memcached.Context ptr, void* mem);
  public delegate void* MallocFunc (Memcached.Context ptr, size_t size);
  public delegate void* ReallocFunc (Memcached.Context ptr, void* mem, size_t size);
  public delegate void* CallocFunc (Memcached.Context ptr, size_t nelem, size_t elsize);

  // callbacks.h
  [CCode (cname = "memcached_execute_fn")]
  public delegate Memcached.ReturnCode ExecuteCallback (Memcached.Context ptr, Memcached.Result result);
  [CCode (cname = "memcached_server_fn")]
  public delegate Memcached.ReturnCode ServerCallback (Memcached.Context ptr, Memcached.Instance server);
  [CCode (cname = "memcached_stat_fn")]
  public delegate Memcached.ReturnCode StatCallback (Memcached.Instance server, [CCode (array_length_type = "size_t")] uint8[] key, [CCode (array_length_type = "size_t")] uint8[] value);

  // triggers.h
  [CCode (cname = "memcached_clone_fn", has_target = false)]
  public delegate Memcached.ReturnCode CloneFunc (Memcached.Context destination, Memcached.Context source);
  [CCode (cname = "memcached_cleanup_fn", has_target = false)]
  public delegate Memcached.ReturnCode CleanupFunc (Memcached.Context ptr);
  [CCode (cname = "memcached_trigger_key_fn", has_target = false)]
  public delegate Memcached.ReturnCode KeyTrigger (Memcached.Context ptr, [CCode (array_length_type = "size_t")] uint8[] key, Memcached.Result result);
  [CCode (cname = "memcached_trigger_delete_key_fn", has_target = false)]
  public delegate Memcached.ReturnCode DeleteKeyTrigger (Memcached.Context ptr, [CCode (array_length_type = "size_t")] uint8[] key);
  [CCode (cname = "memcached_dump_fn")]
  public delegate Memcached.ReturnCode DumpCallback (Memcached.Context ptr, [CCode (array_length_type = "size_t")] uint8[] key);

  [SimpleType]
  [IntegerType (rank = 6), CCode (cname = "in_port_t")]
  public struct in_port_t {}

  [SimpleType]
  [IntegerType (rank = 11), CCode (cname = "unsigned long long")]
  public struct ulonglong {}

  // options.h
  [CCode (cname = "libmemcached_check_configuration")]
  public Memcached.ReturnCode check_configuration ([CCode (array_length_type = "size_t")] uint8[] option_string, [CCode (array_length_type = "size_t")] uint8[] error_buffer);

  // version.h
  public string lib_version ();

  [Compact, CCode (cname = "memcached_st", has_type_id = false, lower_case_cprefix = "memcached_")]
  public class Context {
    // memcached.h
    public void servers_reset ();
    [CCode (cname = "memcached_create")]
    public Context (Memcached.Context? ptr = null);
    [CCode (cname = "memcached")]
    public Context.from_configuration ([CCode (array_length_type = "size_t")] uint8[]? str = null);
    public Memcached.ReturnCode reset ();
    public void reset_last_disconnected_server ();
    [CCode (instance_pos = 2)]
    public Memcached.Context clone (Memcached.Context? destination = null);
    public void set_user_data<T> (T data);
    public T get_user_data<T> ();
    public Memcached.ReturnCode push (Memcached.Context source);
    public unowned Memcached.Instance server_instance_by_position (uint32 server_key);
    public uint32 server_count ();
    public uint64 query_id ();

    // allocators.h
    public Memcached.ReturnCode set_memory_allocator (MallocFunc mem_malloc, FreeFunc mem_free, ReallocFunc mem_realloc, CallocFunc mem_calloc);
    public void get_memory_allocator (out MallocFunc mem_malloc, out FreeFunc mem_free, out ReallocFunc mem_realloc, out CallocFunc mem_calloc);
    public void* get_memory_allocator_context ();

    // analyze.h
    public Memcached.Analysis? analyze (Memcached.Stat memc_stat, out Memcached.ReturnCode error);

    // auto.h
    public Memcached.ReturnCode increment ([CCode (array_length_type = "size_t")] uint8[] key, uint32 offset, out uint64 value);
    public Memcached.ReturnCode decrement ([CCode (array_length_type = "size_t")] uint8[] key, uint32 offset, out uint64 value);
    public Memcached.ReturnCode increment_by_key ([CCode (array_length_type = "size_t")] uint8[] group_key, [CCode (array_length_type = "size_t")] uint8[] key, uint32 offset, out uint64 value);
    public Memcached.ReturnCode decrement_by_key ([CCode (array_length_type = "size_t")] uint8[] group_key, [CCode (array_length_type = "size_t")] uint8[] key, uint32 offset, out uint64 value);
    public Memcached.ReturnCode increment_with_initial ([CCode (array_length_type = "size_t")] uint8[] key, uint64 offset, uint64 initial, time_t expiration, out uint64 value);
    public Memcached.ReturnCode decrement_with_initial ([CCode (array_length_type = "size_t")] uint8[] key, uint64 offset, uint64 initial, time_t expiration, out uint64 value);
    public Memcached.ReturnCode increment_with_initial_by_key ([CCode (array_length_type = "size_t")] uint8[] group_key, [CCode (array_length_type = "size_t")] uint8[] key, uint64 offset, uint64 initial, time_t expiration, out uint64 value);
    public Memcached.ReturnCode decrement_with_initial_by_key ([CCode (array_length_type = "size_t")] uint8[] group_key, [CCode (array_length_type = "size_t")] uint8[] key, uint64 offset, uint64 initial, time_t expiration, out uint64 value);

    // behavior.h
    public Memcached.ReturnCode behavior_set (Memcached.Behavior flag, uint64 data);
    public uint64 behavior_get (Memcached.Behavior flag);
    public Memcached.ReturnCode behavior_set_distribution (Memcached.ServerDistribution type);
    public Memcached.ServerDistribution behavior_get_distribution ();
    public Memcached.ReturnCode set_key_hash (Memcached.Hash type);
    public Memcached.Hash get_key_hash ();
    public Memcached.ReturnCode set_distribution_hash (Memcached.Hash type);
    public Memcached.Hash get_distribution_hash ();
    public Memcached.ReturnCode bucket_set ([CCode (array_length = false)] uint32[] host_map, [CCode (array_length = false)] uint32[] forward_map, uint32 buckets, uint32 replicas);

    // callback.h
    public Memcached.ReturnCode callback_set (Memcached.Callback flag, void* data);
    public void* callback_get (Memcached.Callback flag, out Memcached.ReturnCode error);

    // delete.h
    public Memcached.ReturnCode @delete ([CCode (array_length_type = "size_t")] uint8[] key, time_t expiration);
    public Memcached.ReturnCode delete_by_key ([CCode (array_length_type = "size_t")] uint8[] group_key, [CCode (array_length_type = "size_t")] uint8[] key, time_t expiration);

    // dump.h
    [CCode (cname = "memcached_dump")]
    private Memcached.ReturnCode _dump (Memcached.DumpCallback function, uint32 number_of_callbacks);
    [CCode (cname = "memcached_dump_wrapper")]
    public Memcached.ReturnCode dump (Memcached.DumpCallback function) {
      var _function = &function;
      return this._dump ((Memcached.DumpCallback) _function, 1);
    }

    // encoding_key.h
    public Memcached.ReturnCode set_encoding_key ([CCode (array_length_type = "size_t")] uint8[] str);

    // error.h
    public unowned string error ();
    public unowned string last_error_message ();
    public void error_print ();
    public Memcached.ReturnCode last_error ();
    public int last_error_errno ();

    // exist.h
    public Memcached.ReturnCode exist ([CCode (array_length_type = "size_t")] uint8[] key);
    public Memcached.ReturnCode exist_by_key ([CCode (array_length_type = "size_t")] uint8[] group_key, [CCode (array_length_type = "size_t")] uint8[] key);

    // fetch.h
    [CCode (cname = "memcached_fetch_execute")]
    private Memcached.ReturnCode _fetch_execute (Memcached.ExecuteCallback callback, uint32 number_of_callbacks);
    [CCode (cname = "memcached_fetch_execute_wrapper")]
    public Memcached.ReturnCode fetch_execute (Memcached.ExecuteCallback callback) {
      var _callback = &callback;
      return this._fetch_execute ((Memcached.ExecuteCallback) _callback, 1);
    }

    // flush_buffers.h
    public Memcached.ReturnCode flush_buffers ();

    // flush.h
    public Memcached.ReturnCode flush (time_t expiration);

    // get.h
    [CCode (array_length_pos = 1.5, array_length_type = "size_t")]
    public uint8[]? @get ([CCode (array_length_type = "size_t")] uint8[] key, out uint32 flags, out Memcached.ReturnCode error);
    public Memcached.ReturnCode mget ([CCode (array_length_type = "size_t", array_length_pos = 2.5)] uint8*[] keys, [CCode (array_length = false)] size_t[] keys_length);
    [CCode (array_length_pos = 2.5, array_length_type = "size_t")]
    public uint8[]? get_by_key ([CCode (array_length_type = "size_t")] uint8[] group_key, [CCode (array_length_type = "size_t")] uint8[] key, out uint32 flags, out Memcached.ReturnCode error);
    public Memcached.ReturnCode mget_by_key ([CCode (array_length_type = "size_t")] uint8[] group_key, [CCode (array_length_type = "size_t", array_length_pos = 3.5)] uint8*[] keys, [CCode (array_length = false)] size_t[] keys_length);
    [Version (deprecated = true, deprecated_since = "0.50", replacement = "fetch_result"), CCode (array_length_pos = 1.5, array_length_type = "size_t")]
    public uint8[]? fetch ([CCode (array_length_type = "size_t")] uint8[] key, out uint32 flags, out Memcached.ReturnCode error);
    public Memcached.Result? fetch_result (Memcached.Result? result, out Memcached.ReturnCode error);
    [CCode (cname = "memcached_mget_execute")]
    private Memcached.ReturnCode _mget_execute ([CCode (array_length_type = "size_t", array_length_pos = 2.5)] uint8*[] keys, [CCode (array_length = false)] size_t[] keys_length, Memcached.ExecuteCallback function, uint32 number_of_callbacks = 1);
    [CCode (cname = "memcached_mget_execute_wrapper")]
    public Memcached.ReturnCode mget_execute (uint8*[] keys, size_t[] keys_length, Memcached.ExecuteCallback function) {
      var _function = &function;
      return this._mget_execute (keys, keys_length, (Memcached.ExecuteCallback) _function, 1);
    }
	[CCode (cname = "memcached_mget_execute_by_key")]
    public Memcached.ReturnCode _mget_execute_by_key ([CCode (array_length_type = "size_t")] uint8[] group_key, [CCode (array_length_type = "size_t", array_length_pos = 3.5)] uint8*[] keys, [CCode (array_length = false)] size_t[] keys_length, Memcached.ExecuteCallback function, uint32 number_of_callbacks = 1);
	[CCode (cname = "memcached_mget_execute_by_key_wrapper")]
    public Memcached.ReturnCode mget_execute_by_key (uint8[] group_key, uint8*[] keys, size_t[] keys_length, Memcached.ExecuteCallback function) {
      var _function = &function;
      return this._mget_execute_by_key (group_key, keys, keys_length, (Memcached.ExecuteCallback) _function, 1);
    }

    // hash.h
    public uint32 generate_hash_value ([CCode (array_length_type = "size_t")] uint8[] key, Memcached.Hash hash_algorithm);
    public uint32 generate_hash ([CCode (array_length_type = "size_t")] uint8[] key);
    public void autoeject ();

    // result.h
    public Memcached.Result result_create (Memcached.Result? result = null);

    // sasl.h
    public Memcached.ReturnCode set_sasl_auth_data (string username, string password);
    public Memcached.ReturnCode destroy_sasl_auth_data ();

    // server.h
    [CCode (cname = "memcached_server_cursor")]
    private Memcached.ReturnCode _server_cursor (Memcached.ServerCallback function, uint32 number_of_callbacks);
	[CCode (cname = "memcached_server_cursor_wrapper")]
    public Memcached.ReturnCode server_cursor (Memcached.ServerCallback function) {
      var _function = &function;
      return this._server_cursor ((Memcached.ServerCallback) _function, 1);
    }
    public unowned Memcached.Instance? server_by_key ([CCode (array_length_type = "size_t")] uint8[] key, out Memcached.ReturnCode error);
    public unowned Memcached.Instance? server_get_last_disconnect ();
    public Memcached.ReturnCode server_add_udp (string hostname, in_port_t port = Memcached.DEFAULT_PORT);
    public Memcached.ReturnCode server_add_unix_socket (string filename);
    public Memcached.ReturnCode server_add (string hostname, in_port_t port = Memcached.DEFAULT_PORT);
    public Memcached.ReturnCode server_add_udp_with_weight (string hostname, in_port_t port, uint32 weight);
    public Memcached.ReturnCode server_add_unix_socket_with_weight (string filename, uint32 weight);
    public Memcached.ReturnCode server_add_with_weight (string hostname, in_port_t port, uint32 weight);

    // server_list.h
    public Memcached.ReturnCode server_push (Memcached.ServerList list);

    // stat.h
    public void stat_free (Memcached.Stat memc_stat);
    public Memcached.Stat? stat (string args, out Memcached.ReturnCode error);
    public string stat_get_value (Memcached.Stat memc_stat, string key, out Memcached.ReturnCode error);
    [CCode (array_null_terminated = true)]
    public string[] stat_get_keys (Memcached.Stat memc_stat, out Memcached.ReturnCode error);
    public Memcached.ReturnCode stat_execute (string args, Memcached.StatCallback func);

    // storage.h
    public Memcached.ReturnCode @set ([CCode (array_length_type = "size_t")] uint8[] key, [CCode (array_length_type = "size_t")] uint8[] value, time_t expiration, uint32 flags);
    public Memcached.ReturnCode add ([CCode (array_length_type = "size_t")] uint8[] key, [CCode (array_length_type = "size_t")] uint8[] value, time_t expiration, uint32 flags);
    public Memcached.ReturnCode replace ([CCode (array_length_type = "size_t")] uint8[] key, [CCode (array_length_type = "size_t")] uint8[] value, time_t expiration, uint32 flags);
    public Memcached.ReturnCode append ([CCode (array_length_type = "size_t")] uint8[] key, [CCode (array_length_type = "size_t")] uint8[] value, time_t expiration, uint32 flags);
    public Memcached.ReturnCode prepend ([CCode (array_length_type = "size_t")] uint8[] key, [CCode (array_length_type = "size_t")] uint8[] value, time_t expiration, uint32 flags);
    public Memcached.ReturnCode cas ([CCode (array_length_type = "size_t")] uint8[] key, [CCode (array_length_type = "size_t")] uint8[] value, time_t expiration, uint32 flags, uint64 cas);
    public Memcached.ReturnCode set_by_key ([CCode (array_length_type = "size_t")] uint8[] group_key, [CCode (array_length_type = "size_t")] uint8[] key, [CCode (array_length_type = "size_t")] uint8[] value, time_t expiration, uint32 flags);
    public Memcached.ReturnCode add_by_key ([CCode (array_length_type = "size_t")] uint8[] group_key, [CCode (array_length_type = "size_t")] uint8[] key, [CCode (array_length_type = "size_t")] uint8[] value, time_t expiration, uint32 flags);
    public Memcached.ReturnCode prepend_by_key ([CCode (array_length_type = "size_t")] uint8[] group_key, [CCode (array_length_type = "size_t")] uint8[] key, [CCode (array_length_type = "size_t")] uint8[] value, time_t expiration, uint32 flags);
    public Memcached.ReturnCode append_by_key ([CCode (array_length_type = "size_t")] uint8[] group_key, [CCode (array_length_type = "size_t")] uint8[] key, [CCode (array_length_type = "size_t")] uint8[] value, time_t expiration, uint32 flags);
    public Memcached.ReturnCode cas_by_key ([CCode (array_length_type = "size_t")] uint8[] group_key, [CCode (array_length_type = "size_t")] uint8[] key, [CCode (array_length_type = "size_t")] uint8[] value, time_t expiration, uint32 flags, uint64 cas);

    // strerror.h
    public unowned string strerror (Memcached.ReturnCode rc);

    // touch.h
    public Memcached.ReturnCode touch ([CCode (array_length_type = "size_t")] uint8[] key, time_t expiration);
    public Memcached.ReturnCode touch_by_key ([CCode (array_length_type = "size_t")] uint8[] group_key, [CCode (array_length_type = "size_t")] uint8[] key, time_t expiration);

    // quit.h
    public void quit ();

    // verbosity.h
    public Memcached.ReturnCode verbosity (uint32 verbosity);

    // version.h
    public Memcached.ReturnCode version ();

    public unowned Memcached.Context iterator () {
      return this;
    }
    public Memcached.Result? next_value () {
      Memcached.ReturnCode error;
      return this.fetch_result (null, out error);
    }
  }

  // type/analysis.h
  [CCode (cname = "memcached_analysis_st", has_copy_function = false, free_function = "memcached_analyze_free")]
  public struct Analysis {
    public unowned Memcached.Context root;
    public uint32 average_item_size;
    public uint32 longest_uptime;
    public uint32 least_free_server;
    public uint32 most_consumed_server;
    public uint32 oldest_server;
    public double pool_hit_ratio;
    public uint64 most_used_bytes;
    public uint64 least_remaining_bytes;
  }

  // result.h
  [Compact, CCode (cname = "memcached_result_st")]
  public class Result {
    public void reset ();
    [CCode (cname = "memcached_result_key_value", array_length = false)]
    private unowned uint8[] _key_value ();
    private size_t key_length ();
    [CCode (cname = "memcached_result_key_value_wrapper")]
    public unowned uint8[] key_value () {
        unowned uint8[] key    = this._key_value ();
        key.length = (int) this.key_length ();
        return key;
    }
    [CCode (cname = "memcached_result_value", array_length = false)]
    private unowned uint8[] _value ();
    [CCode (cname = "memcached_result_take_value", array_length = false)]
    private uint8[] _take_value ();
    private size_t length ();
    [CCode (cname = "memcached_result_value_wrapper")]
    public unowned uint8[] value () {
        unowned uint8[] val = this._value ();
        val.length          = (int) this.length ();
        return val;
    }
    [CCode (cname = "memcached_result_take_value_wrapper")]
    public uint8[] take_value () {
        var val    = this._take_value ();
        val.length = (int) this.length ();
        return val;
    }
    public uint32 flags ();
    public uint64 cas ();
    public Memcached.ReturnCode set_value (uint8[] value);
    public void set_flags (uint32 flags);
    public void set_expiration (time_t expiration);
  }

  // types/behavior.h
  [CCode (cname = "memcached_behavior_t")]
  public enum Behavior {
    NO_BLOCK,
    TCP_NODELAY,
    HASH,
    KETAMA,
    SOCKET_SEND_SIZE,
    SOCKET_RECV_SIZE,
    CACHE_LOOKUPS,
    SUPPORT_CAS,
    POLL_TIMEOUT,
    DISTRIBUTION,
    BUFFER_REQUESTS,
    USER_DATA,
    SORT_HOSTS,
    VERIFY_KEY,
    CONNECT_TIMEOUT,
    RETRY_TIMEOUT,
    KETAMA_WEIGHTED,
    KETAMA_HASH,
    BINARY_PROTOCOL,
    SND_TIMEOUT,
    RCV_TIMEOUT,
    SERVER_FAILURE_LIMIT,
    IO_MSG_WATERMARK,
    IO_BYTES_WATERMARK,
    IO_KEY_PREFETCH,
    HASH_WITH_PREFIX_KEY,
    NOREPLY,
    USE_UDP,
    AUTO_EJECT_HOSTS,
    NUMBER_OF_REPLICAS,
    RANDOMIZE_REPLICA_READ,
    CORK,
    TCP_KEEPALIVE,
    TCP_KEEPIDLE,
    LOAD_FROM_FILE,
    REMOVE_FAILED_SERVERS,
    DEAD_TIMEOUT,
    SERVER_TIMEOUT_LIMIT,
    MAX;

    // behavior.h
    [CCode (cname = "libmemcached_string_behavior")]
    public string to_string ();
  }

  // types/callback.h
  [CCode (cname = "memcached_callback_t")]
  public enum Callback {
    PREFIX_KEY       = 0,
    USER_DATA        = 1,
    CLEANUP_FUNCTION = 2,
    CLONE_FUNCTION   = 3,
    GET_FAILURE      = 7,
    DELETE_TRIGGER   = 8,
    MAX,
    NAMESPACE        = Memcached.CALLBACK_PREFIX_KEY
  }

  // types/hash.h
  [CCode (cname = "memcached_hash_t")]
  public enum Hash {
    DEFAULT,
    MD5,
    CRC,
    FNV1_64,
    FNV1A_64,
    FNV1_32,
    FNV1A_32,
    HSIES,
    MURMUR,
    JENKINS,
    MURMUR3,
    CUSTOM,
    MAX
  }

  // return.h
  [CCode (cname = "memcached_return_t", cprefix = "MEMCACHED_", lower_case_cprefix = "memcached_")]
  public enum ReturnCode {
    SUCCESS,
    FAILURE,
    HOST_LOOKUP_FAILURE,
    CONNECTION_FAILURE,
    WRITE_FAILURE,
    READ_FAILURE,
    UNKNOWN_READ_FAILURE,
    PROTOCOL_ERROR,
    CLIENT_ERROR,
    SERVER_ERROR,
    DATA_EXISTS,
    DATA_DOES_NOT_EXIST,
    NOTSTORED,
    STORED,
    NOTFOUND,
    MEMORY_ALLOCATION_FAILURE,
    PARTIAL_READ,
    SOME_ERRORS,
    NO_SERVERS,
    END,
    DELETED,
    VALUE,
    STAT,
    ITEM,
    ERRNO,
    NOT_SUPPORTED,
    FETCH_NOTFINISHED,
    TIMEOUT,
    BUFFERED,
    BAD_KEY_PROVIDED,
    INVALID_HOST_PROTOCOL,
    SERVER_MARKED_DEAD,
    UNKNOWN_STAT_KEY,
    E2BIG,
    INVALID_ARGUMENTS,
    KEY_TOO_BIG,
    AUTH_PROBLEM,
    AUTH_FAILURE,
    AUTH_CONTINUE,
    PARSE_ERROR,
    PARSE_USER_ERROR,
    DEPRECATED,
    IN_PROGRESS,
    SERVER_TEMPORARILY_DISABLED,
    SERVER_MEMORY_ALLOCATION_FAILURE,
    MAXIMUM_RETURN;

    public bool success ();
    public bool failed ();
    public bool fatal ();
  }

  // types/server_distribution.h
  [CCode (cname = "memcached_server_distribution_t", cprefix = "MEMCACHED_DISTRIBUTION_")]
  public enum ServerDistribution {
    MODULA,
    CONSISTENT,
    CONSISTENT_KETAMA,
    RANDOM,
    CONSISTENT_KETAMA_SPY,
    CONSISTENT_WEIGHTED,
    VIRTUAL_BUCKET,
    CONSISTENT_MAX;

    // behavior.h
    [CCode (cname = "libmemcached_string_distribution")]
    public string to_string ();
  }

  // parse.h
  [Version (deprecated = true, deprecated_since = "0.39", replacement = "Context.from_configuration")]
  public Memcached.ServerList servers_parse (string server_strings);

  // server.h
  [Compact, CCode (cname = "memcached_instance_st", has_type_id = false, lower_case_cprefix = "memcached_server_")]
  public class Instance {
    public uint32 response_count ();
    public unowned string name ();
    public in_port_t port ();
    public in_port_t srcport ();
    public void next_retry (time_t absolute_time);
    public unowned string type ();
    public uint8 major_version ();
    public uint8 minor_version ();
    public uint8 micro_version ();

    // error.h
    public unowned string error ();
    public Memcached.ReturnCode error_return ();
  }

  [CCode (cname = "memcached_server_list_st", has_type_id = false)]
  [SimpleType]
  public struct ServerList {
    public Memcached.ServerList append (string hostname, in_port_t port, out Memcached.ReturnCode error);
    public Memcached.ServerList append_with_weight (string hostname, in_port_t port, uint32 weight, out Memcached.ReturnCode error);
    public uint32 count ();
  }

  // stat.h
  [CCode (cname = "memcached_stat_st", has_copy_function = false)]
  public struct Stat {
    ulong connection_structures;
    ulong curr_connections;
    ulong curr_items;
    Posix.pid_t pid;
    ulong pointer_size;
    ulong rusage_system_microseconds;
    ulong rusage_system_seconds;
    ulong rusage_user_microseconds;
    ulong rusage_user_seconds;
    ulong threads;
    ulong time;
    ulong total_connections;
    ulong total_items;
    ulong uptime;
    ulonglong bytes;
    ulonglong bytes_read;
    ulonglong bytes_written;
    ulonglong cmd_get;
    ulonglong cmd_set;
    ulonglong evictions;
    ulonglong get_hits;
    ulonglong get_misses;
    ulonglong limit_maxbytes;
    uint8 version[Memcached.VERSION_STRING_LENGTH];
    void* __future;
    unowned Memcached.Context root;

    public Memcached.ReturnCode servername (string args, string hostname, in_port_t port);
  }
}
