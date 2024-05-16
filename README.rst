gendoc
======

This is a tool to generate the docs for all packages in the Dylan package
catalog. How it works, in a nutshell:

* Load the package catalog.
* Download each package to a temp directory.
* Rename ``<pkg>/documentation/source/*`` to
  ``documentation/source/package/<pkg>/*`` so that URLs will look like
  ``/package/<pkg>/*``.
* Modify ``docs/source/index.rst`` to list each package in the top-level
  ``toctree`` directive.

.. note:: The "docs" subdirectory in this repository is intentionally not named
          "documentation" in order to prevent gendoc itself from showing up in
          the package catalog since it has no documentation other than this
          README.

Usage
-----

To generate package ``.rst`` files in the right place::

   $ cd opendylan
   $ dylan update
   $ dylan build package-doc-generator
   $ _build/bin/package-doc-generator documentation/source/index.rst

See the main Open Dylan :file:`documentation/README.rst` for details on how to
build the full website including the package docs.
