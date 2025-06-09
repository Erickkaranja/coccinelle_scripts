@initialize:ocaml@
@@
let is_func_call e =
  match e with
  | Ast0.Call _ -> true
  | _ -> false

// Match a basic variable declaration
@r1@
type T;
identifier x;
position p;
@@
T@p x;

// Identify declarations followed by assignments that are function calls (to exclude them)
@badr depends on r1@
type T;
identifier r1.x;
position r1.p;
expression E;
statement S;
@@
T@p x;
... when != S
x = E;
... when script:ocaml() { is_func_call E }

// Transform declarations followed by assignments, but only if not a function call
@goodr depends on r1 && !badr@
type T;
identifier r.x;
position r.p;
expression e;
statement S;
@@
- T@p x;
+ T x = e;
... when != S
- x = e;
