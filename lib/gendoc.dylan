Module: gendoc-impl


define constant $gendoc-command-line
  = make(<command-line-parser>,
         help: "Generate docs for packages in the Dylan catalog");

define function main
    (name :: <string>, args :: <sequence>) => (status :: false-or(<integer>))
  let parser = $gendoc-command-line;
  block ()
    parse-command-line(parser, application-arguments());
    execute-command(parser);
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
