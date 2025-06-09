@initialize:ocaml@
@@

let bigcode p =
  let p = List.hd p in
  (p.Coccilib.line <> p.Coccilib.line_end) ||
  (p.Coccilib.col_end - p.Coccilib.col >= 60) 


@r1@
type T;
identifier x;
position p;
@@

T@p x;

@badr1@
type T,T2;
identifier r1.x,y;
statement S1,S2;
position r1.p;
@@

T@p x;
... when != S1
T2 y;
... when != S2
x = <+... y ...+>;

@badr1a@
type T;
expression e,f;
identifier r1.x;
statement S,S1,S2;
position r1.p;
binary operator op;
@@

T@p x;
... when != S
x = e;
if (<+...\(x == NULL\|x != NULL\|x op 0\|f(...,x,...)\)...+>) S1 else S2

@badr1b@
type T;
expression e;
identifier r1.x;
statement S;
position r1.p;
position q : script:ocaml() { bigcode q };
@@

T@p x;
... when != S
x = e@q;

@badr_func_assign@
type T;
identifier r1.x;
position r1.p;
identifier f;
statement S;
@@

T@p x;
... when != S
x = f(...);

@depends on !badr1 && !badr1a && !badr1b && !badr_func_assign@
type T;
identifier r1.x;
expression e;
statement S;
position r1.p;
@@

T@p x
+ = e
  ;
... when != S
- x = e;

// ---------------------------

@r2@
type T;
identifier x;
position p;
@@

T@p x;

@badr2@
type T,T2;
identifier r2.x,y;
statement S1,S2;
position r2.p;
@@

T@p x;
... when != S1
T2 y;
... when != S2
x = <+... y ...+>;

@badr2a@
type T;
expression e,f;
identifier r2.x;
statement S,S1,S2;
position r2.p;
binary operator op;
@@

T@p x;
... when != S
x = e;
if (<+...\(x == NULL\|x != NULL\|x op 0\|f(...,x,...)\)...+>) S1 else S2

@badr2b@
type T;
expression e;
identifier r2.x;
statement S;
position r2.p;
position q : script:ocaml() { bigcode q };
@@

T@p x;
... when != S
x = e@q;

@badr_func_assign2@

type T;
identifier r2.x;
position r2.p;
identifier f;
statement S;
@@

T@p x;
... when != S
x = f(...);

@depends on !badr2 && !badr2a && !badr2b && !badr_func_assign2@
type T;
identifier r2.x;
expression e;
statement S;
position r2.p;
@@

T@p x
+ = e
  ;
... when != S
- x = e;

// ---------------------------

@r3@
type T;
identifier x;
position p;
@@

T@p x;

@badr3@
type T,T2;
identifier r3.x,y;
statement S1,S2;
position r3.p;
@@

T@p x;
... when != S1
T2 y;
... when != S2
x = <+... y ...+>;

@badr3a@
type T;
expression e,f;
identifier r3.x;
statement S,S1,S2;
position r3.p;
binary operator op;
@@

T@p x;
... when != S
x = e;
if (<+...\(x == NULL\|x != NULL\|x op 0\|f(...,x,...)\)...+>) S1 else S2

@badr3b@
type T;
expression e;
identifier r3.x;
statement S;
position r3.p;
position q : script:ocaml() { bigcode q };
@@

T@p x;
... when != S
x = e@q;

@badr_func_assign3@
type T;
identifier r3.x;
position r3.p;
identifier f;
statement S;
@@

T@p x;
... when != S
x = f(...);

@depends on !badr3 && !badr3a && !badr3b && !badr_func_assign3@
type T;
identifier r3.x;
expression e;
statement S;
position r3.p;
@@

T@p x
+ = e
  ;
... when != S
- x = e;

