//scoped_guard uses in the kernel

@initialize:python@
@@
count = 0
c_r, c_b, c_g, c, c_u = 0, 0, 0, 0, 0

@r0 exists@
position p;
@@
scoped_guard@p(...) {
  <+...
   return ...;
 ...+>
}

@script:python@
p << r0.p;
@@
c_r +=1

@r1 exists@
position p != r0.p;

@@
*scoped_guard@p(...) {
  ... 
  break;
  ...
}

@script:python@
p << r1.p;
@@
c_b += 1

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
c_g += 1

@r3 exists@
expression E;
position p != {r0.p, r1.p, r2.p};
@@
scoped_guard@p(...) E;

@script:python@
p << r3.p;
@@
c += 1

@r4 exists@
statement s;
position p != {r0.p, r1.p, r2.p, r3.p};
@@
*scoped_guard@p(...){
s
}
@script:python@
p << r3.p;
@@
c_u += 1

@finalize:python@
@@
print('=' * 50)
print(f'unguarded scoped_guard total use : {c}')
print(f'Return total use : {c_r}')
print(f'break_guard total use : {c_b}')
print(f'goto_guard total use : {c_g}')
print(f'guarded scope guard use : {c_u}')
print(f'Total scoped guard summary : {sum([c, c_r, c_b, c_g, c_u])}')
print('=' * 50)
