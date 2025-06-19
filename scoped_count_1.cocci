//scoped_guard uses in the kernel

@initialize:python@
@@
count = 0

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
count +=1

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
count += 1

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
count += 1

@r3 exists@
statement s;
position p != {r0.p, r1.p, r2.p};
@@
*scoped_guard@p(...) {s};

@script:python@
p << r3.p;
@@
count += 1


@finalize:python@
@@
print('=' * 50)
print(f'unguarded scoped_guard total use : {count}')
print('=' * 50)
