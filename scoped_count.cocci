@initialize:python@
@@
c,c1, c2, c3, c4 = 0, 0, 0, 0, 0

@r0 exists@
position p;
@@
*scoped_guard@p(...) {
...
return ...;
...
}

@script:python@
p << r0.p;
@@
c +=1

@r1 exists@
position p != r0.p;

@@
scoped_guard@p(...) {
...
break;
...
}

@script:python@
p << r1.p;
@@
c1 += 1

@ r2 exists@
identifier id_goto;
position p != {r0.p, r1.p};
@@
scoped_guard@p(...) {
...
goto id_goto;
...
}

@script:python@
p << r2.p;
@@
c2 += 1

@r3 exists@
expression E;
position p != {r0.p, r1.p, r2.p};
@@
scoped_guard@p(...) E;

@script:python@
p << r3.p;
@@
c3 += 1

@r4 exists@
statement s;
position p != {r0.p, r1.p, r2.p, r3.p};
@@
scoped_guard@p(...){
s
}
@script:python@
p << r4.p;
@@
c4 += 1

@finalize:python@
@@
print('=' * 50)
print(f'scoped_guard with return  statement : {c}')
print(f'scoped_guard total with break statement : {c1}')
print(f'scoped_guard with goto label : {c2}')
print(f'Unguarded scoped_guard  : {c3}')
print(f'Guarded scoped_guard with no return, goto or break statements : {c4}')
print('=' * 50)
