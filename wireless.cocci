@initialize:python@
@@
import sys
x = {}

def store_data(action, input, code):
    """Add information to an internal data structure."""
    x[code] = (action, input)

@find@
expression e;
identifier action, input;
type input_type, return_type != void;
@@
 static inline return_type action(input_type input)
 {
 return e;
 }

@script:python collection@
action << find.action;
input << find.input;
code << find.e;
@@
store_data(action, input, code)

@finalize:python@
@@
if x:
   sys.stdout.write("@replacements@\nconst struct usb_endpoint_descriptor *epd;\n@@\n(\n")
   sys.stdout.write("|\n".join("-{}\n+{}({})\n".format(key, value[0], value[1])
                    for key, value in x.items()))
   sys.stdout.write(")\n")
else:
   sys.stderr.write("No result for this analysis!\n")
