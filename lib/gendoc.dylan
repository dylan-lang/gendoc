Module: gendoc-impl


/* To be documented: anaphora, atom-language-dylan, base64,
   collection-extensions, command-interface, dylan-emacs-support, json,
   lisp-to-dylan, lsp-dylan, mime, pacman-catalog, peg-parser, priority-queue,
   sequence-stream, serialization, shootout, skip-list, slot-visitor,
   sphinx-extensions (tools), uncommon-dylan, uri, uuid, vscode-dylan,
   web-framework, wrapper-streams, xml-parser, xml-rpc, zlib

  skip-list has some docs in the Hackers Guide, used as example doc.

 */

// The directory into which package docs are generated, with a subdirectory
// for each package.  This is singular because it will show up in the URL
// lik this: .../package/http/
define constant $packages-subdirectory = "package";

define command-line <gendoc-command-line> ()
  option output-directory :: <string>,
    names: #("output-directory", "o"),
    help: "Root directory of the generated output",
    kind: <parameter-option>,
    default: ".";
end;

define function main
    (name :: <string>, args :: <sequence>) => (status :: false-or(<integer>))
  let parser = make(<gendoc-command-line>,
                    help: "Generate docs for packages in the Dylan catalog");
  block ()
    parse-command-line(parser, application-arguments());
    gendoc(as(<directory-locator>, output-directory(parser)))
  exception (err :: <abort-command-error>)
    let status = exit-status(err);
    if (status ~= 0)
      format-err("Error: %s\n", err);
    end;
    status
  end
end function;

define function gendoc
    (output-dir :: <directory-locator>)
  dynamic-bind (dt_*verbose?* = #t)
    let packages = fetch-packages(output-dir);
    let root-index-file = file-locator(output-dir, "index.rst");
    fs/with-open-file(stream = root-index-file,
                      direction: #"output", if-exists?: #"replace")
      io/write(stream, $header);
      generate-body-rst(stream, packages);

      io/write(stream, $toctree);
      generate-toctree-rst(stream, packages);
    end;
    format-out("Generated docs for %d packages.\n", packages.size);
  end;
end function;

define constant $header = """
******************
Dylan Package Docs
******************

Documentation for packages in the Dylan package catalog.

.. note:: The documentation for some packages is still part of the Open Dylan
   project, available in the `Library Reference
   <https://opendylan.org/documentation/library-reference>`_.  Over time more
   of those docs will be hosted here as they're moved into their own
   repositories.

""";

define constant $toctree = """
.. toctree::
   :hidden:
   :maxdepth: 1
   :caption: Packages

""";

define function generate-body-rst
    (stream :: <stream>, packages :: <sequence>)
  for (package in packages)
    let pkg-name = package.pm/package-name;
    format(stream, "* :doc:`%s/%s/index`", $packages-subdirectory, pkg-name);
    let description = package.pm/package-description;
    if (description)
      // Remove newlines so the reST is valid.
      format(stream, " - %s", join(split-lines(description), " "));
    end;
    format(stream, "\n");
  end;
end function;

define function generate-toctree-rst
    (stream :: <stream>, packages :: <sequence>)
  for (package in packages)
    let pkg-name = package.pm/package-name;
    format(stream, "   %s <%s/%s/index>\n",
           pkg-name, $packages-subdirectory, pkg-name);
  end;
end function;

// Fetch all packages in the pacman catalog. In order to simplify the
// documentation URLs we remove the documentation/source/ part of the URL by
// downloading to a temp directory and then renaming all files in
// documentation/source/ to the package subdirectory where docs will be
// generated.
define function fetch-packages
    (output-dir :: <directory-locator>) => (packages :: <sequence>)
  let package-dir = subdirectory-locator(output-dir, $packages-subdirectory);
  let all-packages
    = sort(pm/load-all-catalog-packages(pm/catalog()),
           test: method (a, b)
                   a.pm/package-name < b.pm/package-name
                 end);
  let doc-packages = make(<stretchy-vector>);
  let scratch-dir = subdirectory-locator(fs/working-directory(), "gendoc-scratch-dir");
  fs/ensure-directories-exist(package-dir);
  fs/ensure-directories-exist(scratch-dir);
  for (package in all-packages)
    let pkg-name = pm/package-name(package);
    let package-subdir = subdirectory-locator(package-dir, pkg-name);
    let scratch-subdir = subdirectory-locator(scratch-dir, pkg-name);
    if (fs/file-exists?(scratch-subdir))
      fs/delete-directory(scratch-subdir, recursive?: #t);
    end;
    if (fs/file-exists?(package-subdir))
      fs/delete-directory(package-subdir, recursive?: #t);
    end;
    let release = %pm/find-release(package, pm/$latest);
    pm/download(release, scratch-subdir, update-submodules?: #f);
    let source-dir = subdirectory-locator(scratch-subdir, "documentation", "source");
    if (~fs/file-exists?(source-dir))
      // TODO: Check for docs/source/ and doc/source/ as well.
      format-out("%s: no documentation; skipping.\n", pkg-name);
    else
      add!(doc-packages, package);
      fs/ensure-directories-exist(package-subdir);
      for (file in fs/directory-contents(source-dir))
        let dest = merge-locators(relative-locator(file, source-dir),
                                  package-subdir);
        fs/rename-file(file, dest);
      end;
    end;
    force-out();
  end;
  doc-packages
end function;
