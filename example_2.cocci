@r1@
expression E;
position p;
@@
* mutex_lock(E);
... when != mutex_unlock(E);
{ ...
mutex_unlock@p(E);
...
 break;
}
