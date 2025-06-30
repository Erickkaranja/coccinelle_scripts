@badr1@
expression E;
position p;

@@
if(...) { 
  ... 
  mutex_unlock@p(E); 
  ... 
  return ...; 
}

@@
expression E;
position p != badr1.p;
@@

-mutex_lock(E);
+scoped_guard(E) {
    <...
   if(...)
-   {   
-    mutex_unlock(E); 
     return ...; 
-  }
  ...>
-mutex_unlock@p(E);
+}
