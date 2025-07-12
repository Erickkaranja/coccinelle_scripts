@r@
expression E;
iterator I;
position p;
@@
I(...){
  ...
  mutex_lock@p(E);
  ... when exists 
         break;
    }
 
@r1@
expression E;
position p;

@@
for(...; ...; ...){
   ...
   mutex_lock@p(E);
   ... when exists
       break;
     }
@r2@
expression E;
position p;

@@
while(...) {
 ...
 mutex_lock@p(E);
 ... when exists
     break;
}


@r3 depends on r || r1 || r2@
expression E;
position p, p1;
@@

mutex_lock(E);
... 
 break@p;
...
mutex_unlock@p1(E);

@script:python@
p << r3.p;
p1 << r3.p;
@@
print(f'{p[0].line} -- {[item.line for item in p1 ]} -- {p[0].file}')
