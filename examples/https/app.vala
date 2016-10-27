using Valum;
using VSGI;

public int main (string[] args) {
	var app = new Router ();

	app.get ("/", (req, res) => {
		res.headers.set_content_type ("text/plain", null);
		return res.expand_utf8 ("Hello world!");
	});

	TlsCertificate tls_certificate;
	try {
		tls_certificate = new TlsCertificate.from_files ("tests/data/http-server/cert.pem",
		                                                 "tests/data/http-server/key.pem");
	} catch (Error err) {
		critical (err.message);
		return 1;
	}

	return Server.@new ("http", handler: app, https: true, tls_certificate: tls_certificate).run (args);
}
