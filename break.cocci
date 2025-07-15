@r exists@
expression E;
iterator I;
position p, p1;
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
       mutex_unlock@p1(E);
       ... when any
       break;
    }
|

break@p1;
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
       mutex_unlock@p1(E);
       ... when any
       break;
     }
|
break@p1;
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
     mutex_unlock@p1(E);
     ... when any
     break;
    }
|
break@p1;
)
 ...>
}
)

@script:python@
p << r.p;
p1 << r.p1;
@@
print(f'{p[0].line} --- {p1[0].line} {p[0].file}')
