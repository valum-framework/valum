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
 * Routing context that stores various states for middleware interaction.
 *
 * @since 0.3
 */
public class Valum.Context : Object {

	/**
	 * Internal mapping of states.
	 */
	private HashTable<string, Value?> states = new HashTable<string, Value?> (str_hash, str_equal);

	/**
	 * Parent's context from which missing keys are resolved.
	 *
	 * @since 0.3
	 */
	public Context? parent { construct; get; default = null; }

	/**
	 * Create a new root context.
	 *
	 * @since 0.3
	 */
	public Context () {

	}

	/**
	 * Create a new child context.
	 *
	 * @since 0.3
	 */
	public Context.with_parent (Context parent) {
		Object (parent: parent);
	}

	/**
	 * Obtain a key from this context or its parent if it's not found.
	 *
	 * @since 0.3
	 */
	public new Value? @get (string key) {
		return states[key] ?? (parent == null ? null : parent[key]);
	}

	/**
	 * Set a key in this context.
	 *
	 * @since 0.3
	 */
	public new void @set (string key, Value? @value) {
		states[key] = @value;
	}

	/**
	 * Lookup if this context or its parent has a key.
	 *
	 * @since 0.3
	 */
	public bool contains (string key) {
		return states.contains (key) || (parent != null && parent.contains (key));
	}
}
