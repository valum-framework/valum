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

    ./waf configure --enable-gcov
    ./waf build
    ./build/tests/tests

During the execution of the tests, some files will be generated and can be
inspected with the ``gcov`` utility.

.. code-block:: bash

    cd build
    gcov src/router.c.1.gcda

::

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
