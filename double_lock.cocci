@@
expression E, E2;
@@
-mutex_lock(E);
-mutex_lock(E2);
+guard(mutex)(E);
+guard(mutex)(E2);
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
)
 ...>
-mutex_unlock(E);
-mutex_unlock(E2);
return ...;
