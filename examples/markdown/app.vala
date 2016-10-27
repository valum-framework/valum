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

using Markdown;
using Valum;
using VSGI;

var app = new Router ();

app.get ("/", (req, res) => {
	var doc = new Document.from_string ("# Hello world!".data, DocumentFlags.EMBED);
	doc.compile (DocumentFlags.EMBED);
	string markdown;
	doc.document (out markdown);
	return res.expand_utf8 (markdown);
});

Server.@new ("http", handler: app).run ();
