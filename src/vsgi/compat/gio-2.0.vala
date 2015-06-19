namespace GLib {
#if !GIO_2_44
	public class SimpleIOStream : IOStream {

		private InputStream _input_stream;
		private OutputStream _output_stream;

		public override InputStream input_stream { get { return this._input_stream; } }

		public override OutputStream output_stream { get { return this._output_stream; } }

		public SimpleIOStream (InputStream @in, OutputStream @out) {
			this._input_stream  = @in;
			this._output_stream = @out;
		}
	}
#endif
}
