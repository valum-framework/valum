using Libmemcached;

namespace Valum {
	namespace NoSQL {
		// Sugar Wrapper around Libmemcached
		public class Mcached {

			public Memcached client;
			private Memcached.Return rc; // Return Code

			public Mcached() {
				this.client = new Memcached ();
			}

			public void add_server(string host, uint16 port) {
				var server = @"$host:$port";
				this.client.server_push (this.client.servers_parse(server));
			}

			public new string get(string key) {
				uint32 flags;

				var str = this.client.get (key.data, out flags, out this.rc);
				if (this.rc == Memcached.Return.SUCCESS) {
					return (string)str;
				} else {
					error("could not get from memcached %d", this.rc);
					return "";
				}
			}

			public bool set(string key, string value) {
				this.rc = this.client.set(key.data, value.data, 0, 0);
				if (this.rc == Memcached.Return.SUCCESS) {
					return true;
				} else {
					error("could not set to memcached %d", this.rc);
					return false;
				}
			}

			public uint64 inc(string key, uint offset) {
				uint64 result;
				this.rc = this.client.increment(key.data, offset, out result);
				if (this.rc == Memcached.Return.STORED) {
					return result;
				} else {
					error("could not inc to memcached %d", this.rc);
					return 0;
				}
			}
		}
	}
}
