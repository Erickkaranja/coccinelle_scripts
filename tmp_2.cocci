@goto_unlock exists@
expression E;
identifier label;
position p;
position p1;
statement s;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@p1(E, ...);
... when != unlock(E, ...);
    goto label;
...
label:
(
    unlock(E, ...);
|
    s@p 
)

@badr4 exists@
expression E;
position p2;
position goto_unlock.p;
position goto_unlock.p1;
statement s;
identifier virtual.lock;
@@
lock@p1@p2(E, ...);
...
s@p

@r@
position p != badr4.p2;
position p3;
expression E;
position goto_unlock.p1;
identifier label;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@p@p1(E, ...);
... when != unlock(E, ...);
    when exists
goto label;
...
unlock@p3(E, ...);

@@
expression E, E1;
position r.p;
identifier lbl, lbl_2;
position px != r.p3;
identifier virtual.lock;
identifier virtual.unlock;
identifier virtual.lock_type;
@@
-lock@p(E, ...);
+scoped_guard(lock_type, E) {
<...
(
if(...) {
...
-goto lbl;
+return E1;
...
-lbl:
-unlock(E, ...);
-return E1;
}

|

if(...) {
...
-goto lbl;
+goto lbl_2; 
...
-lbl:
-unlock(E, ...);
lbl_2:
...
return E1; 
}

|

if(...)
  goto lbl;
...
-unlock(E, ...);
...
return ...;

|
if(...) {
...
goto lbl;
...
-unlock(E, ...);
...
return ...;
}

)
...>
-unlock@px(E, ...);
+}

@@
identifier lbl;
expression E, E1;
identifier virtual.lock;
identifier virtual.unlock;
identifier virtual.lock_type;
@@
-lock(E1);
+guard(lock_type)(E1);
<... when != unlock(E1);
if(...) {
...
-goto lbl;
+ return E;
}
...>
-lbl:
- unlock(E1);
  return E;
