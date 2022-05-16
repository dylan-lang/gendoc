Module: dylan-user

define library gendoc-lib
  use command-line-parser;
  use common-dylan;
  use dylan-tool-lib,
    import: { pacman };
  use io,
    import: { format-out };
  use logging;

  export
    gendoc-impl;
end;

define module gendoc-impl
  use command-line-parser;
  use common-dylan;
  use format-out;
  use logging;
  use pacman,
    prefix: "pm/";
  export
    main;
end;
