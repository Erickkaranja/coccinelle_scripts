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
position p1;
@@

mutex_lock@p1(E);
 ...
mutex_unlock@p(E);

@script:python@
p << r2.p;
p1 << r2.p1;

@@

if int(p[0].line) < int(p1[0].line):
   cocci.include_match(False)

@r3@
expression r1.E;
position r2.p, r2.p1;
identifier label;

@@

(
- mutex_lock@p1(E);
+ guard(mutex)(E);
<...
 if(...)
-  { 
-  mutex_unlock(E); 
   return ...; 
-  }
 ...>

-mutex_unlock@p(E);
return ...;

|

- mutex_lock@p1(E);
+ guard(mutex)(E);
 <...
 if(...) { ... 
-  mutex_unlock(E); 
   ... 
   return ...; }
 ...>
-mutex_unlock@p(E);
return ...;

)


//----------------------------------
@r4@
expression r1.E;
position p != {badr1.p, badr2.p, badr3.p};
position p1; 
@@

mutex_lock@p1(E);
 ... 
mutex_unlock@p(E);

@script:python@
p << r2.p;
p1 << r2.p1;

@@

if int(p[0].line) < int(p1[0].line):
   cocci.include_match(False)

@r5@
expression r1.E;
position r4.p, r4.p1;
identifier label;
@@
(
+scoped_guard(E) {
-mutex_lock@p1(E);
  <...
   if(...)
-   {   
-    mutex_unlock(E); 
     return ...; 
-  }
  ...>
-mutex_unlock@p(E);
+}

|

+scoped_guard(E) {
-mutex_lock@p1(E);
  <...
   if(...) { ... 
-    mutex_unlock(E); 
     return ...; 
  }
  ...>
-mutex_unlock@p(E);
+}

|

+scoped_guard(E) {
-mutex_lock@p1(E);
  <...
   if(...)
    {
     ...
-    mutex_unlock(E);
     goto label;
   }
  ...>
-mutex_unlock@p(E);
+}

|

+scoped_guard(E) {
-mutex_lock@p1(E);
  <...
   if(...)
-    {
-    mutex_unlock(E);
     goto label;
-   }
  ...>
-mutex_unlock@p(E);
+}
)

