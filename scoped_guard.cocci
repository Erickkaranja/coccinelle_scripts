@r exists@
expression E;
identifier label;
@@

* mutex_lock(E);
  ... goto label;
  ...
mutex_unlock(E);
