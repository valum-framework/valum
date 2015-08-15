Configuration
=============

 - add command line options
 - read a configuration file
 - use GSettings


GSettings
---------

GSettings is a good approach to store configuration.

 - declare available settings in a XML schema
 - monitor changes

.. code:: vala

    var configuration = new Settings ("org.valum.example.App");

    configuration.changed.connect ((key) => {

    });

GSettings over DBus

::

    [node storing configuration]
