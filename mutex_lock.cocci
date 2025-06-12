// Pattern: Find mutex_lock/unlock blocks with goto.

//where unlock is done within a goto label
@r1@
identifier label;
expression E;
position p;

@@

mutex_lock(E);
... when != mutex_unlock(E);
goto label;
...
label:
mutex_unlock@p(E);
return ...;

@r2@
identifier label;
expression E;
position p;

@@

mutex_lock(E);
... when != mutex_unlock(E);
goto label;
...
*label:
mutex_unlock@p(E);
...
return ...;

//multiple goto statements

@r3@
expression E;
identifier L1, L2; 
statement S1, S2; 
@@

*mutex_lock(E);
... when != mutex_unlock(E)
(
  goto L1;
  ... 
  goto L2; 
)
... 

(
  L1: 
  ... when any 
  mutex_unlock(E);
|
  L2: 
  ... when any 
  mutex_unlock(E);
)

// identify if a mutex_unlock occurs at function end 
// In this scenario guard(...) (...); is preferred

//@badr1@
//identifier I;
//position p;

//@@

//I(...) {
//  mutex_lock(...);
//  ... 
//  *mutex_unlock@p(...);
//}

//@depends on !badr1@

