from gi.repository import GLib, Gio, VSGI

class App(VSGI.Handler):
    def do_handle(self, req, res):
        res.get_headers().set_content_type("text/plain")
        return res.expand_utf8("Hello world!")

server = VSGI.Server("http")
server.set_handler(App())

server.listen(Gio.InetSocketAddress(address=Gio.InetAddress.new_loopback(family=Gio.SocketFamily.IPV4), port=3003))

GLib.MainLoop().run()
