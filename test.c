static void dmz_chunk_work(struct work_struct *work)
{
        struct dm_chunk_work *cw = container_of(work, struct dm_chunk_work, work);
        struct dmz_target *dmz = cw->target;
        struct bio *bio;

        mutex_lock(&dmz->chunk_lock);

        /* Process the chunk BIOs */
        while ((bio = bio_list_pop(&cw->bio_list))) {
                dmz_handle_bio(dmz, cw, bio);
                mutex_lock(&dmz->chunk_lock);
                dmz_put_chunk_work(cw);
        }    

        /* Queueing the work incremented the work refcount */
        dmz_put_chunk_work(cw);
}

int ceph_monc_wait_osdmap(struct ceph_mon_client *monc, u32 epoch,
                          unsigned long timeout)
{
        unsigned long started = jiffies;
        long ret; 

        mutex_lock(&monc->mutex);
        while (monc->subs[CEPH_SUB_OSDMAP].have < epoch) {
                if (timeout && time_after_eq(jiffies, started + timeout))
                        return -ETIMEDOUT;

                ret = wait_event_interruptible_timeout(monc->client->auth_wq,
                                     monc->subs[CEPH_SUB_OSDMAP].have >= epoch,
                                     ceph_timeout_jiffies(timeout));
                if (ret < 0) 
                        return ret; 

                mutex_lock(&monc->mutex);
        }
        return 0;
}
static int caps_show(struct seq_file *s, void *p)
{
        struct ceph_fs_client *fsc = s->private;
        struct ceph_mds_client *mdsc = fsc->mdsc;

        mutex_lock(&mdsc->mutex);
        for (i = 0; i < mdsc->max_sessions; i++) {
                struct ceph_mds_session *session;

                session = __ceph_lookup_mds_session(mdsc, i);
                if (!session)
                        continue;
                ceph_put_mds_session(session);
                mutex_lock(&mdsc->mutex);
        }
}

int evsel__tpebs_read(struct evsel *evsel, int cpu_map_idx, int thread)
{
	struct perf_counts_values *count, *old_count = NULL;
	struct tpebs_retire_lat *t;
	uint64_t val;
	int ret;

	/* Only set retire_latency value to the first CPU and thread. */
	if (cpu_map_idx != 0 || thread != 0)
		return 0;

	if (evsel->prev_raw_counts)
		old_count = perf_counts(evsel->prev_raw_counts, cpu_map_idx, thread);

	count = perf_counts(evsel->counts, cpu_map_idx, thread);

	mutex_lock(tpebs_mtx_get());
	t = tpebs_retire_lat__find(evsel);
	/*
	 * If reading the first tpebs result, send a ping to the record
	 * process. Allow the sample reader a chance to read by releasing and
	 * reacquiring the lock.
	 */
	if (t && &t->nd == tpebs_results.next) {
		ret = tpebs_send_record_cmd(EVLIST_CTL_CMD_PING_TAG);
		if (ret)
			return ret;
		mutex_lock(tpebs_mtx_get());
	}
	if (t == NULL || t->stats.n == 0) {
		/* No sample data, use default. */
		if (tpebs_recording) {
			pr_warning_once(
				"Using precomputed retirement latency data as no samples\n");
		}
		val = 0;
		switch (tpebs_mode) {
		case TPEBS_MODE__MIN:
			val = rint(evsel->retirement_latency.min);
			break;
		case TPEBS_MODE__MAX:
			val = rint(evsel->retirement_latency.max);
			break;
		default:
		case TPEBS_MODE__LAST:
		case TPEBS_MODE__MEAN:
			val = rint(evsel->retirement_latency.mean);
			break;
		}
	} else {
		switch (tpebs_mode) {
		case TPEBS_MODE__MIN:
			val = t->stats.min;
			break;
		case TPEBS_MODE__MAX:
			val = t->stats.max;
			break;
		case TPEBS_MODE__LAST:
			val = t->last;
			break;
		default:
		case TPEBS_MODE__MEAN:
			val = rint(t->stats.mean);
			break;
		}
	}

	if (old_count) {
		count->val = old_count->val + val;
		count->run = old_count->run + 1;
		count->ena = old_count->ena + 1;
	} else {
		count->val = val;
		count->run++;
		count->ena++;
	}
	return 0;
}
       
