using Markdown;
using Valum;
using VSGI.Soup;

var app = new Router ();

app.get ("", (req, res) => {
	var doc = new Document.from_string ("# Hello world!".data, DocumentFlags.EMBED);
	doc.compile (DocumentFlags.EMBED);
	string markdown;
	doc.document (out markdown);
	res.body.write_all (markdown.data, null);
});

new Server ("org.valum.example.Markdown", app.handle).run ();
