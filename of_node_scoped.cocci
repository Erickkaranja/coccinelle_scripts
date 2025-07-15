@r@
local idexpression parent;
expression child;
iterator name for_each_child_of_node;
statement S;
//expression list [n1] el;
iterator i;
@@
(
* for_each_child_of_node(parent, child) S
&
i(parent, child) S
)

//if(...) {
 //...
// of_node_put(child);

//}

//if(...) {
// ...
// goto label;
//}

//label:
// ...
// of_node_put(child);
