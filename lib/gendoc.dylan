Module: gendoc-impl


// The directory into which packages are cloned.
define constant $packages-subdirectory = "packages";

// Each element takes one of two forms: (1) a string, in which case it's the
// name of a package that has one top-level document in the standard location,
// <repo>/documentation/source/index.rst, or (2) a <doc> instance.
define constant $libraries-to-document
  = vector("binary-data",
           "command-line-parser",
           "concurrency",
           "dylan-tool",
           "http",
           "logging",
           "melange",
           "sphinx-extensions",
           "strings",
           "testworks",
           "uuid");

/*
.. To be documented: anaphora, atom-language-dylan, base64, command-interface,
   json, mime, pacman-catalog, peg-parser, priority-queue, sequence-stream,
   serialization, shootout, skip-list, slot-visitor, sphinx-extensions (tools),
   uncommon-dylan, uri, uuid, web-framework, wrapper-streams, xml-parser,
   xml-rpc, zlib

.. To be moved out of OD: collection-extensions, command-line-parser,
   dylan-emacs-support (under tools), hash-algorithms, lisp-to-dylan (tools),
   lsp-dylan (tools), regular-expressions, strings, vscode-dylan
   (tools)

.. Move testworks docs out of user-guide subdirectory
*/

define command-line <gendoc-command-line> ()
  option source-directory :: <string>,
    names: #("source-directory", "o"),
    help: "Root directory of the generated output",
    kind: <parameter-option>,
    default: ".";
  option force-download? :: <boolean>,
    names: #("force", "f"),
    help: "Whether to force download of packages if already present",
    kind: <flag-option>,
    default: #f;
end;

define function main
    (name :: <string>, args :: <sequence>) => (status :: false-or(<integer>))
  let parser = make(<gendoc-command-line>,
                    help: "Generate docs for packages in the Dylan catalog");
  block ()
    parse-command-line(parser, application-arguments());
    let dir = as(<directory-locator>, source-directory(parser));
    gendoc(directory: dir, force?: force-download?(parser));
  exception (err :: <abort-command-error>)
    let status = exit-status(err);
    if (status ~= 0)
      format-err("Error: %s\n", err);
    end;
    status
  exception (err :: <error>)
    log-error("%s", condition-to-string(err));
  end
end function;

define class <doc> (<object>)
  constant slot doc-package-name :: <string>,
    required-init-keyword: name:;
  // Root docs are relative to the repository root. e.g.,
  // "documentation/source/user-guide/index.rst"
  constant slot doc-roots :: <sequence>,
    required-init-keyword: roots:;
  slot doc-package :: false-or(pm/<package>) = #f;
end class;

// Canonicalize the given document specs into <doc> objects with their
// doc-package slot filled in.
define function documents
    (#key document-specs = $libraries-to-document) => (docs :: <sequence>)
  let catalog = pm/catalog();
  map(method (spec)
        let doc = spec;
        if (instance?(spec, <string>))
          doc := make(<doc>,
                      name: spec,
                      roots: #["documentation/source/index.rst"]);
        end;
        doc-package(doc)
          := pm/find-package(catalog, doc-package-name(doc));
        doc
      end,
      document-specs)
end function;

define function gendoc
    (#key directory :: <directory-locator> = fs/working-directory,
          docs :: <sequence> = documents(),
          force? :: <boolean>)
  let package-dir = subdirectory-locator(directory, $packages-subdirectory);
  fetch-packages(docs, package-dir, force?);

  let index-file = merge-locators(as(<file-locator>, "index.rst"), directory);
  fs/with-open-file(stream = index-file,
                    direction: #"output", if-exists?: #"replace")
    gendoc-to-stream(stream, docs)
  end;
end function;

define function fetch-packages
    (docs :: <sequence>, directory :: <directory-locator>, force? :: <boolean>)
  for (doc in docs)
    let package = doc-package(doc);
    let release = %pm/find-release(package, pm/$latest);
    let pkg-dir = subdirectory-locator(directory, pm/package-name(package));
    if (force? & fs/file-exists?(pkg-dir))
      format-out("Deleting %s because --force was used.\n", pkg-dir);
      fs/delete-directory(pkg-dir);
    end;
    if (~fs/file-exists?(pkg-dir))
      fs/ensure-directories-exist(pkg-dir);
      pm/download(release, pkg-dir, update-submodules?: #f);
    end;
    force-out();
  end;
end function;

define function string-parser (s) => (s) s end;

define constant $header = #:string:"
********************************
Dylan Library and Tool Reference
********************************

Documentation for libraries in the Dylan package catalog.

.. note:: The documentation for some libraries is still part of the Open Dylan
   project, available `here <https://opendylan.org/documentation/library-reference>`_.
   Over time more of those library docs will be hosted here.

.. toctree::
   :maxdepth: 1
   :caption: Libraries

";

define constant $footer = #:string:"

Indices and tables
==================

* :ref:`genindex`
* :ref:`search`
";

define function gendoc-to-stream
    (stream :: <stream>, docs :: <sequence>)
  io/write(stream, $header);
  generate-table-of-contents-alphabetized(stream, docs);
  io/write(stream, $footer);
end function;

define function generate-table-of-contents-alphabetized
    (stream :: <stream>, docs :: <sequence>)
  let docs = sort(docs, test: method (a, b)
                                doc-package-name(a) < doc-package-name(b)
                              end);
  for (doc in docs)
    let pkg-name = doc-package-name(doc);
    for (path in doc-roots(doc))
      if (ends-with?(path, ".rst"))
        path := copy-sequence(path, end: path.size - ".rst".size);
      end;
      let pkg-name = doc-package-name(doc);
      // TODO: really want a way to include a one sentence description of the
      // package here, outside of the link text, and without it being included
      // in the left nav toctree, but Sphinx doesn't appear to be that
      // flexible.
      format(stream, "   %s <%s/%s/%s>\n",
             pkg-name,
             $packages-subdirectory, pkg-name, path);
    end for;
  end
end function;

/*
define function generate-table-of-contents-categorized
    (stream :: <stream>, docs :: <sequence>)
  let docs-by-category = make(<istring-table>);
  for (doc in docs)
    let package = doc-package(doc);
    let category = pm/package-category(package);
    let cat-docs = element(docs-by-category, category, default: #());
    docs-by-category[category] := pair(doc, cat-docs);
  end;
  for (category in sort(key-sequence(docs-by-category)))
    let cat-docs = docs-by-category[category];
    // TODO: there's no provision here for a single package having doc roots in
    // more than one category. Seems like it would be rare?
    format(stream, $toctree-template, category);
    for (doc in cat-docs)
      for (path in doc-roots(doc))
        if (ends-with?(path, ".rst"))
          path := copy-sequence(path, end: path.size - 4);
        end;
        let pkg-name = doc-package-name(doc);
        format(stream, "   %s <%s/%s/%s>\n",
               pkg-name, $packages-subdirectory, pkg-name, path);
      end for;
    end for;
  end for;
end function;

// Search for the first '.' that is < maxlen characters from the beginning. If
// not found, elide at the nearest whitespace.

// (Copied from dylan-tool as a quick hack...should be unified/moved to pacman.)
define method brief-description
    (package :: pm/<package>, #key maxlen = 90) => (_ :: <string>)
  let text = pm/package-description(package);
  if (text.size < maxlen)
    text
  else
    let space = #f;
    let pos = #f;
    iterate loop (p = min(text.size - 1, maxlen))
      case
        p <= 0         => #f;
        text[p] == '.' => pos := p + 1;
        otherwise      =>
          if (whitespace?(text[p]) & (~space | space == p + 1))
            space := p;
          end;
          loop(p - 1);
      end;
    end iterate;
    case
      pos => copy-sequence(text, end: pos);
      space => concatenate(copy-sequence(text, end: space), "...");
      otherwise => text;
    end
  end if
end method;
*/
