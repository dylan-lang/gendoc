.. dylan-libraries documentation master file, created by
   sphinx-quickstart on Sun May  8 04:41:10 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Dylan Library and Tool Reference
================================

Documentation for all libraries in the Dylan package catalog.

.. To be documented: anaphora, atom-language-dylan, base64, command-interface,
   json, mime, pacman-catalog, peg-parser, priority-queue, sequence-stream,
   serialization, shootout, skip-list, slot-visitor, sphinx-extensions (tools),
   uncommon-dylan, uri, uuid, web-framework, wrapper-streams, xml-parser,
   xml-rpc, zlib

.. To be moved out of OD: collection-extensions, command-line-parser,
   dylan-emacs-support (under tools), hash-algorithms, lisp-to-dylan (tools),
   logging, lsp-dylan (tools), regular-expressions, strings, vscode-dylan
   (tools)

.. Move testworks docs out of user-guide subdirectory

.. toctree::
   :maxdepth: 1
   :caption: Testing:

   libraries/binary-data/documentation/source/index
   libraries/concurrency/documentation/source/index
   libraries/http/documentation/source/index
   libraries/meta/documentation/source/index
   libraries/testworks/documentation/users-guide/source/index
   libraries/uuid/documentation/source/index

.. toctree::
   :maxdepth: 1
   :caption: Tools:

   libraries/melange/documentation/source/index
   libraries/dylan-tool/documentation/source/index
   sphinx-extensions/sphinxcontrib/dylan/domain/reference

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
