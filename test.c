//case 1
void foo(void)
{
        mutex_lock(&register_mutex);

        for (i = 0; i < SNDRV_CARDS; i++)
                if (enable[i])
                        break;

        if (i >= SNDRV_CARDS) {
                dev_err(&device->dev, "no available " CARD_NAME " audio device\n");
                ret = -ENODEV;
        }
        mutex_unlock(&register_mutex);
}

//case 2
void foo_2(void)
{
	mutex_lock(&devices_mutex);
        for (card_index = 0; card_index < SNDRV_CARDS; card_index++) {
                if (!test_bit(card_index, devices_used) && enable[card_index])
                        break;
        }
        if (card_index >= SNDRV_CARDS) {
                mutex_unlock(&devices_mutex);
                return -ENOENT;
        }
	mutex_unlock(&devices_mutex);
}
