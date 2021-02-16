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

###############################################################
# Path configuration
###############################################################

# Get the absolute path of the python file
dataset_path = os.path.dirname(__file__)
# Go back to the parent directoy
dataset_path = dataset_path.replace('analysis','')
# And go through to the events folder
dataset_path = dataset_path + 'GenericSeqMon\\dataset\\events_with_avcn\\'

###############################################################
# Files processing
###############################################################

# For each subdirectory in the events dataset folder
for entry in os.listdir(dataset_path):
    if os.path.isdir(os.path.join(dataset_path, entry)):
        # Go inside the current subdirectory
        basepath = dataset_path + entry

        # For each file contained in the subdirectory
        for entry in os.listdir(basepath):
            if os.path.isfile(os.path.join(basepath, entry)) and entry.endswith('.aedat'):
                # Create the absolute path to the .aedat file
                filename = basepath + '\\' + entry
                print("Processing file " + filename + "...")

                # Load the file
                recording_file = Loaders.loadAEDAT(filename, settings)
                recording_file = Functions.adapt_SpikesFile(recording_file, settings)
                Functions.check_SpikesFile(recording_file, settings)
                # Generate the PDF report
                Functions.PDF_report(recording_file, settings, filename.replace('.wav.aedat', '.pdf'), plots=["Sonogram", "Histogram", "Average activity"], vector=False)