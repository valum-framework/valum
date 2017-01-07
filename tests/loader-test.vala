using GLib;
using VSGI;

[ModuleInit]
public Type handler_init (TypeModule type_module) {
	return typeof (App);
}

public class App : Handler {
	public override bool handle (Request req, Response res) throws Error {
		return res.expand_utf8 ("Hello world2!");
	}
}
