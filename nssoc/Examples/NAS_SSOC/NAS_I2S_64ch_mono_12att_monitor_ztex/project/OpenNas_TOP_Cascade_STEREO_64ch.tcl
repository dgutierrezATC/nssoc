#///////////////////////////////////////////////////////////////////////////////
#//                                                                           //
#//    Copyright © 2016  Angel Francisco Jimenez-Fernandez                    //
#//                                                                           //
#//    This file is part of OpenNAS.                                          //
#//                                                                           //
#//    OpenNAS is free software: you can redistribute it and/or modify        //
#//    it under the terms of the GNU General Public License as published by   //
#//    the Free Software Foundation, either version 3 of the License, or      //
#//    (at your option) any later version.                                    //
#//                                                                           //
#//    OpenNAS is distributed in the hope that it will be useful,             //
#//    but WITHOUT ANY WARRANTY; without even the implied warranty of         //
#//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the            //
#//    GNU General Public License for more details.                           //
#//                                                                           //
#//    You should have received a copy of the GNU General Public License      //
#//    along with OpenNAS. If not, see <http://www.gnu.org/licenses/>.        //
#//                                                                           //
#///////////////////////////////////////////////////////////////////////////////


#///////////////////////////////////////////////////////////////////////
#/////////////////////////////// README ////////////////////////////////
#///////////////////////////////////////////////////////////////////////
# For running the script:
#     -Open Vivado 20xx.x Tcl Shell
#     -Change the current directory to which the .tcl file is located
#     -Write the command: source scriptname.tcl
#///////////////////////////////////////////////////////////////////////

#
# Input files
#

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# the top-level of our HDL source:

# Set the project name
set _xil_proj_name_ "OpenNas_Cascade_STEREO_64ch"

variable script_file
set script_file "OpenNas_Cascade_STEREO_64ch.tcl"

# Create project
create_project ${_xil_proj_name_} ./${_xil_proj_name_} -part xc7a75tcsg324-2

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/${_xil_proj_name_}.cache/ip" -objects $obj
set_property -name "part" -value "xc7a75tcsg324-2" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "target_language" -value "VHDL" -objects $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
    create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
set_property -name "top" -value "OpenNas_TOP_Cascade_STEREO_64ch" -objects $obj

set hdl_files [ list \
 [file normalize "${origin_dir}/../sources/I2S_inteface_sync.vhd"] \
 [file normalize "${origin_dir}/../sources/Spikes_Generator_signed_BW.vhd"] \
 [file normalize "${origin_dir}/../sources/i2s_to_spikes_stereo.vhd"] \
 [file normalize "${origin_dir}/../sources/AER_HOLDER_AND_FIRE.vhd"] \
 [file normalize "${origin_dir}/../sources/AER_DIF.vhd"] \
 [file normalize "${origin_dir}/../sources/spikes_div_BW.vhd"] \
 [file normalize "${origin_dir}/../sources/Spike_Int_n_Gen_BW.vhd"] \
 [file normalize "${origin_dir}/../sources/spikes_LPF_fullGain.vhd"] \
 [file normalize "${origin_dir}/../sources/spikes_2LPF_fullGain.vhd"] \
 [file normalize "${origin_dir}/../sources/spikes_2BPF_fullGain.vhd"] \
 [file normalize "${origin_dir}/../sources/CFBank_64.vhd"] \
 [file normalize "${origin_dir}/../sources/AER_DISTRIBUTED_MONITOR_MODULE.vhd"] \
 [file normalize "${origin_dir}/../sources/AER_DISTRIBUTED_MONITOR.vhd"] \
 [file normalize "${origin_dir}/../sources/DualPortRAM.vhd"] \
 [file normalize "${origin_dir}/../sources/ramfifo.vhd"] \
 [file normalize "${origin_dir}/../sources/handsakeOut.vhd"] \
 [file normalize "${origin_dir}/../sources/AER_OUT.vhd"] \
 [file normalize "${origin_dir}/../sources/OpenNas_TOP_Cascade_STEREO_64ch.vhd"] \
]

# constraints with pin placements. This file will need to be replaced if you
# are using a different Xilinx device or board.
# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/../constraints/ZTEX_constraints.xdc"]"

#////////////////////////////////////////////////////////////////////////
#// Create a new project or open project                               //
#////////////////////////////////////////////////////////////////////////
puts "INFO: Project created: ${_xil_proj_name_}"

puts "Running synthesis step..."
launch_runs impl_1 -to_step write_bitstream

puts "\nEnd of Tcl script.\n\n"
