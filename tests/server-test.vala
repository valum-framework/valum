using VSGI;

public int main (string[] args) {
	Test.init (ref args);

	Test.add_func ("/server/new/http", () => {
		var server = Server.@new ("http");
		assert ("VSGIHTTPServer" == server.get_type ().name ());
	});

	Test.add_func ("/server/new/cgi", () => {
		var server = Server.@new ("cgi");
		assert ("VSGICGIServer" == server.get_type ().name ());
	});

	Test.add_func ("/server/new/scgi", () => {
		var server = Server.@new ("scgi");
		assert ("VSGISCGIServer" == server.get_type ().name ());
	});

	Test.add_func ("/server/new/fastcgi", () => {
		var server = Server.@new ("fastcgi");
		assert ("VSGIFastCGIServer" == server.get_type ().name ());
	});

	Test.add_func ("/server/new/mock", () => {
		var server = Server.@new ("mock");
		assert ("VSGIMockServer" == server.get_type ().name ());
	});

	return Test.run ();
}
