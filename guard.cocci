//safe handling scoped_guard transformation.
//replace calls to mutex_lock and mutex_unlock
//with scoped_guard.

//bad break positions which on replacing with
//guard alters the break inteded use.

@bad_break exists@
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

@script:python@
p << bad_break.p;
@@
print(f"could not transform the node at line {p[0].line} in the file{p[0].file} /
       this transformation could lead to unintended use of the break statement")


// Identify initial lock
@r@
expression E;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock(E, ...);


// Handle a single Expression between lock and unlock.

@r2@
expression r.E, E1;
identifier virtual.lock_type;
identifier virtual.lock;
identifier virtual.unlock;
@@
-lock(E, ...);
+scoped_guard(lock_type, E)
E1;
-unlock(E, ...);

//Exclude nodes with reverse lock order

@lock_order@
expression r.E;
position lp != bad_break.p;
position up;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@lp(E, ...);
... when strict
unlock@up(E, ...);

@script:python@
up << lock_order.up;
lp << lock_order.lp;

@@

for i in range(len(up)):
    if int(lp[0].line) > int(up[i].line):
        cocci.include_match(False)
        break

@lock_order_2@
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
p << lock_order_2.p;

@@
if p:
   cocci.include_match(False)

//------------------------------------
//Locate early unlocks

@early_unlock@
expression r.E;
position p, lock_order.up;
identifier virtual.unlock;

@@
if(...) { ...unlock@up@p(E, ...); ... return ...; }

@early_unlock_2@
expression r.E;
position p, lock_order.up;
identifier virtual.unlock;

@@
if(...) { ...unlock@up@p(E, ...); continue; }

@early_unlock_3@
expression r.E;
position p, lock_order.up;
identifier label;
identifier virtual.unlock;
@@
if(...) { ...unlock@up@p(E, ...);goto label; }

@early_unlock_4@
expression r.E;
position p, lock_order.up;
identifier virtual.unlock;

@@
switch(...) {
  case ...: {...}
  default:
  ...
  unlock@up@p(E, ...);
  return ...;
}

@r3@
expression r.E;
position p != {early_unlock.p, early_unlock_2.p,
               early_unlock_3.p, early_unlock_4.p};
position lock_order.lp, lock_order.up;
identifier virtual.lock;
identifier virtual.unlock;
@@

lock@lp(E, ...);
 ...
unlock@up@p(E, ...);


@r4@
expression r.E;
position r3.p, lock_order.lp;
identifier virtual.lock;
identifier virtual.unlock;
identifier virtual.lock_type;
@@

- lock@lp(E, ...);
+ guard(lock_type)(E);
<...
(
 if(...)
-  { 
-  unlock(E, ...);
   return ...; 
-  }
|
 if(...) { ... 
-  unlock(E, ...);
   return ...; }
|
switch(...) {
  case ...: {...}
  default:
    ...
-    unlock(E, ...);
    return ...;
}
)
 ...>
-unlock@p(E, ...);
return ...;
