using Valum;
using Valum.ContentNegotiation;
using VSGI.Test;

/**
 * @since 0.3
 */
public void test_content_negotiation_negotiate () {
	var req   = new Request (new Connection (), "GET", new Soup.URI ("http://localhost/"));
	var res   = new Response (req);
	var stack = new Queue<Value?> ();

	req.headers.append ("Accept", "text/html; q=0.9, text/xml; q=0");

	negotiate ("Accept", {"text/html"}, (req, res, next, stack, content_type) => {
		assert ("text/html" == content_type);
	}) (req, res, () => {
		assert_not_reached ();
	}, stack);

	// explicitly refuse the content type with 'q=0'
	negotiate ("Accept", {"text/xml"}, () => {
		assert_not_reached ();
	}) (req, res, () => {}, stack);

	negotiate ("Accept", {"application/octet-stream"}, () => {
		assert_not_reached ();
	}) (req, res, () => {}, stack);

	// header is missing, so forward unconditionnaly
	assert (null == req.headers.get_one ("Accept-Encoding"));
	negotiate ("Accept-Encoding", {"utf-8"}, () => {
		assert_not_reached ();
	}) (req, res, () => {}, stack);
}

/**
 * @since 0.3
 */
public void test_content_negotiation_negotiate_final () {
	var req   = new Request (new Connection (), "GET", new Soup.URI ("http://localhost/"));
	var res   = new Response (req);
	var stack = new Queue<Value?> ();

	req.headers.append ("Accept", "text/html; q=0.9, text/xml; q=0");

	var reached = false;
	try {
		negotiate ("Accept", {"application/octet-stream"}, () => {
			assert_not_reached ();
		}, NegotiateFlags.FINAL) (req, res, () => {}, stack);
	} catch (ClientError.NOT_ACCEPTABLE err) {
		reached = true;
	}
	assert (reached);
}

/**
 * @since 0.3
 */
public void test_content_negotiation_accept () {
	var req   = new Request (new Connection (), "GET", new Soup.URI ("http://localhost/"));
	var res   = new Response (req);
	var stack = new Queue<Value?> ();

	req.headers.append ("Accept", "text/*");
	req.headers.append ("Accept-Encoding", "*");

	accept ({"text/html"}, (req, res, next, stack, content_type) => {
		assert ("text/html" == content_type);
	}) (req, res, () => {
		assert_not_reached ();
	}, stack);
	assert ("text/html" == res.headers.get_content_type (null));

	accept ({"text/xml"}, (req, res, next, stack, content_type) => {
		assert ("text/xml" == content_type);
	}) (req, res, () => {
		assert_not_reached ();
	}, stack);
	assert ("text/xml" == res.headers.get_content_type (null));

	accept ({"application/json"}, () => {
		 assert_not_reached () ;
	}) (req, res, () => {}, stack);
}


