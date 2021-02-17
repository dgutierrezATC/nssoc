%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created by Daniel Gutierrez-Galan
% University of Seville 2021
% Last modification: 16/jan/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all; clc; fprintf('.\n');

%%%% Define common parameters
fs = 48000;    % sampling frequency (Hz)
duration = 1;  % signal duration (seconds)
power = 0;
format = '.wav';

%%%% Define destination path
destination_absolute_path = '';

%%%% If you want to generate a complete dataset, use a for loop for varying
%%%% one parameter (eg. the power of the signal, in dBs) or keeping all the
%%%% parameters fixed and then generating different files with the same
%%%% config (note that the wgn function uses random numbers, so every time
%%%% the result should be different.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% For multiple files
% num_files = 10;
% 
% for index = 1:num_files
%     % generate a white noise file
%     filename = 'white_noise_';
%     fs_string = int2str(fs);
%     duration_string = int2str(duration);
%     power_string = int2str(power);
%     filename = strcat(filename, 'fs', fs_string, 'duration', duration_string, 'power', power_string, '_', int2str(index), format);
%     noise = white_noise_generator(fs, duration, power, filename);
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% For multiple files with parameter variation
num_files = 3;

for power = 6:-6:-6
    for index = 1:num_files
        % generate a white noise file
        filename = 'white_noise_';
        fs_string = int2str(fs);
        duration_string = int2str(duration);
        power_string = int2str(power);
        filename = strcat(filename, 'fs', fs_string, 'duration', duration_string, 'power', power_string, '_', int2str(index), format);
        noise = white_noise_generator(fs, duration, power, filename);
    end
end

fprintf('Files generated correctly!\n');

% EOF