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

for i in range(len(up)):
    if int(lp[0].line) > int(up[i].line):
        cocci.include_match(False)
        break

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

