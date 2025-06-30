@r1@
expression E;
@@
mutex_lock(E);

@badr1@
expression r1.E;
position p;

@@
if(...) { ...mutex_unlock@p(E);... }

@r2 depends on badr1@
expression r1.E;

@@

- mutex_lock(E);
+ scoped_guard(E) {
...
- mutex_unlock(E);
...
- mutex_unlock(E);
+}
