using Valum;
using VSGI.HTTP;

class Mailer : Object {

	public bool send (string to, string subject, Bytes body) {
		// TODO: this is just an example
		return true;
	}
}

var app = new Router ();

app.use ((req, res, next, ctx) => {
	ctx.register ("org.mail.Mailer", new Mailer ());
	next (req, res);
});

app.get ("", (req, res, next, ctx) => {
	var mailer = ctx.resolve ("org.mail.Mailer") as Mailer;
	if (mailer.send ("johndoe@example.com", "Hey!", new Bytes.take ("How have you been?".data))) {
		res.body.write_all ("You mail was successfully sent!".data, null);
	}
});

new Server ("org.valum.example.Service", app.handle).run ();
