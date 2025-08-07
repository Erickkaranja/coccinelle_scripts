#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/moduleparam.h>
#include <linux/string.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Erick Karanja");
MODULE_DESCRIPTION("A kernel module with parameters.");
MODULE_VERSION("0.2");

// Command line parameters
static char *first_name = "Erick";
module_param(first_name, charp, 0444);
MODULE_PARM_DESC(first_name, "My first name");

static char *second_name = "Karanja";
module_param(second_name, charp, 0444);
MODULE_PARM_DESC(second_name, "My second name");

static int __init hello_init(void) {
    printk(KERN_NOTICE "Module loaded: first_name = %s, second_name = %s\n", first_name, second_name);
    return 0;
}

static void __exit hello_exit(void) {
    printk(KERN_NOTICE "Bye Bye\n");
}

module_init(hello_init);
module_exit(hello_exit);

