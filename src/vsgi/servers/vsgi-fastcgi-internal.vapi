/*
 * This file is part of Valum.
 *
 * Valum is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * Valum is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Valum.  If not, see <http://www.gnu.org/licenses/>.
 */

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
