using Valum;
using VSGI.Test;

/**
 * @since 0.3
 */
public void test_negociate () {
	var req = new Request (new Connection (), "GET", new Soup.URI ("http://localhost/"));

	req.headers.append ("Accept", "text/html; q=0.9, text/xml; q=0");

	assert (negociate ("Accept", "text/html") (req, new Context ()));
	assert (!negociate ("Accept", "text/xml") (req, new Context ()));
	assert (!negociate ("Accept-Encoding", "utf-8") (req, new Context ()));
}


