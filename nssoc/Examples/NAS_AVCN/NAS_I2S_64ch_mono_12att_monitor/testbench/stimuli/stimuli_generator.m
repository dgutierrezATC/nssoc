% Typical parameters:
%   -Sine: sample_freq = 96e3; duration = 0.01; amplitude = 1000;
%          freq = 1000; withNoise = 0;
%   -Chirp: sample_freq = 1e6; duration = 1; start_freq = 1; 
%          end_freq = 100;

% Output file parameters
output_left_filename = '_left.bin';
output_right_filename = '_right.bin';

% Signal parameters
signal_type = 0; % 0--> Sine; 1--> Chirp
signal_sample_freq = 10e6; % In Hz
signal_duration = 1.0; % In seconds
signal_amplitude = 1;
signal_add_with_noise_flag = 0;
signal_delay_left = 0; % In seconds
signal_delay_right = 0; % In seconds

% Sine generator parameters
signal_freq = 700; % In Hz

% Chirp generator parameters
signal_start_freq = 100; % In Hz
signal_end_freq = 10e3; % In Hz

% Select between pure sinusoidal signal or chirp signal
if signal_type == 0
    generated_signal_left = generate_sinusoidal_signal(signal_sample_freq, signal_amplitude, signal_freq, signal_duration, signal_delay_left, signal_add_with_noise_flag);
    generated_signal_right = generate_sinusoidal_signal(signal_sample_freq, signal_amplitude, signal_freq, signal_duration, signal_delay_right, signal_add_with_noise_flag);
else
    writeChirpFile(filename, sample_freq, start_freq, end_freq, duration);
end

output_left_filehandler = fopen(output_left_filename,'w');
output_right_filehandler = fopen(output_right_filename,'w');

fwrite(output_left_filehandler,generated_signal_left,'int32');
fclose(output_left_filehandler);

fwrite(output_right_filehandler,generated_signal_right,'int32');
fclose(output_right_filehandler);

output_left_filehandler = fopen(output_left_filename);
output_right_filehandler = fopen(output_right_filename);

readed_signal_left = fread(output_left_filehandler, 'int32');
readed_signal_right = fread(output_right_filehandler, 'int32');

figure()
stem(readed_signal_left);

figure()
stem(readed_signal_right);