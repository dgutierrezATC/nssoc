"""--/////////////////////////////////////////////////////////////////////////////////
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
--/////////////////////////////////////////////////////////////////////////////////"""

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
testbench_results_filenames.append("avcn_input_pos_spikes.txt")
testbench_results_filenames.append("avcn_input_neg_spikes.txt")
testbench_results_filenames.append("avcn_output_spikes.txt")

###############################################################
# Read files
###############################################################
