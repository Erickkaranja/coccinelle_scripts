//safe handling scoped_guard transformation.
//replace calls to mutex_lock and mutex_unlock
//with scoped_guard.

/*
@@
expression E;
identifier virtual.lock;
identifier virtual.unlock;
@@
func(...){
... when any
?- unlock(E);
+unlock(E, end);
}

@@
expression E;
constant C;
identifier I;
identifier virtual.lock;
identifier virtual.unlock;
@@
func(...){
... when any
?- mutex_lock(E);
+mutex_lock(E, end);
return \(C\|I\);
}
 */

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

// Identify initial lock, may be a single lock
//or a double lock.
@r@
expression E, E2;
identifier virtual.lock;
identifier virtual.unlock;
@@
(
lock(E, ...);
... when != unlock(E, ...);
lock(E2, ...);
|
lock(E, ...);
)

//Handle sequential double locks of the same kind.

@r1@
expression r.E, r.E2;
identifier f;
identifier virtual.lock;
identifier virtual.unlock;
identifier virtual.lock_type;
@@
f(...) {
 ... when any
-lock(E, ...);
+guard(lock_type)(E);
... when != unlock(E);
-lock(E2);
+guard(lock_type)(E2);
<...
(
 if(...)
-  {
-  unlock(E2, ...);
-  unlock(E, ...); 
   return ...; 
-  }
|
 if(...) { ... 
-  unlock(E2, ...);
-  unlock(E, ...);
   return ...; }
)
 ...>
-unlock(E2, ...);
-unlock(E, ...);
return ...;
}

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

//Identify nodes with goto label between
//lock and unlock suitable for transformation.

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

@bad_goto exists@
expression E;
position goto_unlock.p;
position goto_unlock.p1;
position p2;
statement s;
identifier virtual.lock;
@@
lock@p1@p2(E, ...);
...
s@p

//Exclude nodes with reverse lock order

@lock_order@
expression r.E;
position lp != {bad_break.p ,bad_goto.p2};
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
position p != {early_unlock.p, early_unlock_2.p, early_unlock_3.p, early_unlock_4.p};
position lock_order.lp, lock_order.up;
identifier virtual.lock;
identifier virtual.unlock;
@@

lock@lp(E, ...);
 ...
unlock@up@p(E, ...);

@badr5 exists@
identifier label;
expression r.E;
position lock_order.lp;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@lp(E, ...);
 ... when != unlock(E, ...);
if (...) {
    ...
    goto label;
  }

@r5 depends on badr5@
position lock_order.lp, r3.p;
expression r.E;
position s_g != bad_goto.p2;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@s_g@lp(E, ...);
  ...
unlock@p(E, ...);
return ...;


@r4@
expression r.E;
position r3.p, lock_order.lp, r5.s_g;
identifier virtual.lock;
identifier virtual.unlock;
identifier virtual.lock_type;
@@
(
- lock@s_g(E, ...);
+ scoped_guard(lock_type, E) {
<...
(
 if(...)
-  {   
-  unlock(E, ...);
   return ...; 
-  }
|
 if(...) { ... 
-  lock(E, ...);
   return ...; }
)
 ...>
-unlock@p(E, ...);
+}
return ...;

|

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
)
