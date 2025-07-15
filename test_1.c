static void spapr_tce_release_ownership(struct iommu_table_group *table_group, struct device *dev)
{
        struct iommu_table *tbl = table_group->tables[0];

        if (tbl) { /* Default window already restored */
                return;
        }

        guard(mutex)(&dma_win_init_mutex);
        do_123
        /* Restore the default window */
        pseries_setup_default_iommu_config(table_group, dev);

        return;
}

