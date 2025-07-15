// wrongly placed braces in if
@r@
expression E;
position p;
@@
scoped_guard@p(E) {
<...
 if(...) {}
...>
}

@script:python@
p << r.p;
@@
print(f'{p[0].line} -- {p[0].file}')

// hanging goto labels
@r1@
expression E;
position p;
identifier label;

@@
scoped_guard(E) {
 ...
 ... goto label;
 ...
}
<...
  {
   ...
   label:
  }
...>
@script:python@
p << r1.p;
@@
print(f'{p[0].line} -- {p[0].file}')

@r2 exists@
expression E;
position p;
@@
scoped_guard@p(E) {
  ...
  ... mutex_unlock(E);
  ...
}

@script:python@
p << r2.p;
@@
print(f'{p[0].line} -- {p[0].file}')
