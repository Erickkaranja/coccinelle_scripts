@unbraced_if@
identifier lbl;
expression E;
@@

if(E)
+{
goto lbl;
+}


@gt_bad_break exists@
expression E;
iterator I;
position p;
identifier virtual.lock;
identifier virtual.unlock;
@@
(
I(...){
  <...
  lock@p(E, ...);
   ... when != unlock(E, ...);
       when any
(
    {
       ...
       unlock(E, ...);
       ... when any
       break;
    }
|

break;
)
   ...>
}

 
|

for(...; ...; ...){
   <...
   lock@p(E, ...);
   ... when != unlock(E, ...);
       when any
(
     {
       ...
       unlock(E, ...);
       ... when any
       break;
     }
|

break;
)
   ...>
}

|

while(...) {
 <...
 lock@p(E, ...);
 ... when != unlock(E, ...);
     when any
(
    {
     ...
     unlock(E, ...);
     ... when any
     break;
    }
|
break;
)
 ...>
}
)

@gt_lock_order@
expression E;
position lp != gt_bad_break.p;
position up;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@lp(E, ...);
... when strict
unlock@up(E, ...);

@script:python@
up << gt_lock_order.up;
lp << gt_lock_order.lp;

@@

for i in range(len(up)):
    if int(lp[0].line) > int(up[i].line):
        cocci.include_match(False)
        break

@gt_lock_order_2@
expression E;
position p;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@p(E, ...);
... when exists
    unlock(E, ...);
...
lock(E, ...);

@script:python@
p << gt_lock_order_2.p;

@@
if p:
   cocci.include_match(False)

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
@script:python@
p << goto_unlock.p;
@@
print(f"{p[0].file} --- {p[0].line} goto matched a statement")

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

@gt_early_unlock@
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
position gt_early_unlock.p;
identifier lbl, lbl_2;
position px != gt_early_unlock.p3;
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

if(...){
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

if(...){
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

@clean_up@
expression unbraced_if.E;
identifier unbraced_if.lbl;
@@
(
if(E)
-{
goto lbl;
-}

|

if(E)
-{
return ...;
-}
)
