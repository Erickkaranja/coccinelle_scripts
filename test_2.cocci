//@r@
//expression E;
//position p;
//@@
//mutex_lock@p(E);
//...
//mutex_unlock(E);
//... when strict
//mutex_lock(E);

@find_mutex_pattern@
expression E;
position p;
@@
mutex_lock@p(E);
... when exists
    mutex_unlock(E);
...
mutex_lock(E);

@script:python@
p << find_mutex_pattern.p;

@@
if p:
   cocci.include_match(False);

@r@
expression E;
position p;
@@
mutex_lock@p(E);
...
-mutex_unlock(E);
