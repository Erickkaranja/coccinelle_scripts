int ceph_monc_wait_osdmap(struct ceph_mon_client *monc, u32 epoch,
                          unsigned long timeout)
{
        unsigned long started = jiffies;
        long ret; 

        mutex_lock(&monc->mutex);
        while (monc->subs[CEPH_SUB_OSDMAP].have < epoch) {
                mutex_unlock(&monc->mutex);

                if (timeout && time_after_eq(jiffies, started + timeout))
                        return -ETIMEDOUT;

                ret = wait_event_interruptible_timeout(monc->client->auth_wq,
                                     monc->subs[CEPH_SUB_OSDMAP].have >= epoch,
                                     ceph_timeout_jiffies(timeout));
                if (ret < 0) 
                        return ret; 

                mutex_lock(&monc->mutex);
        }

        mutex_unlock(&monc->mutex);
        return 0;
}
