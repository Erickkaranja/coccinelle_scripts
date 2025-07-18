@r@
expression E;
position p;
@@
switch (...) {
  case ...: { ... }
*  default:
    ... mutex_unlock@p(E);
        return ...;
}
