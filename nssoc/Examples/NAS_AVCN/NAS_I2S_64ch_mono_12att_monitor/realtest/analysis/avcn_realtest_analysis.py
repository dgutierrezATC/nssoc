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

###############################################################
# Path configuration
###############################################################

# Get the absolute path of the python file
dataset_path = os.path.dirname(__file__)
# Go back to the parent directoy
dataset_path = dataset_path.replace('analysis','')
# And go through to the events folder
dataset_path = dataset_path + 'GenericSeqMon\\dataset\\events\\'

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

                # Create two list for containing the isi_average value and the isi_std value
                isi_average_per_channel = []
                isi_standard_dev_per_channel = []
                x_pos = []

                # Create a row list for writting out the csv file
                row_list = []
                row = ["Channel address", "ISI mean (us)", "ISI mean std (us)", "Estimated freq. (Hz)"]
                row_list.append(row)

                # For each channel, extract the activity
                for chnn_index in range(0, nas_num_channels):
                    # Due to the phase-lock, the NAS' output only have even addresses
                    channel_address = [chnn_index * 2]
                    x_pos.append(chnn_index)

                    # Extract the events from the specified channel
                    channel_extracted_data = Functions.extract_channels_activities(recording_file, channel_address)

                    # Calculate the ISI of the extracted activity
                    isi_values = []

                    num_extracted_events = len(channel_extracted_data.timestamps)
                    
                    # For each pair of timestamps (i+1, i), calculate the ISI
                    for index in range (0, num_extracted_events-1):
                        isi_values.append(channel_extracted_data.timestamps[index+1] - channel_extracted_data.timestamps[index])

                    # Then, calculate the ISI average and the standard deviation
                    isi_average = np.mean(isi_values)
                    isi_average_per_channel.append(isi_average)

                    isi_standard_dev = np.std(isi_values)
                    isi_standard_dev_per_channel.append(isi_standard_dev)

                    # Create the row info to be written into the csv file
                    # Channel address, ISI mean, ISI mean std, stimated freq.
                    estimated_freq = 1.0 / (isi_average * 1.0e-6)
                    row = [str(chnn_index), str(isi_average), str(isi_standard_dev), str(estimated_freq)]
                    row_list.append(row)
                
                # Generate a csv file containing the information
                csv_filename = filename.replace('.wav.aedat','.csv')
                with open(csv_filename, 'w', newline='') as file:
                    writer = csv.writer(file, delimiter=';')
                    writer.writerows(row_list)

                # Finally, plot the result as a bar plot with error
                fig, ax = plt.subplots()
                ax.bar(x_pos, isi_average_per_channel,
                    yerr=isi_standard_dev_per_channel,
                    align='center',
                    alpha=0.5,
                    ecolor='black',
                    capsize=5)
                ax.set_ylabel('Microseconds')
                ax.set_xticks(x_pos)
                ax.set_title('Inter-Spike Interval from phase-locked output')
                ax.yaxis.grid(True)


                # Save the figure
                plt.tight_layout()
                plt.show()
                #figure_filename = filename.replace('.wav.aedat','.png')
                #plt.savefig(figure_filename)




