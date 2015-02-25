This section covers how to deploy a FastCGI application written in Vala.

In order to test your application, you will need to spawn a FastCGI process and
setup a web server that can communicate with it.

FastCGI uses unix socket for bidirectional communication.

For testing, you can use
[lighthttpd spawn-fcgi](https://github.com/lighttpd/spawn-fcgi) utility along
with this [FastCGI server](https://github.com/iriscouch/fastcgi) written with
Node.js.

Valum use [Vala fcgi bindings](https://github.com/lighttpd/spawn-fcgi), so you
need to install the `fcgi` library. Both `spawn-fcgi` and `npm` should be found
in your distribution repository.

```bash
yum install fcgi spawn-fcgi npm     # Fedora
apt-get install fcgi spawn-fcgi npm # Ubuntu and Debian
npm install -G fastcgi
```

Once done, build valum examples, spawn a FastCGI process and start the FastCGI
web server.

```bash
./waf build
spawn-fcgi -n -s valum.socket -- build/examples/fastcgi/fastcgi
fastcgi --socket valum.socket --port 3003
```

Point your browser at [http://localhost:3000](http://localhost:3003) to see the
result!

Use this setup to test your application before the deployment. To develop, it is
generally more convenient to use the libsoup built-in HTTP server.

Technically, you end-up with a FastCGI executable, so deploying it on a specific
server is already documented.

## Apache

Under Apache, there are two mods available: `mod_fcgid` is more likely to be
available as it is part of Apache and `mod_fastcgi` is developed by those who
did the FastCGI specifications.

 - [mod_fcgid](http://httpd.apache.org/mod_fcgid/)
 - [mod_fastcgi](http://www.fastcgi.com/mod_fastcgi/docs/mod_fastcgi.html)

## Nginx

Nginx expect a process to be already spawned and will communicate with it using
a port.

## lighttpd

lighttpd spawn a process and communicate with it through a socket or a port.

An [example of configuration](https://github.com/valum-framework/valum/tree/master/examples/fastcgi/lighttpd.conf)
is providen to get you started.

```bash
lighttpd -D -f examples/fastcgi/lighttpd.conf
```
