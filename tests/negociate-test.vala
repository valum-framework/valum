using Valum;
using VSGI.Test;

/**
 * @since 0.3
 */
public void test_negociate () {
	var req   = new Request (new Connection (), "GET", new Soup.URI ("http://localhost/"));
	var res   = new Response (req);
	var stack = new Queue<Value?> ();

	req.headers.append ("Accept", "text/html; q=0.9, text/xml; q=0");

	negociate ("Accept", "text/html", () => {}) (req, res, () => {
		assert_not_reached ();
	}, stack);

	negociate ("Accept", "text/xml", () => {
		assert_not_reached ();
	}) (req, res, () => {}, stack);

	negociate ("Accept-Encoding", "utf-8", () => {
		assert_not_reached ();
	}) (req, res, () => {}, stack);
}


