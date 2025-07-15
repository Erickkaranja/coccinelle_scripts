@cond@
expression E;
position lp;
position up; 
@@
mutex_lock@lp(E);
... when strict
mutex_unlock@up(E);

@script:python@
up << cond.up;
lp << cond.lp;

@@

for i in range(len(up)):
    if int(lp[0].line) > int(up[i].line):
        cocci.include_match(False)
        break

@@
expression E;
position cond.lp, cond.up;
@@
mutex_lock@lp(E);
...
- mutex_unlock@up(E);
