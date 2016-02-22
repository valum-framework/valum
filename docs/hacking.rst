Hacking
=======

This document addresses hackers who wants to get involved in the framework
development.

Building
--------

You can avoid installing the library if you export ``LD_LIBRARY_PATH`` to the
``build`` folder.

.. code-block:: bash

    export LD_LIBRARY_PATH=build

    ./waf configure
    ./waf build

    ./build/tests/tests

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

Many parts of the HTTP/1.1 specification is case-insensitive, in these cases,
`Soup.str_case_equal`_ must be used to perform comparisons.

.. _Soup.str_case_equal: http://valadoc.org/#!api=libsoup-2.4/Soup.str_case_equal

Try to stay by the book and read carefully the specification to ensure that the
framework is semantically correct. In particular, the following points:

-  choice of a status code
-  method is case-sensitive
-  URI and query are automatically decoded by `Soup.URI`_
-  headers and their parameters are case-insensitive
-  ``\r\n`` are used as newlines
-  do not handle ``Transfer-Encoding``, except for the libsoup-2.4
   implementation with ``steal_connection``: at this level, it's up to the HTTP
   server to perform the transformation

.. _Soup.URI: http://valadoc.org/#!api=libsoup-2.4/Soup.URI

The framework should rely as much as possible upon libsoup-2.4 to ensure
consistent and correct behaviours.

Coverage
--------

`gcov`_ is used to measure coverage of the tests on the generated C code. The
results are automatically uploaded to `coveralls.io`_ with `coveralls-cpp`_ on
a successful build.

You can build Valum with gcov if you specify the ``--enable-gcov`` option
during the configuration.

.. _gcov: http://gcc.gnu.org/onlinedocs/gcc/Gcov.html
.. _coveralls.io: https://coveralls.io/r/valum-framework/valum
.. _coveralls-cpp: https://github.com/eddyxu/cpp-coveralls

.. code-block:: bash

    ./waf configure CFLAGS='-fprovide-arcs -ftest-coverage' VALAFLAGS='--debug'
    ./waf build
    ./build/tests/tests

During the execution of the tests, some files will be generated and can be
inspected with the ``gcov`` utility.

.. code-block:: bash

    cd build
    gcov src/router.c.1.gcda


Would output something like:

    File 'src/router.c'
    Executed lines: 57.83% of 792
    Creating 'router.c.gcov'

The generated ``router.c.gcov`` will contain detailed coverage information
structured in three columns separated by a ``:`` character:

-  number of executions
-  line number
-  corresponding line of code

The number of executions can take the following values:

-  a ``-`` symbol means that the line is irrelevant (eg. comment)
-  ``#####`` means that the line is uncovered
-  a positive integer indicates how many time the line has executed

Once you have identified an uncovered region, you can supply a test that covers
that particular case and submit us a `pull request on GitHub`_.

.. _pull request on GitHub: https://github.com/valum-framework/valum/pulls

Tests
-----

Valum is thoroughly tested for regression with the `GLib.Test`_ framework. Test
cases are annotated with ``@since`` to track when a behaviour was introduced
and guarantee its backward compatibility.

.. _GLib.Test: http://valadoc.org/#!api=glib-2.0/GLib.Test

You can refer an issue from GitHub by calling ``Test.bug`` with the issue
number.

::

    Test.bug ("123");

Version bump
------------

Most of the version substitutions is handled during the build, but some places
in the code have to be updated manually:

-   ``VERSION`` and ``API_VERSION`` in ``wscript``
-   GIR version annotations for all declared namespaces
-   ``version`` and ``release`` in ``docs/conf.py``

