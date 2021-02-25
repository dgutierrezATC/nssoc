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
import numpy as np
import csv

###############################################################
# NAS parameters configuration
###############################################################
# NAS parameter
nas_num_channels = 64          # 64 frequency channels
nas_mono_stereo = 0            # If mono was used, then use 0
nas_polarity_on_off_both = 1   # If merged polarity was used, then use 1

# Recordings parameters: MATLAB
nas_address_size = 2           # If matlab was used, then use 2
nas_ts_tick = 0.2              # If matlab was used, then use 0.2
nas_bin_size = 10000           # Not relevant

settings = MainSettings(num_channels=nas_num_channels, 
                        mono_stereo=nas_mono_stereo, 
                        on_off_both=nas_polarity_on_off_both, 
                        address_size=nas_address_size, 
                        ts_tick=nas_ts_tick, 
                        bin_size=nas_bin_size)

# MSO parameters
mso_start_freq_chnn = 25
mso_end_freq_chnn = 34
mso_num_neurons_per_chnn = 16

###############################################################
# Path configuration
###############################################################

# Get the absolute path of the python file
dataset_path = os.path.dirname(__file__)
# Set the filename
filename = 'pure_tone_fs48000duration1000frequency500amplitude1_3.aedat'
# Set the absolute path to the filename
filename_path = os.path.join(dataset_path, filename)

###############################################################
# Files processing
###############################################################
print("Processing file " + filename + "...")

# Load the file
recording_file = Loaders.loadAEDAT(filename_path, settings)
recording_file = Functions.adapt_SpikesFile(recording_file, settings)
Functions.check_SpikesFile(recording_file, settings)

# Generate a stereo file from mono file adding some delay
delta_t = 250
recording_file_stereo = Functions.mono_to_stereo(recording_file, delay=delta_t, settings=settings, return_save_both=0)

# Now, the settings should be changed due to we have now a stereo file
settings.mono_stereo = 1

# Extract channels activity
channels_to_extract = []

for i in range(mso_start_freq_chnn, mso_end_freq_chnn + 1):
    address_left_on = i * (1 + nas_polarity_on_off_both)
    address_left_off = address_left_on + 1

    address_right_on = address_left_on + (nas_num_channels * (1 + nas_polarity_on_off_both))
    address_right_off = address_right_on + 1

    channels_to_extract.append(address_left_on)
    channels_to_extract.append(address_left_off)

    channels_to_extract.append(address_right_on)
    channels_to_extract.append(address_right_off)

recording_file_stereo_channels = Functions.extract_channels_activities(spikes_file = recording_file_stereo, addresses = channels_to_extract, reset_addresses = False, verbose = False)

# Save the channels activity as txt 
Savers.save_TXT(recording_file_stereo_channels, os.path.join(dataset_path, filename.replace('.aedat','')), True)
