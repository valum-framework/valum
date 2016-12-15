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

using GLib;

/**
 * VSGI is an set of abstraction and implementations used to build generic web
 * application in Vala.
 *
 * It is minimalist and relies on libsoup-2.4, a good and stable HTTP library.
 */
[CCode (gir_namespace = "VSGI", gir_version = "0.4")]
namespace VSGI {

	[Version (since = "0.3")]
	[CCode (has_target = false)]
	public delegate Type HandlerInitFunc (TypeModule type_module);

	[Version (since = "0.3")]
	[CCode (has_target = false)]
	public delegate Type ServerInitFunc (TypeModule module);
}
