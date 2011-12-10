namespace Valum {
	namespace View {
		public interface IView : Object {

			/**
			 * Path to file containing template
			 */
			public abstract string path { get; set; }

			/**
			 * Renders reads template from path
			 */
			public abstract void read(string? path);

			/**
			 * Renders given template
			 * Returns: rendered template
			 */
			public abstract string? render(Gee.HashMap? vars);
		}
	}
}
