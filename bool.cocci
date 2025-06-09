@initialize:ocaml@
@@

let same_function p q =
  (List.hd p).Coccilib.current_element = (List.hd q).Coccilib.current_element

@r@
expression e;
position p;
symbol true,false;
@@

e =@p \(true\|false\)

@@
expression r.e;
position q : script:ocaml(r.p) { same_function p q };
@@

e =@q
(
- 1
+ true
|
- 0
+ false
)

@s@
type T;
T e;
identifier fld;
symbol true,false;
@@

e.fld = \(true\|false\)

@@
type s.T;
T e;
identifier s.fld;
@@

e.fld =
(
- 1
+ true
|
- 0
+ false
)
