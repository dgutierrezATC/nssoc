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
import pyrirgen
import matplotlib.pyplot as plt
import IPython.display as ipd
import soundfile as sf
import numpy as np
from scipy.signal import chirp
import math
import os

################################################################################
# Documentation
################################################################################
"""
https://www.audiolabs-erlangen.de/fau/professor/habets/software/rir-generator
https://github.com/ehabets/RIR-Generator
https://github.com/ty274/rir-generator
https://pypi.org/project/rir-generator/

"""

###############################################################
# Functions
###############################################################
def generate_sound_positions(reference_position, distance_to_reference, num_sound_positions, verbose=False):

    # Create the list of positions
    sound_positions = [[0,0,0] for i in range(0, num_sound_positions)]

    # Calculate the angle slot according to the number of sound positions to generate
    """
    ----------------------------------------------------------------------------
    NOTE: We took into account the horizontal line as reference: 180 degrees
    ----------------------------------------------------------------------------
    """
    angle_slot = 180.0 / num_sound_positions

    # Create variables for positions estimation
    """
            alfa
            |\
            | \
      ca    |  \   ab
            |   \
            |    \
      tetta ------- betta
               bc
    """

    angle_betta = 0.0
    angle_alfa = 0.0
    angle_tetta = 0.0

    seg_ab = 0.0
    seg_bc = 0.0
    seg_ca = 0.0

    # Calculate the sound positions according to the number of desired sounds
    for i in range(0, num_sound_positions):

        # Tetta angle is always 90 degrees
        angle_tetta = 90.0
        # Beta angle depends on the current sound source position
        angle_betta = i * angle_slot
        # Alfa angle is the rest up to 180 degrees
        angle_alfa = 180.0 - angle_tetta - angle_betta

        # The segment AB is always the distance between the microphones and the sound source
        seg_ab = distance_to_reference

        # Convert angle from degrees to radians and calculate its cos and sin to get the lenght of the segments BC and CA
        angle_betta_rads = angle_betta * (math.pi / 180.0)
        seg_bc = seg_ab * math.cos(angle_betta_rads)
        seg_ca = seg_ab * math.sin(angle_betta_rads)

        # Calculate the bisector of the betta angle, which indicates the exact position of the sound source
        angle_betta_bisector = angle_betta + (angle_slot / 2.0)
        # Convert it to radians
        angle_betta_bisector_rads = angle_betta_bisector * (math.pi / 180.0)
        # And get the X,Y coordinates
        x = seg_ab * math.cos(angle_betta_bisector_rads)
        y = seg_ab * math.sin(angle_betta_bisector_rads)

        # Save the X,Y,Z coordinates taking into account that the reference used for calculations were the microphones' position,
        # and we need to add the relative position of the microphones inside the room
        """
        __________________________             __________________________
        |                        |             |                        |
        |                        |             |                        |
        |                        |             |                        |
        |                        |             |                        |
        |                        |    -->      |                        |
        |                        |             |                        |
        |            x           |             |            x           |
        |                        |             |                        |
        |________________________|             |________________________|
        -d/2         0          d/2            0           d/2          d


        """
        sound_positions[i][0] = x + reference_position[0]
        sound_positions[i][1] = y + reference_position[1]
        sound_positions[i][2] = reference_position[2]

    if verbose:
        print(sound_positions)
    
    return sound_positions

###############################################################
# Path configuration
###############################################################
# Get the absolute path of the python file
file_absolute_path = os.path.dirname(__file__)

###############################################################
# Main
###############################################################

#########################
# Room configuration
#########################

# Sound velocity (m/s)
c = 340

# Room dimensions [x y z] (m)
L = [10, 10, 4]
# Reverberation time (s)
rt = 0.2

#########################
# Receiver configuration
#########################

# Receiver position [x y z] (m)
rec = [[5, 3, 2]]
# Microphone type
mtype = 'subcardioid'
# Microphones orientations
orientation_left_mic = [math.pi/2, 0]
orientation_righ_mic = [-(math.pi)/2, 0]

#########################
# Sound sources configuration
#########################

# Source position [x y z] (m) MODIFY HERE
s = [2, 6, 2]
# Distance to the microphones (m)
dist = 3.0
# Number of sound sources
n_sounds = 9
# Generate sound source positions
sources_positions = generate_sound_positions(rec[0], dist, n_sounds, True)

#########################
# Sound signal configuration
#########################

# Sample frequency (samples/s)
fs = 48000
# Number of samples
n = 4096

# Sound duration (s)
sound_duration = 0.5
# Frequency (Hz)
sound_freq = 2500
# Generate time array
t = np.arange(0, sound_duration, 1. / fs)
# Generaty signal array
x = chirp(t, sound_freq, sound_duration, sound_freq)

#########################
# Room visualization
#########################

# Create the room
fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

# Set the room dimension
ax.set_xlim(0, L[0])
ax.set_ylim(0, L[1])
ax.set_zlim(0, L[2])

# Add the microphone pair
ax.scatter(rec[0][0]-(.15), rec[0][1], rec[0][2], marker='d', s=100, c='blue')
ax.scatter(rec[0][0]+(.15), rec[0][1], rec[0][2], marker='d', s=100, c='red')

# Add the sound sources
for sound_source in sources_positions:
    ax.scatter(sound_source[0], sound_source[1], sound_source[2], marker='o', s=100, label=sound_source)

ax.set_xlabel('X Label')
ax.set_ylabel('Y Label')
ax.set_zlabel('Z Label')

ax.legend()

plt.show()

#########################
# Save info into textfile
#########################

# Generate a txt with the information of the configuration
info_filename = "generation_config_log.txt"
f = open(os.path.join(file_absolute_path, info_filename), "w")
f.write("c=" + str(c) + "\n")
f.write("L=" + str(L) + "\n")
f.write("rt=" + str(rt) + "\n")
f.write("rec=" + str(rec) + "\n")
f.write("mtype=" + mtype + "\n")
f.write("orientation_left_mic=" + str(orientation_left_mic) + "\n")
f.write("orientation_righ_mic=" + str(orientation_righ_mic) + "\n")
f.write("dist=" + str(dist) + "\n")
f.write("n_sounds=" + str(n_sounds) + "\n")
f.write("sources_positions=" + str(sources_positions) + "\n")
f.write("fs=" + str(fs) + "\n")
f.write("n=" + str(n) + "\n")
f.write("sound_duration=" + str(sound_duration) + "\n")
f.write("sound_freq=" + str(sound_freq) + "\n")
f.write("generated_files:" + "\n")

#########################
# Generate RIR
#########################

# For each sound source
for j in range(0, n_sounds):

    # Get the coordinates
    s = sources_positions[j]

    all_s1 = []
    all_s2 = []

    for r in rec:
        # Get the RIR
        h1 = pyrirgen.generateRir(L, s, np.array(r) - np.array([.15, 0, 0]), soundVelocity=c, fs=fs, reverbTime=rt, nSamples=n, orientation = orientation_left_mic)
        h2 = pyrirgen.generateRir(L, s, np.array(r) + np.array([.15, 0, 0]), soundVelocity=c, fs=fs, reverbTime=rt, nSamples=n, orientation = orientation_righ_mic)

        # Do a convolution to obtain the sound response
        xx1 = np.convolve(x, h1)
        xx2 = np.convolve(x, h2)
        all_s1.append(xx1)
        all_s2.append(xx2)

    # Save the response to a wav file
    for i in range(len(rec)):
        output_wav_filename = 'nssoc_puretone_' + str(sound_freq) + 'Hz_dist' + str(dist) + 'm_pos_' + str(j) + 'of' + str(n_sounds) + '.wav'
        f.write(output_wav_filename + "\n")
        #sf.write(os.path.join(file_absolute_path, output_wav_filename), np.array([all_s1[i], all_s2[i]]).T, fs)

# Finally, close the file
f.close()