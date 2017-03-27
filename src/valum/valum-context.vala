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
 * Type of function passed to {@link Valum.Context.foreach} to iterate in all
 * context entries depth-wise.
 */
[Version (since = "0.3")]
public delegate void Valum.ContextForeachFunc (string key, Value @value, uint depth);

/**
 * Routing context that stores various states for middleware interaction.
 */
[Version (since = "0.3")]
public class Valum.Context : Object {

	/**
	 * Internal mapping of states.
	 */
	private HashTable<string, Value?> states = new HashTable<string, Value?> (str_hash, str_equal);

	/**
	 * Parent's context from which missing keys are resolved.
	 */
	[Version (since = "0.3")]
	public Context? parent { construct; get; default = null; }

	/**
	 * Create a new root context.
	 */
	[Version (since = "0.3")]
	public Context () {

	}

	/**
	 * Create a new child context.
	 */
	[Version (since = "0.3")]
	public Context.with_parent (Context parent) {
		Object (parent: parent);
	}

	/**
	 * Obtain a key from this context or its parent if it's not found.
	 *
	 * @param key the key used to retreive the value
	 * @return    the value, or 'null' if not found
	 */
	[Version (since = "0.3")]
	public new unowned Value? @get (string key) {
		return states[key] ?? (parent == null ? null : parent.@get (key));
	}

	/**
	 * Take a {@link GLib.Value} from the context.
	 *
	 * The value is removed from the context and owned by the caller.
	 *
	 * @param key the key used to retreive the value
	 * @return    the value, or 'null' if not found
	 */
	[Version (since = "0.3")]
	public Value? take (string key) {
		try {
			return states.lookup (key);
		} finally {
			states.steal (key);
		}
	}

	/**
	 * Set a key in this context.
	 *
	 * @param key   the key used to retreive the value once assigned
	 * @param value the value, which is then owned by the context
	 */
	[Version (since = "0.3")]
	public new void @set (string key, owned Value @value) {
		states.@set (key, (owned) @value);
	}

	/**
	 * Test if this context or its parent has a key.
	 *
	 * @param key the key used to test
	 *
	 * @return 'true' if the key is found in the context tree, 'false' otherwise
	 */
	[Version (since = "0.3")]
	public bool contains (string key) {
		return states.contains (key) || (parent != null && parent.contains (key));
	}

	/**
	 * Remove all occurences of a key in the context and its parents.
	 *
	 * @return 'true' if the key was removed from the context, otherwise the key
	 *          was not found and 'false' is returned
	 */
	[Version (since = "0.3")]
	public bool remove (string key) {
		var removed = states.remove (key);
		return (parent != null && parent.remove (key)) || removed;
	}

	private void _foreach (owned ContextForeachFunc func, uint depth) {
		states.@foreach ((k, v) => { func (k, v, depth); });
		if (parent != null) {
			parent._foreach ((owned) func, depth + 1);
		}
	}

	/**
	 * Iterate for each keys in the context tree by depth.
	 *
	 * @param func function called on each key in the context tree
	 */
	[Version (since = "0.3")]
	public void @foreach (owned ContextForeachFunc func) {
		_foreach ((owned) func, 0);
	}
}
