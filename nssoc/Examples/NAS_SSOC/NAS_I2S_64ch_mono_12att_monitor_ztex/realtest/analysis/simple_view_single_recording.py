"""--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright C 2020  Daniel Gutierrez Galan                                 //
--//                                                                             //
--//    This file is part of NSSOC.                                              //
--//                                                                             //
--//    NSSOC is free software: you can redistribute it and/or modify            //
--//    it under the terms of the GNU General Public License as published by     //
--//    the Free Software Foundation, either version 3 of the License, or        //
--//    (at your option) any later version.                                      //
--//                                                                             //
--//    NSSOC is distributed in the hope that it will be useful,                 //
--//    but WITHOUT ANY WARRANTY; without even the implied warranty of           //
--//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the              //
--//    GNU General Public License for more details.                             //
--//                                                                             //
--//    You should have received a copy of the GNU General Public License        //
--//    along with NSSOC. If not, see <http://www.gnu.org/licenses/>.            //
--//                                                                             //
--/////////////////////////////////////////////////////////////////////////////////"""

###############################################################
# Imports
###############################################################
from pyNAVIS import *
import os
import matplotlib.pyplot as plt

###############################################################
# NAS & SOC parameters configuration
###############################################################
# NAS parameter
nas_num_channels = 64          # 64 frequency channels
nas_mono_stereo = 1            # If stereo was used, then use 1
nas_polarity_on_off_both = 1   # If merged polarity was used, then use 1

# MSO parameter
mso_start_freq_channel = 25#25
mso_end_freq_channel = 34#29
mso_num_neurons_per_freq_channel = 16#32

###############################################################
# Recording platform configuration
###############################################################

# Recordings parameters: MATLAB
nas_address_size = 2           # If matlab was used, then use 2
nas_ts_tick = 0.2              # If matlab was used, then use 0.2
nas_bin_size = 10000           # Not relevant

"""# Recordings parameters: JAER
nas_address_size = 4           # If matlab was used, then use 2
nas_ts_tick = 1.0              # If matlab was used, then use 0.2
nas_bin_size = 10000           # Not relevant"""

settings = MainSettings(num_channels=nas_num_channels, 
                        mono_stereo=nas_mono_stereo, 
                        on_off_both=nas_polarity_on_off_both, 
                        address_size=nas_address_size, 
                        ts_tick=nas_ts_tick, 
                        bin_size=nas_bin_size)

settings_localization = LocalizationSettings(
                        mso_start_channel=mso_start_freq_channel, 
                        mso_end_channel=mso_end_freq_channel, 
                        mso_num_neurons_channel=mso_num_neurons_per_freq_channel)

###############################################################
# Path configuration
###############################################################

# Get the absolute path of the python file
dataset_path = os.path.dirname(__file__)
# Go back to the parent directoy
dataset_path = dataset_path.replace('analysis','')
# And go through to the events folder
dataset_path = dataset_path + 'GenericSeqMon\\dataset\\events\\Pure_tones_dataset\\Dist_300cm\\Config2\\1000Hz_aedats\\'

###############################################################
# Files processing
###############################################################

# Load the AEDAT file
filename = dataset_path + 'nssoc_puretone_1000Hz_dist3.0m_pos_2of9.aedat'
#filename = 'D:\\prueba.aedat'
print("Processing file " + filename + "...")

# Load the file
recording_file_nas, recording_file_soc = Loaders.loadAEDATLocalization(filename, settings, settings_localization)

# Adapt timestamps and check the NAS file
recording_file_nas.timestamps = Functions.adapt_timestamps(recording_file_nas.timestamps, settings)
Functions.check_SpikesFile(recording_file_nas, settings)

# Adapt timestamps and check SOC file
recording_file_soc.mso_timestamps = Functions.adapt_timestamps(recording_file_soc.mso_timestamps, settings)
Functions.check_LocalizationFile(recording_file_soc, settings, settings_localization)

# Generate plots
Plots.spikegram(recording_file_nas, settings)
Plots.sonogram(recording_file_nas, settings)
Plots.histogram(recording_file_nas, settings)
Plots.average_activity(recording_file_nas, settings)
Plots.difference_between_LR(recording_file_nas, settings)

Plots.mso_spikegram(recording_file_soc, settings, settings_localization)
Plots.mso_heatmap(recording_file_soc, settings_localization)
Plots.mso_localization_plot(recording_file_soc, settings, settings_localization)
Plots.mso_histogram(recording_file_soc, settings, settings_localization)

plt.show()