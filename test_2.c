void foo() {
while(1){	
mutex_lock(&node->mutex);
                item = __btrfs_first_delayed_deletion_item(node);
                if (!item) {
                        mutex_unlock(&node->mutex);
                        break;
                }
mutex_unlock(&node->mutex);
}
}
