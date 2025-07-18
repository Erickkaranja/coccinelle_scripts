#include "mutex_lock.cocci"

@sg@
expression E;
@@
mutex_lock(E);

@goto_unlock_2 exists@
expression E;
identifier label;
position p;
position p1;
statement s;
@@
mutex_lock@p1(E);
... when != mutex_unlock(E);
    goto label;
...
label:
(
    mutex_unlock(E);
|
    s@p
)

@badr4_2 exists@
expression E;
position goto_unlock_2.p;
position goto_unlock_2.p1;
position p2;
statement s;
@@
mutex_lock@p1@p2(E);
...
s@p

@cond_2@
expression sg.E;
position lp != badr4_2.p2, up; 
@@
mutex_lock@lp(E);
... when strict
mutex_unlock@up(E);

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
@@
mutex_lock@p(E);
... when exists
    mutex_unlock(E);
...
mutex_lock(E);

@script:python@
p << find_mutex_pattern_2.p;

@@
if p:
   cocci.include_match(False)

@badr_2@
expression sg.E;
position p;

@@
if(...) { ...mutex_unlock@p(E); ... return ...; }

@badr1_2@
expression sg.E;
position p;

@@
if(...) { ...mutex_unlock@p(E); ...  continue; }

@badr2_2@
expression sg.E;
position p;
identifier label;

@@
if(...) { ...mutex_unlock@p(E); ... goto label; }

@badr3_2@
expression E;
position p;
@@
switch(...) {
  case ...: {...}
  ...
  default:
  ...
  mutex_unlock@p(E);
  return ...;
}

@r4@
expression sg.E;
position p != {badr_2.p, badr1_2.p, badr2_2.p, badr3_2.p};
position cond_2.lp, cond_2.up;

@@

mutex_lock@lp(E);
 ... 
mutex_unlock@up@p(E);

@r7@
expression sg.E;
position r4.p, cond_2.lp;
identifier label;

@@
+scoped_guard(E) {
-mutex_lock@lp(E);
<...
(
   if(...)
-   {   
-    mutex_unlock(E); 
     return ...; 
-  }

|

   if(...) { ... 
-    mutex_unlock(E); 
     return ...; 
  }

|

   if(...)
-   {   
-    mutex_unlock(E);
     continue;
-   }

|
  if(...)
    {
     ...
-    mutex_unlock(E);
     continue;
    }

|

  if(...)
-   {
-    mutex_unlock(E);
     goto label;
-   }
|

  if(...)
    {
     ...
-    mutex_unlock(E);
     goto label;
    }
|
 switch(...) {
 case ...:
 ...
 default:
   ...
-  mutex_unlock(...);
 return ...;
 }
)   
  ...>
-mutex_unlock@p(E);
+}
