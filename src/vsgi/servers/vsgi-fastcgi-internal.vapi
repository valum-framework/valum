namespace VSGI.FastCGI {
	[CCode (cheader_filename = "vsgi-fastcgi-input-stream.h")]
	public class InputStream : GLib.UnixInputStream {
		public InputStream (int fd, global::FastCGI.Stream @in);
	}
	[CCode (cheader_filename = "vsgi-fastcgi-output-stream.h")]
	public class OutputStream : GLib.UnixOutputStream {
		public OutputStream (int fd, global::FastCGI.Stream @out, global::FastCGI.Stream err);
	}
}
