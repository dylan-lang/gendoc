Module: dylan-user

define library gendoc-lib-test-suite
  use common-dylan;
  use gendoc-lib;
  use testworks;
end;

define module gendoc-lib-test-suite
  use common-dylan;
  use gendoc-impl;
  use testworks;
end;
