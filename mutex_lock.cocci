//safe handling scoped_guard transformation.
//replace calls to mutex_lock and mutex_unlock
//with scoped_guard.
@@
expression E;
@@
func(...){
... when any
?- mutex_unlock(E);
+mutex_unlock(E, end);
}

@@
expression E;
constant C;
identifier I;
@@
func(...){
... when any
?- mutex_unlock(E);
+mutex_unlock(E, end);
return \(C\|I\);
}
 
@r exists@
expression E;
iterator I;
position p;
@@
(
I(...){
  <...
  mutex_lock@p(E);
   ... when != mutex_unlock(E);
       when any
(
    {
       ...
       mutex_unlock(E);
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
   mutex_lock@p(E);
   ... when != mutex_unlock(E);
       when any
(
     {
       ...
       mutex_unlock(E);
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
 mutex_lock@p(E);
 ... when != mutex_unlock(E);
     when any
(
    {
     ...
     mutex_unlock(E);
     ... when any
     break;
    }
|
break;
)
 ...>
}
)

@r1@
expression E, E2;
@@
(
mutex_lock(E);
... when != mutex_unlock(E);
mutex_lock(E2);
|
mutex_lock(E);
)

@@
expression r1.E, r1.E2;
identifier f;
@@
f(...) {
 ... when any
-mutex_lock(E);
... when != mutex_unlock(E);
-mutex_lock(E2);
+guard(mutex)(E);
+guard(mutex)(E2);
<...
(
 if(...)
-  {
-  mutex_unlock(E2);
-  mutex_unlock(E); 
   return ...; 
-  }
|
 if(...) { ... 
-  mutex_unlock(E2);
-  mutex_unlock(E);
   return ...; }
)
 ...>
-mutex_unlock(E2);
-mutex_unlock(E);
return ...;
}
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
position lp != {r.p ,badr4.p2};
position up;
@@
mutex_lock@lp(E);
... when strict
mutex_unlock@up(E);

@script:python@
up << cond.up;
lp << cond.lp;

@@

for i in range(len(up)):
    if int(lp[0].line) > int(up[i].line):
        cocci.include_match(False)
        break

@find_mutex_pattern@
expression E;
position p;
@@
mutex_lock@p(E);
... when exists
    mutex_unlock(E);
...
mutex_lock(E);

@script:python@
p << find_mutex_pattern.p;

@@
if p:
   cocci.include_match(False)

//------------------------------------
@badr@
expression r1.E;
position p;

@@
if(...) { ...mutex_unlock@p(E); ... return ...; }

@badr1@
expression r1.E;
position p;

@@
if(...) { ...mutex_unlock@p(E); continue; }

@badr2@
expression r1.E;
position p;
identifier label;

@@
if(...) { ...mutex_unlock@p(E);goto label; }

@badr3@
expression r1.E;
position p;
@@
switch(...) {
  case ...: {...}
  default:
  ...
  mutex_unlock@p(E);
  return ...;
}

@r2@
expression r1.E;
position p != {badr.p, badr1.p, badr2.p, badr3.p};
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
identifier label;
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
   return ...; }
|
goto label;
...
label:
- mutex_unlock(E);
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
   return ...; }
|
switch(...) {
  case ...: {...}
  default:
    ...
-    mutex_unlock(E);
    return ...;
}
)
 ...>
-mutex_unlock@p(E);
return ...;
)
