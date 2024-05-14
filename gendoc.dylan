Module: gendoc

/* To be documented: anaphora, atom-language-dylan,
   collection-extensions, command-interface, dylan-emacs-support, json,
   lisp-to-dylan, mime, pacman-catalog, peg-parser, priority-queue,
   sequence-stream, serialization, shootout, skip-list, slot-visitor,
   sphinx-extensions (tools), uncommon-dylan, uri, uuid, vscode-dylan,
   web-framework, wrapper-streams, xml-parser, xml-rpc, zlib

  skip-list has some docs in the Hackers Guide, used as example doc.

 */

define command-line <gendoc-command-line> ()
  option index-file :: <string>,
    names: #("index-file"),
    help: "Pathname to the package/index.rst file in the opendylan repository checkout."
            " This file will be modified to contain the package docs.",
    kind: <positional-option>;
end;

define function main
    (name :: <string>, args :: <sequence>) => (status :: false-or(<integer>))
  let parser = make(<gendoc-command-line>,
                    help: "Generate docs for packages in the Dylan catalog");
  block ()
    parse-command-line(parser, application-arguments());
    gendoc(as(<file-locator>, parser.index-file))
  exception (err :: <abort-command-error>)
    let status = exit-status(err);
    if (status ~= 0)
      io/format-err("Error: %s\n", err);
    end;
    status
  end
end function;

define function gendoc
    (root-index-file :: <file-locator>)
  dynamic-bind (deft-*verbose?* = #t)
    let packages = fetch-packages(root-index-file.locator-directory);
    let template = fs/with-open-file(stream = root-index-file)
                     io/read-to-end(stream)
                   end;
    let body = generate-body-rst(packages);
    let toctree = generate-toctree-rst(packages);
    fs/with-open-file(stream = root-index-file,
                      direction: #"output", if-exists?: #"replace")
      // Be careful to write the markers back out to the file so that this code
      // is idempotent. (Which is why the markers are RST comments.)
      iterate loop (lines = as(<list>, split-lines(template)), drop-lines? = #f)
        if (~empty?(lines))
          let line = lines.head;
          if (drop-lines?)
            let keep? = starts-with?(line, ".. end-");
            loop(if (keep?) lines else lines.tail end, ~keep?)
          else
            io/format(stream, "%s\n", line);
            select (line by \=)
              ".. begin-body" =>
                io/write(stream, body);
                loop(lines.tail, #t);
              ".. begin-toctree" =>
                io/write(stream, toctree);
                loop(lines.tail, #t);
              otherwise =>
                loop(lines.tail, #f);
            end;
          end;
        end;
      end iterate;
    end;
    io/format-out("Generated docs for %d packages.\n", packages.size);
  end;
end function;

define function generate-body-rst
    (packages :: <sequence>) => (body :: <string>)
  io/with-output-to-string (stream)
    io/format(stream, "\n");    // Need blank line after ".. begin-body" comment.
    for (package in packages)
      let pkg-name = package.pm/package-name;
      io/format(stream, "* :doc:`%s <%s/index>`", pkg-name, pkg-name);
      let description = package.pm/package-description;
      if (description)
        // Remove newlines so the reST is valid.
        io/format(stream, " - %s", join(split-lines(description), " "));
      end;
      io/format(stream, "\n");
    end;
    io/format(stream, "\n");    // Need blank line before ".. end-body" comment.
  end
end function;

define function generate-toctree-rst
    (packages :: <sequence>) => (toctree :: <string>)
  io/with-output-to-string (stream)
    io/format(stream, """

                      .. toctree::
                         :hidden:
                         :maxdepth: 1
                         :caption: Packages\n\n
                      """);
    for (package in packages)
      let pkg-name = package.pm/package-name;
      io/format(stream, "   %s <%s/index>\n", pkg-name, pkg-name);
    end;
    io/format(stream, "\n");    // Need blank line before ".. end-toctree" comment.
  end
end function;

// Fetch all packages in the pacman catalog. In order to simplify the
// documentation URLs to just /package/<pkg>/<name>.html we remove the
// documentation/source/ part of the URL by downloading to a temp directory and
// renaming all doc files in documentation/source/ to the package subdirectory
// where docs will be generated.
define function fetch-packages
    (package-dir :: <directory-locator>) => (packages :: <sequence>)
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

    // For DPG, source/index.rst. For others, documentation/source/index.rst
    iterate loop (files = list(file-locator(scratch-subdir, "source", "index.rst"),
                               file-locator(scratch-subdir, "documentation", "source", "index.rst")))
      if (empty?(files))
        io/format-out("%s: no documentation; skipping.\n", pkg-name);
      else
        let index = head(files);
        if (~fs/file-exists?(index))
          loop(tail(files))
        else
          add!(doc-packages, package);
          fs/ensure-directories-exist(package-subdir);
          let src-dir = index.locator-directory;
          for (file in fs/directory-contents(src-dir))
            let dest = merge-locators(relative-locator(file, src-dir),
                                      package-subdir);
            fs/rename-file(file, dest);
          end;
        end;
      end if
    end iterate;
    io/force-out();
  end;
  doc-packages
end function;

main(application-name(), application-arguments())
