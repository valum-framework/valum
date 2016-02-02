using VSGI;

public class App : Handler {

	public override bool handle (Request req, Response res) throws Error {
		return res.expand_utf8 ("Hello world!");
	}
}

public int main (string[] args) {
	return Server.new ("ajp", handler: new App ()).run (args);
}
