"""
--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright (c) 2020  Daniel Gutierrez Galan                               //
--//                                                                             //
--//    This file is part of NSSOC project.                                      //
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
--/////////////////////////////////////////////////////////////////////////////////
"""

###############################################################
# Imports
###############################################################
import csv
import os
import matplotlib.pyplot as plt
import numpy as np

###############################################################
# Paths configuration
###############################################################

testbench_results_analysis_folder_path = os.path.dirname(os.path.realpath(__file__))
print(testbench_results_analysis_folder_path)

testbench_results_folder_path = testbench_results_analysis_folder_path.replace("Analysis", "")
print(testbench_results_folder_path)

testbench_results_files_folder_path = testbench_results_analysis_folder_path.replace("Analysis", "Files\\")
print(testbench_results_folder_path)

###############################################################
# Files to be processed
###############################################################

testbench_results_filenames = []
testbench_results_filenames.append("sbc_input_pos_spikes.txt")
testbench_results_filenames.append("sbc_input_neg_spikes.txt")
testbench_results_filenames.append("sbc_output_spikes.txt")

###############################################################
# Read files
###############################################################

input_pos_spikes_timestamps = []
input_pos_spikes_addresses = []

input_neg_spikes_timestamps = []
input_neg_spikes_addresses = []

output_spikes_timestamps = []
output_spikes_addresses = []

for testbench_results_file_index in range(0, len(testbench_results_filenames)):
    testbench_results_file_path = testbench_results_files_folder_path + testbench_results_filenames[testbench_results_file_index]

    with open(testbench_results_file_path) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=';')

        for row in csv_reader:
            ts = row[1]
            ts = ts.replace(" ps", "")
            ts = int(ts)
            print(ts)
            if testbench_results_file_index == 0:
                input_pos_spikes_timestamps.append(ts)
                input_pos_spikes_addresses.append(0)
            elif testbench_results_file_index == 1:
                input_neg_spikes_timestamps.append(ts)
                input_neg_spikes_addresses.append(1)
            elif testbench_results_file_index == 2:
                output_spikes_timestamps.append(ts)
                output_spikes_addresses.append(0)
            else:
                print("ERROR!")

# Create the figure and the subplots
fig = plt.figure(figsize=(4.6, 3.0))

# Change the figure title
fig.suptitle('Spherical bussy cell example')

# Plotting the facilitatory and trigger spikes
ax1 = fig.add_subplot(211)

ax1.plot(input_pos_spikes_timestamps, np.ones(len(input_pos_spikes_timestamps)), 'g|', markersize=15, label='Positive')
ax1.plot(input_neg_spikes_timestamps, np.zeros_like(input_neg_spikes_timestamps), 'r|', markersize=15, label='Negative')

ax1.set_ylabel('Input', labelpad = 10)
ax1.set_ylim([-1, 2])
y_labels = ['pos.', 'neg.']
y_pos = np.arange(len(y_labels))
ax1.set_yticks(y_pos)
ax1.set_yticklabels(y_labels)
plt.setp(ax1.get_xticklabels(), visible=False)

# Plotting the output spikes
ax2 = fig.add_subplot(212, sharex=ax1)
ax2.plot(output_spikes_timestamps, np.zeros_like(output_spikes_timestamps), 'b|', markersize=15, label='Output')
ax2.set_ylabel('Output', labelpad = 10)
y_label = ['out.']
y_pos = np.arange(len(y_label))
ax2.set_yticks(y_pos)
ax2.set_yticklabels(y_label)

plt.xlabel(r'Time ($\mu$s)')
plt.subplots_adjust(top=0.780, bottom=0.280, left=0.175, right=0.950, hspace=0.300, wspace=0.200)
#plt.tight_layout()

# Saving out the figure
plt.show()

