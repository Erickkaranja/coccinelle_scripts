@@
identifier lbl;
expression E, E1;
@@
-mutex_lock(E1);
+guard(mutex)(E1);
<... when != mutex_unlock(E1);
if(...) {
...
-goto lbl;
+ return E;
}
...>
-lbl:
- mutex_unlock(E1);
  return E;
