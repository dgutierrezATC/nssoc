import pyrirgen
import matplotlib.pyplot as plt
import soundfile as sf
import numpy as np
from scipy.signal import chirp

################################################################################
# Room definition
################################################################################

# Room dimensions [x y z] (m)
room_dimensions = 3                          # Room dimension
room_size = [8, 10, 4]

# Receiver position [x y z] (m)
microphone_center_pos = [4, 9, 2]
microphone_separation = 0.20

microphone_right_pos = microphone_left_pos = microphone_center_pos
microphone_right_pos[0] = microphone_right_pos[0] - (microphone_separation / 2.0)
microphone_left_pos[0] = microphone_left_pos[0] - (microphone_separation / 2.0)

microphones_pos = [microphone_right_pos, microphone_left_pos]

# Source positions [x y z] (m)
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
chirp_end_freq = 500
chirp_duration = 1.0

# Generate the signal and plot it
x = chirp(t, chirp_start_freq, chirp_duration, chirp_end_freq)
plt.plot(t, x)
plt.show()

################################################################################
# Microphones configuration
################################################################################

# Type of microphone
mtype = 'hypercardioid'
# Microphone orientation (rad)
orientation = [math.pi/2, 0]
# Enable high-pass filter
hp_filter = True

"""


all_s1 = []
all_s2 = []

# For all the sound sources
for r in rec:
    # Generate response for RIGHT microphone
    h1 = pyrirgen.generateRir(L, s, np.array(r) - np.array([(microphone_separation/2.0), 0, 0]), soundVelocity=c, fs=fs, reverbTime=rt, nSamples=n)
    # Generate response for LEFT microphone
    h2 = pyrirgen.generateRir(L, s, np.array(r) + np.array([(microphone_separation/2.0), 0, 0]), soundVelocity=c, fs=fs, reverbTime=rt, nSamples=n)

    xx1 = np.convolve(x, h1)
    xx2 = np.convolve(x, h2)
    all_s1.append(xx1)
    all_s2.append(xx2)

    plt.figure()
    plt.plot(h1)
    plt.show()
"""