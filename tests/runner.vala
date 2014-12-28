namespace Valum {
	namespace Tests {
		public void main (string[] args) {
			Test.init (ref args);

			Test.add_func ("/ctpl/from_path", () => {

				var template = new View.Tpl.from_string ("{hello}");

				assert (template.render () == "hello");
			});

			Test.run ();
		}
	}
}
