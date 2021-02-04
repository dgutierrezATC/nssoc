# Loading .aedat with localization information
print("Starting the test proces...")
settings = MainSettings(num_channels=64, mono_stereo=1, on_off_both=1, address_size=4, ts_tick=1, bin_size=20000)
ssl_settings = LocalizationSettings(mso_start_channel=33, mso_end_channel=36, mso_num_neurons_channel=16)

#nas_file, soc_file = Loaders.loadAEDATLocalization(os.path.join(dirname, 'examples/test_files/enun_stereo_64ch_ONOFF_addr4b_ts1.aedat'), settings, ssl_settings)

nas_file, soc_file = Loaders.loadCSVLocalization(os.path.join(dirname, 'examples/test_files/pure_tone_fs48000duration1000frequency500amplitude1_3_soc_out.txt'), from_simulation=True)

Plots.mso_heatmap(soc_file, ssl_settings)

Plots.mso_spikegram(soc_file, settings, ssl_settings, 1)
plt.show()