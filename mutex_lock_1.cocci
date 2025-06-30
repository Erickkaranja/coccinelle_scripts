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

@cond@
expression r1.E;
position lp, up;
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

@r3@
expression r1.E;
position r2.p, cond.lp;

@@

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



//----------------------------------
@cond_2@
expression r1.E;
position lp, up; 
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

@r5@
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
    {
     ...
-    mutex_unlock(E);
     goto label;
   }
|

   if(...)
-    {
-    mutex_unlock(E);
     goto label;
-   }

|

   if(...)
-    {   
-    mutex_unlock(E);
     continue;
-   }
)   
  ...>
-mutex_unlock@p(E);
+}
