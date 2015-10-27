/*
 * ->Copyright (C) 2007 David Loren Parsons.
 * All rights reserved.<-
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1.  Redistributions of works must retain the original copyright notice,
 *     this list of conditions and the following disclaimer.
 * 2.  Redistributions in binary form must reproduce the original copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 * 3.  Neither my name (David L Parsons) nor the names of contributors to
 *     this code may be used to endorse or promote products derived
 *     from this work without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

[CCode (cheader_filename = "mkdio.h")]
namespace Markdown
{
	[CCode (cname = "mkd_callback_t", has_target = false)]
	public delegate string Callback<T> (string str, int size, T user_data);
	[CCode (cname = "mkd_free_t", has_target = false)]
	public delegate void FreeCallback<T> (string str, int size, T user_data);
	[CCode (cname = "mkd_sta_t", has_target = false)]
	public delegate int StringToAnchorCallback<T> (int outchar, T @out);

	public void initialize ();
	public void with_html5_tags ();
	public void shlib_destructor ();
	public char markdown_version[];

	[Compact]
	[CCode (cname = "MMIOT", cprefix = "mkd_", free_function = "mkd_cleanup")]
	public class Document
	{
		[CCode (cname = "mkd_in")]
		public Document.from_in (Posix.FILE file, DocumentFlags flags);
		[CCode (cname = "mkd_string")]
		public Document.from_string (uint8[] doc, DocumentFlags flags);

		[CCode (cname = "gfm_in")]
		public Document.from_gfm_in (Posix.FILE file, DocumentFlags flags);
		[CCode (cname = "gfm_string")]
		public Document.from_gfm_string (uint8[] doc, DocumentFlags flags);

		public void basename (string @base);

		public bool compile (DocumentFlags flags);
		public void cleanup ();

		public int dump (Posix.FILE file, DocumentFlags flags, string title);
		[CCode (cname = "markdown")]
		public int markdown (Posix.FILE file, DocumentFlags flags);
		public static int line (uint8[] buffer, out string @out, DocumentFlags flags);
		public static void string_to_anchor<T> (uint8[] buffer, StringToAnchorCallback<T> sta, T @out, DocumentFlags flags);
		public int xhtmlpage (DocumentFlags flags, Posix.FILE file);

		public string doc_title ();
		public string doc_author ();
		public string doc_date ();

		public int document (out unowned string text);
		public int toc (out unowned string @out);
		public int css (out unowned string @out);
		public static int xml (uint8[] buffer, out string @out);

		public int generatehtml (Posix.FILE file);
		public int generatetoc (Posix.FILE file);
		public static int generatexml (uint8[] buffer, Posix.FILE file);
		public int generatecss (Posix.FILE file);
		public static int generateline (uint8[] buffer, Posix.FILE file, DocumentFlags flags);

		public void e_url (Callback callback);
		public void e_flags (Callback callback);
		public void e_free (FreeCallback callback);
		public void e_data<T> (T user_data);

		public static void mmiot_flags (Posix.FILE file, Document document, bool htmlplease);
		public static void flags_are (Posix.FILE file, DocumentFlags flags, bool htmlplease);

		public void ref_prefix (string prefix);
	}

	[Flags]
	[CCode (cprefix = "MKD_")]
	public enum DocumentFlags
	{
		NOLINKS,
		NOIMAGE,
		NOPANTS,
		NOHTML,
		STRICT,
		TAGTEXT,
		NO_EXT,
		NOEXT,
		CDATA,
		NOSUPERSCRIPT,
		NORELAXED,
		NOTABLES,
		NOSTRIKETHROUGH,
		TOC,
		1_COMPAT,
		AUTOLINK,
		SAFELINK,
		NOHEADER,
		TABSTOP,
		NODIVQUOTE,
		NOALPHALIST,
		NODLIST,
		EXTRA_FOOTNOTE,
		NOSTYLE,
		EMBED
	}
}
