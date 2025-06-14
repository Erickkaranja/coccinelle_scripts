//replace calls to mutex_lock and mutex_unlock
//with scoped_guard.

@r1@
expression E;
@@
mutex_lock(E);

@r2@
expression r1.E;
statement s;
@@

-mutex_lock(E);
+scoped_guard(E)
s
-mutex_unlock(E);

@badr1@
expression r1.E;
position p;

@@
if(...) {... mutex_unlock@p(E); ...}

@badr2@
expression r1.E;
position p;
identifier label;

@@
label: ... mutex_unlock@p(E); ...

@r3@
expression r1.E;
position p != {badr1.p, badr2.p};
@@

- mutex_lock(E);
+ guard(mutex)(E);
... 
-mutex_unlock@p(E);
return ...;

@r4@
expression r1.E;
position p != {badr1.p, badr2.p};
@@

+scoped_guard(E) {
-mutex_lock(E);
...
-mutex_unlock@p(E);
+}
...
