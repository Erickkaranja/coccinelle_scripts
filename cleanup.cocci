//clean-up after transformation
@@
type T;
identifier err;
expession E1;
@@
-T err;
... when != err = E1;

-return err;
+return 0;

/*
@@
local idexpression E;
constant C;
@@
(
if(...)
-{
-  E = C;
-  return E;
+ return C;
-}
|
if(...)
{
...
- E = C;
- return E;
+ return C;
}
)
*/
