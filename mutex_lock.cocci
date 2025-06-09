// Pattern: Find mutex_lock/unlock blocks with goto, break, or return
//refine futher to only catch related locks.
//check where unlock are confined in conditions.
@r1@
identifier goto_label;
position goto_pos;
identifier lock =~ ".*_lock$";
identifier unlock =~ ".*_unlock$";

@@

*lock(...);

... when any

goto goto_label@goto_pos;

... when any
*unlock(...);

@@
identifier lock =~ ".*_lock$";
identifier unlock =~ ".*_unlock$";
@@
*lock(...);

... when any 

*return ...;

... when any 
*unlock(...);
