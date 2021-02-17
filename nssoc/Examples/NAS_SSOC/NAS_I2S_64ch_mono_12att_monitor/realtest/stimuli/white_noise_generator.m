%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created by Daniel Gutierrez-Galan
% University of Seville 2021
% Last modification: 16/jan/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function noise = white_noise_generator(frequency_sample, duration, power, wav_filename)

%%%% Input parameters
% frequency_sample : In Hz
% duration         : In seconds
% power            : In decibels
% wav_filename     : String

%%%% White noise generation

% Calculate the number of samples according to the frequency sample and the
% duration
num_samples = frequency_sample * duration;

% Generate the white noise signal
noise = wgn(num_samples, 1, power);

% Save the signal as a .wav file
audiowrite(wav_filename, noise, frequency_sample);

fprintf('File %s generated! \n', wav_filename);