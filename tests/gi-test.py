import unittest
from gi.repository import GLib, Soup, VSGI

class App(VSGI.Handler):
    def do_handle(self, req, res):
        return res.expand_utf8('Hello world!')

class GiTest(unittest.TestCase):
    def test_handler(self):
        app = App()

        req = VSGI.Request(uri=Soup.URI.new("http://localhost:3003/"))
        res = VSGI.Response(request=req)

        self.assertTrue(app.handle(req, res))
        payload = req.get_connection().get_output_stream().steal_as_bytes().get_data()
        self.assertTrue(payload.endswith(b'Hello world!'))

if __name__ == '__main__':
    unittest.main()
