Module: dylan-user

define library gendoc
  use common-dylan;
  use gendoc-lib;
  use system, import: { operating-system };
end;

define module gendoc
  use common-dylan;
  use gendoc-impl, import: { main };
  use operating-system;
end;
