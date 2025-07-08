//safe handling scoped_guard transformation.
//replace calls to mutex_lock and mutex_unlock
//with scoped_guard.

@r1@
expression E;
@@
mutex_lock(E);

@@
expression r1.E, E1;
@@
-mutex_lock(E);
+scoped_guard(E)
E1;
-mutex_unlock(E);

@goto_unlock exists@
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

@badr4 exists@
expression E;
position goto_unlock.p;
position goto_unlock.p1;
position p2;
statement s;
@@
mutex_lock@p1@p2(E);
...
s@p

@cond@
expression r1.E;
position lp != badr4.p2, up;
@@
mutex_lock@lp(E);
... when strict
mutex_unlock@up(E);

@script:python@
up << cond.up;
lp << cond.lp;

@@

for i in range(len(lp)):
    if int(lp[i].line) > int(up[0].line):
        cocci.include_match(False)
        break

//------------------------------------
@badr1@
expression r1.E;
position p;

@@
if(...) { ...mutex_unlock@p(E); ... return ...; }

@badr2@
expression r1.E;
position p;

@@
if(...) { ...mutex_unlock@p(E); ...  continue; }

@badr3@
expression r1.E;
position p;
identifier label;

@@
if(...) { ...mutex_unlock@p(E); ... goto label; }

@r2@
expression r1.E;
position p != {badr1.p, badr2.p, badr3.p};
position cond.lp, cond.up;

@@

mutex_lock@lp(E);
 ...
mutex_unlock@up@p(E);

@badr5 exists@
identifier label;
expression r1.E;
position cond.lp;
@@
mutex_lock@lp(E);
 ... when != mutex_unlock(E);
if (...) {
    ...
    goto label;
  }

@r5 depends on badr5@
position cond.lp, r2.p;
expression r1.E;
position s_g != badr4.p2;

@@
mutex_lock@s_g@lp(E);
  ...
   mutex_unlock@p(E);
  return ...;


@r3@
expression r1.E;
position r2.p, cond.lp, r5.s_g;

@@
(
- mutex_lock@s_g(E);
+ scoped_guard(E) {
<...
(
 if(...)
-  {   
-  mutex_unlock(E); 
   return ...; 
-  }
|
 if(...) { ... 
-  mutex_unlock(E); 
   ... 
   return ...; }
)
 ...>
-mutex_unlock@p(E);
+}
return ...;

|

- mutex_lock@lp(E);
+ guard(mutex)(E);
<...
(
 if(...)
-  { 
-  mutex_unlock(E); 
   return ...; 
-  }
|
 if(...) { ... 
-  mutex_unlock(E); 
   ... 
   return ...; }
)
 ...>
-mutex_unlock@p(E);
return ...;
)

//----------------------------------
@cond_2@
expression r1.E;
position lp != badr4.p2, up; 
@@
mutex_lock@lp(E);
... when strict
mutex_unlock@up(E);

@script:python@
up << cond_2.up;
lp << cond_2.lp;

@@

for i in range(len(lp)):
    if int(lp[i].line) > int(up[0].line):
        cocci.include_match(False)
        break

@r4@
expression r1.E;
position p != {badr1.p, badr2.p, badr3.p};
position cond_2.lp, cond_2.up;

@@

mutex_lock@lp(E);
 ... 
mutex_unlock@up@p(E);

@r7@
expression r1.E;
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
)   
  ...>
-mutex_unlock@p(E);
+}
