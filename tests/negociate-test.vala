using Valum;
using VSGI.Mock;

/**
 * @since 0.3
 */
public void test_negociate () {
	var req   = new Request (new Connection (), "GET", new Soup.URI ("http://localhost/"));
	var res   = new Response (req);

	req.headers.append ("Accept", "text/html; q=0.9, text/xml; q=0");

	negociate ("Accept", "text/html", () => { return true; }) (req, res, () => {
		assert_not_reached ();
	}, new Context ());

	negociate ("Accept", "text/xml", () => {
		assert_not_reached ();
	}) (req, res, () => { return true; }, new Context ());

	negociate ("Accept-Encoding", "utf-8", () => {
		assert_not_reached ();
	}) (req, res, () => { return true; }, new Context ());
}


