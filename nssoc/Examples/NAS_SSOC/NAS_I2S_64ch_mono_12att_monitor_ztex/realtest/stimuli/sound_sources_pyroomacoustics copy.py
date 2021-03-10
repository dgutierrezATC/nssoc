import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile
from scipy.signal import fftconvolve
import pyroomacoustics as pra
import os

corners = np.array([[0,0], [0,3], [3,3], [3,0]]).T  # [x,y]

# specify signal source
absolute_folder_path = os.path.dirname(__file__)
filename = "pure_tone_fs48000duration1000frequency1000amplitude1_4"
extension = ".wav"
fs, audio = wavfile.read(os.path.join(absolute_folder_path, filename + extension))

# set max_order to a low value for a quick (but less accurate) RIR
room = pra.Room.from_corners(corners, fs=fs, max_order=3, materials=pra.Material(0.2, 0.15), ray_tracing=True, air_absorption=True)
room.extrude(2., materials=pra.Material(0.2, 0.15))

# Set the ray tracing parameters
room.set_ray_tracing(receiver_radius=0.5, n_rays=10000, energy_thres=1e-5)

# add source and set the signal to WAV file content
room.add_source([0.5, 0.5, 0.5], signal=audio)

# add two-microphone array
R = np.array([[1.4, 1.6], [1.5, 1.5], [0.5,  0.5]])  # [[x], [y], [z]]
room.add_microphone(R)

# compute image sources
#room.image_source_model()

# visualize 3D polyhedron room and image sources
fig, ax = room.plot(img_order=3)
fig.set_size_inches(18.5, 10.5)

plt.show()

room.plot_rir()
fig = plt.gcf()
fig.set_size_inches(20, 10)

plt.show()

t60 = pra.experimental.measure_rt60(room.rir[0][0], fs=room.fs, plot=True)
print(t60)

room.simulate()
print(room.mic_array.signals.shape)

# original signal
print("Original WAV:")

print("Simulated propagation to first mic:")

room.mic_array.to_wav(
    os.path.join(absolute_folder_path,filename + "_out" + extension),
    norm=True,
    bitdepth=np.int16,
)

plt.show()