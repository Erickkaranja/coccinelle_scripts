@@
expression E;
iterator I;
@@
*mutex_lock(E);
... I(...) {
     ...
     break;
    }
...
*mutex_unlock(E);
