/*
 * This file is part of Valum.
 *
 * Valum is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * Valum is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Valum.  If not, see <http://www.gnu.org/licenses/>.
 */

using Valum;
using VSGI.Soup;

var app = new Router ();

var openweathermap = new Soup.Session ();

openweathermap.prefetch_dns ("api.openweathermap.org", null, null);

openweathermap.authenticate.connect ((msg, auth) => {
    auth.authenticate ("client_id", "secret_id");
});

app.get ("", (req, res) => {
	var tpl = new View.from_string ("""
    <h1>Weather in Montreal</h1>
    <dl>
	  <dt>Humidity</dt><dd>{humidity}%</dd>
	  <dt>Pressure</dt><dd>{pressure}hPa</dd>
	  <dt>Temperature</dt><dd>{temp}°C</dd>
	  <dt>Max</dt><dd>{temp_max}°C</dd>
	  <dt>Min</dt><dd>{temp_min}°C</dd>
    </dl>
	""");

	openweathermap.send_async.begin (new Soup.Message ("GET", "http://api.openweathermap.org/data/2.5/weather?q=Montreal&units=metric"),
	                                 null,
	                                 (obj, result) => {
		var parser = new Json.Parser ();

		parser.load_from_stream (openweathermap.send_async.end (result));

		var root = parser.get_root ().get_object ();

		root.get_object_member ("main").foreach_member ((obj, member_name, member_node) => {
			tpl.environment.push_float (member_name, member_node.get_double ());
		});

		tpl.to_stream (res.body);
	});
});

new Server ("org.valum.example.WeatherAPI", app.handle).run ();
