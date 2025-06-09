// Find scoped_guard(identifier) { ... } pattern inside functions
// Matches the exact pattern: scoped_guard(id) { statements }

@initialize:python@
@@
count = 0

@r0 exists@
position p;
statement s;

@@
scoped_guard@p(...) s

@script:python@
p << r0.p;
@@
print(f' scoped_guard exists on line -{p[0].line} - {p[0].file}')
count+=1

@r1 exists@
position p != r0.p;

@@
scoped_guard@p(...){
  ...
  return;
  ...
}
@script:python@
p << r1.p;
@@
print(f'scoped_guard with a return exists on line -{p[0].line} - {p[0].file}')
count+=1

@r2 exists@
position p != {r0.p, r1.p};
@@
scoped_guard@p(...) {
  ...
  break;
  ...
}
@script:python@
p << r2.p;
@@
print(f'scoped_guard with a break exists on line -{p[0].line} - {p[0].file}')
count+=1

@ r3 exists@
identifier id_goto;
position p != {r0.p, r1.p, r2.p};
@@
scoped_guard@p(...) {
  ...
  goto id_goto;
  ...
}
@script:python@
p << r3.p;
@@
print(f'scoped_guard with a goto exists on line -{p[0].line} - {p[0].file}')
count+=1

@finalize:python@
@@

print(f'scoped_guard current use -{count}')
