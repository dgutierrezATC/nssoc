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
# First, we add the input spikes to the testbench results file list (index 0)
testbench_results_filenames.append("delay_line_connection_tb_input_spikes.txt")
# Then, we add the output spikes to the testbench results file list (index 1)
testbench_results_filenames.append("delay_line_connection_tb_output_spikes.txt")

###############################################################
# Read files
###############################################################

# Create one list for the input events timestamps and for the addresses
input_spikes_timestamps = []
input_spikes_addresses = []

# Create one list of lists for the output events timestamps and for the addresses
# WARNING! : delay_lines_connection_num_lines value should be the same that the one set in the VHDL simulation
delay_lines_connection_num_lines = 16
output_spikes_timestamps = [[] for index in range(0, delay_lines_connection_num_lines)]
output_spikes_addresses = [[] for index in range(0, delay_lines_connection_num_lines)]

# Open and read each testbench result file
for testbench_results_file_index in range(0, len(testbench_results_filenames)):
    # Get the first testbench result file absolute path
    testbench_results_file_path = testbench_results_files_folder_path + testbench_results_filenames[testbench_results_file_index]

    # Open the file as a csv file
    with open(testbench_results_file_path) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=';')

        # For each row, extract the data
        for row in csv_reader:
            # First, let's process the timestamps. Since from the simulator the time ref is added (ps),
            # we need to remove it and convert the value from string to numerical value
            ts = row[1]
            ts = ts.replace(" ps", "")
            ts = int(ts)
            # Then, we convert the time reference from ps to microseconds
            ts = ts * 1.0e-6

            # Then, process the address
            # Depending on the file being read, we append the values to the correct list
            if testbench_results_file_index == 0:
                input_spikes_timestamps.append(ts)
                input_spikes_addresses.append(0)
            elif testbench_results_file_index == 1:
                # Get the address
                ad = row[0]
                ad = int(ad)

                output_spikes_timestamps[ad].append(ts)
                output_spikes_addresses[ad].append(0)
            else:
                print("ERROR!")

# After both input and output events files have been readed, let's plot them

# First, create the figure and the subplots
fig = plt.figure(figsize=(4.6, 6.0))

# Change the figure title
fig.suptitle('Delay line testbench results')

# Plotting the facilitatory and trigger spikes
ax1 = fig.add_subplot(17,1,1)
ax1.plot(input_spikes_timestamps, input_spikes_addresses, 'g|', markersize=15, label='Input')
y_labels = ['input']
y_pos = np.arange(len(y_labels))
ax1.set_yticks(y_pos)
ax1.set_yticklabels(y_labels)
plt.setp(ax1.get_xticklabels(), visible=False)

for index in range(0,delay_lines_connection_num_lines):
    # Plotting the output spikes
    ax2 = fig.add_subplot(17,1,index+2, sharex=ax1)
    ax2.plot(output_spikes_timestamps[index], output_spikes_addresses[index], 'b|', markersize=15, label='Output')
    y_label = ['output']
    y_pos = np.arange(len(y_label))
    ax2.set_yticks(y_pos)
    ax2.set_yticklabels(y_label)

plt.xlabel(r'Time ($\mu$s)')
#plt.subplots_adjust(top=0.780, bottom=0.280, left=0.175, right=0.950, hspace=0.300, wspace=0.200)
plt.tight_layout()
plt.show()