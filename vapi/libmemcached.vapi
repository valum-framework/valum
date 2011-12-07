namespace Libmemcached {
	[Compact]
	[CCode (cheader_filename="libmemcached/memcached.h", free_function="memcached_free", cprefix="memcached_", cname="memcached_st")]
	public class Memcached {
		[Compact]
		[CCode (cname="memcached_server_st")]
		public class Server {
		}

		[CCode (cname="memcached_return_t", cprefix="MEMCACHED_")]
		public enum Return {
			SUCCESS,
			FAILURE,
			HOST_LOOKUP_FAILURE,
			CONNECTION_FAILURE,
			CONNECTION_BIND_FAILURE,
			WRITE_FAILURE,
			READ_FAILURE,
			UNKNOWN_READ_FAILURE,
			PROTOCOL_ERROR,
			CLIENT_ERROR,
			SERVER_ERROR,
			CONNECTION_SOCKET_CREATE_FAILURE,
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
			FAIL_UNIX_SOCKET,
			NOT_SUPPORTED,
			NO_KEY_PROVIDED, /* Deprecated. Use MEMCACHED_BAD_KEY_PROVIDED! */
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
			MAXIMUM_RETURN
		}

		[Compact]
		[CCode (cname="struct memcached_server_st")]
		public class ServerList {
		}

		[CCode (cname="memcached_create")]
		public Memcached(Memcached? ptr = null);
		public static ServerList servers_parse(string str);

		public Return server_push(ServerList list);
		public Return increment(uint8[] key, uint offset, out uint64 v);
		[CCode (array_length_pos=2.1)]
		public uint8[] get(uint8[] key, out uint32 flags, out Return err);
		public string get_by_key (uint8[] master_key, uint8[] key, out size_t vlength, out uint32 flags, out Return error);
		//public string mget(string[] keys, size_t[] key_length, int nkeys);
		//public string mget_by_key (uint8[] master_key,size_t[], key_length, size_t nkeys);
		public Return delete(uint8[] key, time_t expiration);
		public Return delete_by_key(uint8[] master_key, uint8[] key, time_t expiration);

		public Return append(uint8[] key, uint8[] @value, time_t expiration, uint32 flags);
		public Return prepend(uint8[] key, uint8[] @value, time_t expiration, uint32 flags);
		public Return cas(uint8[] key, uint8[] @value, time_t expiration, uint32 flags, uint64 cas);
		public Return set(uint8[] key, uint8[] @value, time_t expiration, uint32 flags);
		public Return @add(uint8[] key, uint8[] @value, time_t expiration, uint32 flags);
		public Return set_by_key(uint8[] masterkey, uint8[] key, uint8[] @value, time_t expiration, uint32 flags);
		public Return add_by_key(uint8[] masterkey, uint8[] key, uint8[] @value, time_t expiration, uint32 flags);
		public Return replace_by_key(uint8[] masterkey, uint8[] key, uint8[] @value, time_t expiration, uint32 flags);
		public Return prepend_by_key(uint8[] masterkey, uint8[] key, uint8[] @value, time_t expiration, uint32 flags);
		public Return append_by_key(uint8[] masterkey, uint8[] key, uint8[] @value, time_t expiration, uint32 flags);
		public Return cas_by_key(uint8[] masterkey, uint8[] key, uint8[] @value, time_t expiration, uint32 flags);
	}
}
