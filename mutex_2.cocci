@r2@
expression r1.E;
position p != badr1.p;
@@

(
- mutex_lock(E);
+ guard(mutex)(E);
 <...
 if(...) { ...
-  mutex_unlock(E); 
   ... 
   return ...; }
 ...>
-mutex_unlock@p(E);
return ...;

|

+scoped_guard(E) {
-mutex_lock(E);
<...
 if(...) { 
   ...
-  mutex_unlock(E);
   ...
   return ...; }
...>
-mutex_unlock@p(E);
+}
)

