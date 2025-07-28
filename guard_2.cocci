#include "guard.cocci"

@sg@
expression E;
identifier virtual.lock;
identifier virtual.unlock;

@@
lock(E, ...);

@goto_unlock_2 exists@
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

@badr4_2 exists@
expression E;
position goto_unlock_2.p;
position goto_unlock_2.p1;
position p2;
statement s;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@p1@p2(E, ...);
...
s@p

@cond_2@
expression sg.E;
position lp != badr4_2.p2, up;
identifier virtual.lock;
identifier virtual.unlock; 
@@
lock@lp(E, ...);
... when strict
unlock@up(E, ...);

@script:python@
up << cond_2.up;
lp << cond_2.lp;

@@

for i in range(len(up)):
    if int(lp[0].line) > int(up[i].line):
        cocci.include_match(False)
        break

@find_mutex_pattern_2@
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
p << find_mutex_pattern_2.p;

@@
if p:
   cocci.include_match(False)

@badr_2@
expression sg.E;
position p;
identifier virtual.lock;
identifier virtual.unlock;

@@
if(...) { ...unlock@p(E, ...); ... return ...; }

@badr1_2@
expression sg.E;
position p;
identifier virtual.lock;
identifier virtual.unlock;

@@
if(...) { ...unlock@p(E, ...); continue; }

@badr2_2@
expression sg.E;
position p;
identifier label;
identifier virtual.lock;
identifier virtual.unlock;

@@
if(...) { ...unlock@p(E, ...);  goto label; }

@badr3_2@
expression E;
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

@r4@
expression sg.E;
position p != {badr_2.p, badr1_2.p, badr2_2.p, badr3_2.p};
position cond_2.lp, cond_2.up;
identifier virtual.lock;
identifier virtual.unlock;

@@

lock@lp(E, ...);
 ... 
unlock@up@p(E, ...);

@r7@
expression sg.E;
position r4.p, cond_2.lp;
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
