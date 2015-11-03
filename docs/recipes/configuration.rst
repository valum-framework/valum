Configuration
=============

Configuration can be handled in multiple different ways:

 - command line options
 - configuration file (JSON, YAML, ini)
 - through GSettings

GSettings
---------

GSettings is a good approach to store configuration as it integrates very well
with GLib-based software.

 - declare available settings in a XML schema
 - monitor changes on configuration keys

.. code:: vala

    var configuration = new Settings ("org.valum.example.App");

    configuration.changed.connect ((key) => {

    });

GSettings over DBus

::

    [node storing configuration]
