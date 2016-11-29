import unittest
from gi.repository import VSGI

class App(VSGI.Handler):
    def handle(self, req, res):
        return res.expand_utf8('Hello world!')

class GiTest(unittest.TestCase):
    def test_handler(self):
        app = App()

        req = VSGI.Request()
        res = VSGI.Response(request=req)

        print(type(req.get_connection().get_output_stream().get_data()))
        self.assertTrue(app.handle(req, res))
        self.assertEqual('Hello world!',
                str(req.get_connection().get_output_stream().steal_data_as_bytes()))

if __name__ == '__main__':
    unittest.main()
