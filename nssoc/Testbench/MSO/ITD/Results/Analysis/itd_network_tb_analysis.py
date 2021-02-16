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
testbench_results_filenames.append("itd_network_tb_input_spikes.txt")
# Then, we add the output spikes to the testbench results file list (index 1)
testbench_results_filenames.append("itd_network_tb_output_spikes.txt")

###############################################################
# Read files
###############################################################

# Create one list for the input events timestamps and for the addresses
num_inputs = 2
input_spikes_timestamps = [[] for index in range(0, num_inputs)]
input_spikes_addresses = [[] for index in range(0, num_inputs)]

# Create one list of lists for the output events timestamps and for the addresses
# WARNING! : delay_lines_connection_num_lines value should be the same that the one set in the VHDL simulation
num_outputs = 16
output_spikes_timestamps = [[] for index in range(0, num_outputs)]
output_spikes_addresses = [[] for index in range(0, num_outputs)]

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
            ad = row[0]
            ad = int(ad)

            # Depending on the file being read, we append the values to the correct list
            if testbench_results_file_index == 0:
                input_spikes_timestamps[ad].append(ts)
                input_spikes_addresses[ad].append(ad)
            elif testbench_results_file_index == 1:
                output_spikes_timestamps[ad].append(ts)
                output_spikes_addresses[ad].append(0)
            else:
                print("ERROR!")

# After both input and output events files have been readed, let's plot them

# First, create the figure and the subplots
fig = plt.figure(figsize=(4.6, 10.0))

# Change the figure title
fig.suptitle('ITD network testbench results')

# Plotting the facilitatory and trigger spikes
num_subplots = num_inputs + num_outputs

ax_input_list = []
for index in range(0, num_inputs):
    if(index == 0):
        ax_input_list.append(fig.add_subplot(num_subplots, 1, index + 1))
    else:
        ax_input_list.append(fig.add_subplot(num_subplots, 1, index + 1, sharex=ax_input_list[0]))
    
    ax_input_list[index].plot(input_spikes_timestamps[index], input_spikes_addresses[index], 'g|', markersize=15, label='Input')
    
    y_labels = [str(index)]
    y_pos = np.arange(len(y_labels))
    ax_input_list[index].set_yticks(y_pos)
    ax_input_list[index].set_yticklabels(y_labels)
    plt.setp(ax_input_list[index].get_xticklabels(), visible=False)

ax_output_list = []
for index in range(0, num_outputs):
    ax_output_list.append(fig.add_subplot(num_subplots,1,num_inputs + index + 1, sharex=ax_input_list[0]))
    ax_output_list[index].plot(output_spikes_timestamps[index], output_spikes_addresses[index], 'b|', markersize=15, label='Output')

    y_labels = [str(index)]
    y_pos = np.arange(len(y_labels))
    ax_output_list[index].set_yticks(y_pos)
    ax_output_list[index].set_yticklabels(y_labels)
    if(index < (num_subplots - 1)):
        plt.setp(ax_output_list[index].get_xticklabels(), visible=False)
    else:
        plt.setp(ax_output_list[index].get_xticklabels(), visible=True)

plt.xlabel(r'Time ($\mu$s)')
#plt.tight_layout()
plt.show()
