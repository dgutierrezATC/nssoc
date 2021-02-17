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


#*** External clock ***
set_property PACKAGE_PIN P15 [get_ports i_sys_clock]
set_property IOSTANDARD LVCMOS33 [get_ports i_sys_clock]

#*** External reset button ***
#** Button PB2
set_property PACKAGE_PIN P5 [get_ports i_sys_reset]
set_property IOSTANDARD LVCMOS33 [get_ports i_sys_reset]

#*** GP_1 connector: audio input source ***
#*2:VDD | 4:SDOUT          | 6:SCLK          | 8:LRCK           | 10:SRC_SEL   *
#*      |                  |                 |                  |              *
#*1:GND | 3:PDM_DAT_LEFT   | 5:PDM_CLK_LEFT  | 7:PDM_CLK_RIGTH  | 9:PDM_DATA_R *

#*** I2S interface ***
set_property PACKAGE_PIN G16 [get_ports i_I2S_sck]
set_property IOSTANDARD LVCMOS33 [get_ports i_I2S_sck]

set_property PACKAGE_PIN G14 [get_ports i_I2S_sd]
set_property IOSTANDARD LVCMOS33 [get_ports i_I2S_sd]

set_property PACKAGE_PIN H16 [get_ports i_I2S_ws]
set_property IOSTANDARD LVCMOS33 [get_ports i_I2S_ws]

#*** AER out bus & protocol handshake ***
set_property PACKAGE_PIN M6 [get_ports {o_AER_data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_AER_data[0]}]

set_property PACKAGE_PIN N5 [get_ports {o_AER_data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_AER_data[1]}]

set_property PACKAGE_PIN L6 [get_ports {o_AER_data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_AER_data[2]}]

set_property PACKAGE_PIN P4 [get_ports {o_AER_data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_AER_data[3]}]

set_property PACKAGE_PIN L5 [get_ports {o_AER_data[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_AER_data[4]}]

set_property PACKAGE_PIN P3 [get_ports {o_AER_data[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_AER_data[5]}]

set_property PACKAGE_PIN N4 [get_ports {o_AER_data[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_AER_data[6]}]

set_property PACKAGE_PIN T1 [get_ports {o_AER_data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_AER_data[7]}]

set_property PACKAGE_PIN M4 [get_ports {o_AER_data[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_AER_data[8]}]

set_property PACKAGE_PIN R1 [get_ports {o_AER_data[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_AER_data[9]}]

set_property PACKAGE_PIN M3 [get_ports {o_AER_data[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_AER_data[10]}]

set_property PACKAGE_PIN R2 [get_ports {o_AER_data[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_AER_data[11]}]

set_property PACKAGE_PIN M2 [get_ports {o_AER_data[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_AER_data[12]}]

set_property PACKAGE_PIN P2 [get_ports {o_AER_data[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_AER_data[13]}]

set_property PACKAGE_PIN K5 [get_ports {o_AER_data[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_AER_data[14]}]

set_property PACKAGE_PIN N2 [get_ports {o_AER_data[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_AER_data[15]}]


set_property PACKAGE_PIN L4 [get_ports o_AER_req]
set_property IOSTANDARD LVCMOS33 [get_ports o_AER_req]

set_property PACKAGE_PIN N1 [get_ports i_AER_ack]
set_property IOSTANDARD LVCMOS33 [get_ports i_AER_ack]


