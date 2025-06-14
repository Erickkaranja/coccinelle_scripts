@@
identifier E;
@@

(
mutex_lock(E);
...
*mutex_unlock(E);
}
|
mutex_lock(E);
...
*mutex_unlock(E);
return ...;
}
