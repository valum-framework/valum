using Valum;

/**
 * TODO: test captures extraction
 */
public void test_valum_route_new () {}

public void test_valum_route_from_rule () {
	var router = new Router ();

	var route = new Route.from_rule (router, "<int:id>", (req, res) => {});
	assert ("^(?<id>\\d+)$" == route.regex.get_pattern ());

	route = new Route.from_rule (router, "<id>", (req, res) => {});
	assert ("^(?<id>\\w+)$" == route.regex.get_pattern ());

	route = new Route.from_rule (router, "<any:id>", (req, res) => {});
	assert ("^(?<id>.+)$" == route.regex.get_pattern ());
}

/**
 * TODO: test parameters extraction
 */
public void test_route_fire () {}
