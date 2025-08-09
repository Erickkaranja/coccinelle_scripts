
@sg_initial_lock@
expression E;
identifier virtual.lock;
identifier virtual.unlock;

@@
lock(E, ...);

/*Ensure a strict lock and unlock order
  lock should always come before the unlock
*/

@lock_unlock_order@
expression sg_initial_lock.E;
position lp, up;
identifier virtual.lock;
identifier virtual.unlock; 
@@
lock@lp(E, ...);
... when strict
unlock@up(E, ...);

@script:python@
up << lock_unlock_order.up;
lp << lock_unlock_order.lp;

@@

for i in range(len(up)):
    if int(lp[0].line) > int(up[i].line):
        cocci.include_match(False)
        break

@lock_unlock_order_2@
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
p << lock_unlock_order_2.p;

@@
if p:
   cocci.include_match(False)

//Identify early unlock which will help
//isolate them from the last unlock

@sg_early_unlock@
expression sg_initial_lock.E;
position p;
identifier virtual.lock;
identifier virtual.unlock;

@@
if(...) { ...unlock@p(E, ...); ... return ...; }

@sg_early_unlock_2@
expression sg_initial_lock.E;
position p;
identifier virtual.lock;
identifier virtual.unlock;

@@
if(...) { ...unlock@p(E, ...); continue; }

@sg_early_unlock_3@
expression sg_initial_lock.E;
position p;
identifier label;
identifier virtual.lock;
identifier virtual.unlock;

@@
if(...) { ...unlock@p(E, ...);  goto label; }

@sg_early_unlock_4@
expression sg_initial_lock.E;
position p;
identifier virtual.lock;
identifier virtual.unlock;
@@
switch(...) {
  case ...: {...}
  ...
  default:
  ...
  unlock@p(E, ...);
  return ...;
}

/*
  Identify the last unlock position which
  should be different from the early_unlocks
*/

@sg_last_unlock@
expression sg_initial_lock.E;
position p != {sg_early_unlock.p, sg_early_unlock_2.p,
               sg_early_unlock_3.p, sg_early_unlock_4.p};
position lock_unlock_order.lp, lock_unlock_order.up;
identifier virtual.lock;
identifier virtual.unlock;

@@

lock@lp(E, ...);
 ... 
unlock@up@p(E, ...);

/*
  Transform lock/unlock order to 
  scoped_guard
*/

@s_g@
expression sg_initial_lock.E;
position sg_last_unlock.p, lock_unlock_order.lp;
identifier label;
identifier virtual.lock;
identifier virtual.unlock;
identifier virtual.lock_type;
@@
+scoped_guard(lock_type, E) {
-lock@lp(E, ...);
<...
(
   if(...)
-   {   
-    unlock(E, ...); 
     return ...; 
-  }

|

   if(...) { ... 
-    unlock(E, ...);
     return ...; 
  }

|

   if(...)
-   {   
-    unlock(E, ...);
     continue;
-   }

|
  if(...)
    {
     ...
-    unlock(E, ...);
     continue;
    }

|

  if(...)
-   {
-    unlock(E, ...);
     goto label;
-   }
|

  if(...)
    {
     ...
-    unlock(E, ...);
     goto label;
    }
|
 switch(...) {
 case ...:
 ...
 default:
   ...
-  unlock(E, ...);
 return ...;
 }
)   
  ...>
-unlock@p(E, ...);
+}
