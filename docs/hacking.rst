Hacking
=======

This document addresses hackers who wants to get involved in the framework
development.

Code conventions
----------------

Valum uses the `Vala compiler coding style`_ and these rules are specifically
highlighted:

-  tabs for indentation
-  spaces for alignment
-  80 characters for comment block and 120 for code
-  always align blocks of assignation around ``=`` sign
-  remember that little space between a function name and its arguments
-  doclets should be aligned, grouped and ordered alphabetically

.. _Vala compiler coding style: https://wiki.gnome.org/Projects/Vala/Hacking#Coding_Style

General strategies
------------------

Produce minimal headers, especially if the response has an empty body as every
byte will count.

Since ``GET`` handle ``HEAD`` as well, verifying the request method to prevent
spending time on producing a body that won't be considered is important.

::

    res.headers.set_content_type ("text/html", null);

    if (req.method == "HEAD") {
        size_t bytes_written;
        return res.write_head (out bytes_written);
    }

    return res.expand_utf8 ("<!DOCTYPE html><html></html>");

Use the ``construct`` block to perform post-initialization work. It will be
called independently of how the object is constructed.

Tricky stuff
------------

Most of HTTP/1.1 specification is case-insensitive, in these cases,
:valadoc:`libsoup-2.4/Soup.str_case_equal` must be used to perform comparisons.

Try to stay by the book and read carefully the specification to ensure that the
framework is semantically correct. In particular, the following points:

-  choice of a status code
-  method is case-sensitive
-  URI and query are automatically decoded by :valadoc:`libsoup-2.4/Soup.URI`
-  headers and their parameters are case-insensitive
-  ``\r\n`` are used as newlines
-  do not handle ``Transfer-Encoding``, except for the libsoup-2.4
   implementation with ``steal_connection``: at this level, it's up to the HTTP
   server to perform the transformation

The framework should rely as much as possible upon libsoup-2.4 to ensure
consistent and correct behaviours.

Coverage
--------

`gcov`_ is used to measure coverage of the tests on the generated C code. The
results are automatically uploaded to `Codecov`_ on a successful build.

You can build Valum with coverage by passing the ``-D b_coverage`` flag during
the configuration step.

.. _gcov: http://gcc.gnu.org/onlinedocs/gcc/Gcov.html
.. _Codecov: https://codecov.io/gh/valum-framework/valum

.. code-block:: bash

    meson -D b_coverage=true
    ninja test
    ninja coverage-html

Once you have identified an uncovered region, you can supply a test that covers
that particular case and submit us a `pull request on GitHub`_.

.. _pull request on GitHub: https://github.com/valum-framework/valum/pulls

Tests
-----

Valum is thoroughly tested for regression with the :valadoc:`glib-2.0/GLib.Test`
framework. Test cases are annotated with ``@since`` to track when a behaviour
was introduced and guarantee its backward compatibility.

You can refer an issue from GitHub by calling ``Test.bug`` with the issue
number.

::

    Test.bug ("123");

Version bump
------------

Most of the version substitutions is handled during the build, but some places
in the code have to be updated manually:

-   ``version`` and ``api_version`` variable in ``meson.build``
-   GIR version annotations for all declared namespaces
-   ``version`` and ``release`` in ``docs/conf.py``

