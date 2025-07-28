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
@r exists@
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

@r1@
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

@@
expression r1.E, r1.E2;
identifier f;
identifier virtual.lock;
identifier virtual.unlock;
identifier virtual.lock_type;
@@
f(...) {
 ... when any
-lock(E, ...);
... when != unlock(E);
-lock(E2);
+guard(lock_type)(E);
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

@@
expression r1.E, E1;
identifier virtual.lock_type;
identifier virtual.lock;
identifier virtual.unlock;
@@
-lock(E, ...);
+scoped_guard(lock_type, E)
E1;
-unlock(E, ...);

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

@badr4 exists@
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

@cond@
expression r1.E;
position lp != {r.p ,badr4.p2};
position up;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@lp(E, ...);
... when strict
unlock@up(E, ...);

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
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@p(E, ...);
... when exists
    unlock(E, ...);
...
lock(E, ...);

@script:python@
p << find_mutex_pattern.p;

@@
if p:
   cocci.include_match(False)

//------------------------------------
@badr@
expression r1.E;
position p, cond.up;
identifier virtual.unlock;

@@
if(...) { ...unlock@up@p(E, ...); ... return ...; }

@badr1@
expression r1.E;
position p, cond.up;
identifier virtual.unlock;

@@
if(...) { ...unlock@up@p(E, ...); continue; }

@badr2@
expression r1.E;
position p, cond.up;
identifier label;
identifier virtual.unlock;
@@
if(...) { ...unlock@up@p(E, ...);goto label; }

@badr3@
expression r1.E;
position p, cond.up;
identifier virtual.unlock;

@@
switch(...) {
  case ...: {...}
  default:
  ...
  unlock@up@p(E, ...);
  return ...;
}

@r2@
expression r1.E;
position p != {badr.p, badr1.p, badr2.p, badr3.p};
position cond.lp, cond.up;
identifier virtual.lock;
identifier virtual.unlock;
@@

lock@lp(E, ...);
 ...
unlock@up@p(E, ...);

@badr5 exists@
identifier label;
expression r1.E;
position cond.lp;
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
position cond.lp, r2.p;
expression r1.E;
position s_g != badr4.p2;
identifier virtual.lock;
identifier virtual.unlock;
@@
lock@s_g@lp(E, ...);
  ...
unlock@p(E, ...);
return ...;


@r3@
expression r1.E;
position r2.p, cond.lp, r5.s_g;
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
