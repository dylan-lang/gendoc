gendoc
======

This is a tool to generate the complete Dylan library reference from all the
libraries in the Dylan catalog, ultimately replacing most or all of
[the current library reference](http://opendylan.org/documentation/library-reference).

Why?  Because it shouldn't be necessary to include your library docs in the
Open Dylan repository or the [opendylan.org
repo](https://github.com/dylan-lang/website) in order to have them
published. You should be able to make a package, write docs, and get it added
to the shared documentation pages.

There are two problems:

1.  Not all libraries in the catalog have docs. We should fix that!

2.  Some docs (e.g., [logging](https://github.com/dylan-lang/logging)) are in
    the Open Dylan repo instead of in their own repo. We _will_ fix that.

Usage
-----

The Sphinx project files (conf.py, Makefile, etc.) already exist in the
"source" subdirectory. `gendoc` just does two things:

1.  Creates a `source/libraries` subdirectory and populates it with all the
    packages in the Dylan catalog that have documentation. (This list is
    hard-coded...update it and rebuild if necessary.)

2.  Creates `source/index.rst` with a set of `:toctree:` directives that
    arrange the libraries into categories.

It is up to you to run `make html` and verify that everything is correct.

If this whole thing pans out it will be more fully automated by adding the
appropriate metadata about the existence of documentation to the catalog.
