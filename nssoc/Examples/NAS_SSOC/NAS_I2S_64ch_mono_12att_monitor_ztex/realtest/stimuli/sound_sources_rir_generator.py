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

################################################################################
# Imports
################################################################################
import pyrirgen
import matplotlib.pyplot as plt
import soundfile as sf
import numpy as np
from scipy.signal import chirp
import os

################################################################################
# Path configuration
################################################################################
absolute_folder_path = os.path.dirname(__file__)

################################################################################
# Room definition
################################################################################

# Room dimensions [x y z] (m)
room_dimensions = 3                          # Room dimension
room_size = [8, 10, 4]

# Receiver position [x y z] (m)
microphone_center_pos = [4, 9, 2]
microphone_separation = 0.20

# Source positions [x y z] (m)
num_sound_sources = 8
sound_sources_pos = [[1, 8, 2],
                    [2, 5, 2],
                    [1, 2, 2],
                    [4, 1, 2],
                    [6, 2, 2],
                    [5, 5, 2],
                    [7, 5, 2],
                    [7, 9, 2]]  

# Create the room
fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

# Set the room dimension
ax.set_xlim(0, room_size[0])
ax.set_ylim(0, room_size[1])
ax.set_zlim(0, room_size[2])

# Add the microphone pair
ax.scatter(microphone_center_pos[0]-(microphone_separation/2.0), microphone_center_pos[1], microphone_center_pos[2], marker='d', s=100, c='blue')
ax.scatter(microphone_center_pos[0]+(microphone_separation/2.0), microphone_center_pos[1], microphone_center_pos[2], marker='d', s=100, c='red')

# Add the sound sources
for sound_source in sound_sources_pos:
    ax.scatter(sound_source[0], sound_source[1], sound_source[2], marker='o', s=100, label=sound_source)

ax.set_xlabel('X Label')
ax.set_ylabel('Y Label')
ax.set_zlabel('Z Label')

ax.legend()

plt.show()

################################################################################
# Room environmental conditions
################################################################################

# Sound velocity (m/s)
c = 340
# Reverberation time (s)
rt = 0.2
# Reflection order
order = -1

################################################################################
# Sound definition
################################################################################

# Sound sample frequency (samples/s)
fs = 16000
# Number of samples
n = 4096
# Sound duration (s)
duration = 2.0
# Time ticks
t = np.arange(0.0, duration, 1. / fs)

# Sound generation (Hz, s)
########
# NOTE: if a sine wave is desired, then chirp_start_freq and chirp_end_freq must have the same value
########
chirp_start_freq = 250
chirp_end_freq = 600
chirp_duration = 1.0

# Generate the signal and plot it
x = chirp(t, chirp_start_freq, chirp_duration, chirp_end_freq)
plt.plot(t, x)
plt.show()

################################################################################
# Microphones configuration
################################################################################
"""# Type of microphone
mtype = 'hypercardioid'
# Microphone orientation (rad)
orientation = [math.pi/2, 0]
# Enable high-pass filter
hp_filter = True"""


################################################################################
# RIR generator
################################################################################

all_s1 = []
all_s2 = []

# For all the sound sources
for sound_source in sound_sources_pos:
    # Generate response for RIGHT microphone
    h1 = pyrirgen.generateRir(room_size, microphone_center_pos, np.array(sound_source) - np.array([(microphone_separation/2.0), 0, 0]), soundVelocity=c, fs=fs, reverbTime=rt, nSamples=n)
    # Generate response for LEFT microphone
    h2 = pyrirgen.generateRir(room_size, microphone_center_pos, np.array(sound_source) + np.array([(microphone_separation/2.0), 0, 0]), soundVelocity=c, fs=fs, reverbTime=rt, nSamples=n)

    """
    h = pyrirgen.generateRir(L, s, r, soundVelocity=c, fs=fs, reverbTime=rt, nSamples=n, micType=mtype, nOrder=order, nDim=dim, isHighPassFilter=hp_filter)
    print(len(h), len(h[0]))
    """

    xx1 = np.convolve(x, h1)
    xx2 = np.convolve(x, h2)
    all_s1.append(xx1)
    all_s2.append(xx2)

for i in range(num_sound_sources):
    filename = 'nas_soc_pos{}_chirp.wav'.format(i)
    sf.write(os.path.join(absolute_folder_path, filename), np.array([all_s1[i], all_s2[i]]).T, fs)
