/* GnuTLS Vala Binding
 * Copyright 2017 Guillaume Poirier-Morency <guillaumepoiriermorency@gmail>
 *
 * Copyright (C) 2008-2012 Free Software Foundation, Inc.
 *
 * The GnuTLS is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */
[CCode (lower_case_cprefix = "gnutls_")]
namespace GnuTLS {
	public int memcmp (void* s1, void* s2, size_t n);
}
