/* guile.vapi
 *
 * Copyright (C) 2011 Antono Vasiljev
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Authors:
 * 	Antono Vasiljev <self@antono.info>
 */

[CCode (lower_case_cprefix = "scm_", cheader_filename = "libguile.h")]
class Guile {

	/* Constants */

	public const string VERSION;
	public const string RELEASE;
	public const int VERSION_NUM;
	public const string COPYRIGHT;
	public const string AUTHORS;
	public const string SIGNATURE;
	public const int MULTRET;

	/* TODO */
}
