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

@script:python@
p << goto_unlock.p;
p1 << badr4.p2;
@@
print(f'{p[0].line}---{p1[0].line} {p[0].file}')
