using GLib;
using Valum;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/context", () => {
		var ctx = new Context ();

		assert (null == ctx["key"]);

		ctx["key"] = "test";
		assert ("key" in ctx);
		assert ("test" == ctx["key"].get_string ());
	});

	Test.add_func ("/context/take", () => {
		var ctx = new Context ();

		assert (null == ctx.take ("key"));

		ctx["key"] = "test";

		var @value = ctx.take ("key");
		assert (null != @value);
		assert ("test" == @value.get_string ());
		assert (!("key" in ctx));
	});

	Test.add_func ("/context/remove", () => {
		var ctx = new Context ();

		ctx["key"] = "test";
		assert ("key" in ctx);

		assert (ctx.remove ("key"));
		assert (!ctx.remove ("key"));

		assert (!("key" in ctx));
	});

	Test.add_func ("/context/foreach", () => {
		var ctx = new Context ();

		ctx["key"] = "value";

		ctx.@foreach ((k, v, d) => {
			assert ("key" == k);
			assert ("value" == v.get_string ());
			assert (0 == d);
		});
	});

	return Test.run ();
}
