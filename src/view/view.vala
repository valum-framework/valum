using Gee;

namespace Valum {
	namespace View {
        // View interface providing rendering abilities.
		public abstract class View : Object {

            // Variables for the view
            public HashMap<string, Value?> vars = new HashMap<string, Value?> ();

            // Renders the view into a string
			public abstract string? render ();
		}
	}
}
