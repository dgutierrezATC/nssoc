% TEST_TONE_GENERATOR Demo for the TONE_GENERATOR routine.
%
%   See also TONE_GENERATOR.

%   Author: Kamil Wojcicki, UTD, November 2011.

clear all; close all; clc; randn('seed',0); rand('seed',0); fprintf('.\n');


% inline function for periodogram spectrum computation
psd = @(x,w,nfft)( 10*log10(abs(fftshift(fft(x(:).'*diag(w(length(x))),nfft))).^2/length(x)) );


% define common parameters
fs = 48E3;                              % sampling frequency (Hz)
duration = 1000;                        % signal duration (ms)
N = floor(duration*1E-3*fs);            % signal length (samples)
nfft = 2^nextpow2( 4*N );               % FFT analysis length
freq = [ 0:nfft-1 ]/nfft*fs - fs/2;     % frequency vector (Hz)
%   window = @hanning;                      % analysis window function
%   window = @(N)( chebwin(N,40) );         % analysis window function
window = @(N)( chebwin(N,100) );        % analysis window function
format = '.wav';

% define parameters specific to generation of the single pure tone signal
amplitude = 1;                          % pure tone amplitude
frequencies = [500,1000,5000,10000,15000,20000];                        % pure tone frequency (Hz)
phase = pi/16;                          % pure tone phase (rad/sec)
fade_duration = 50;                    % fade-in and fade-out duration (ms)
fade_window = @(N)( hanning(N).^2 );    % fade-in and fade-out window function handle

for amplitude = 0.5:0.5:2.5
    for index = 1:length(frequencies)
        % generate a pure tone
        [ tone, time ] = tone_generator( fs, duration, amplitude, frequencies(index), phase, fade_duration, fade_window );

        % save pure tone as a .wav file
        puretone_wav_filename = 'pure_tone';
        puretone_wav_filename = strcat(puretone_wav_filename, '_fs', int2str(fs), 'duration', int2str(duration), 'frequency', int2str(frequencies(index)),'amplitude', num2str(amplitude),'_',int2str(index), format);
        audiowrite(puretone_wav_filename, tone, fs);
    end
end

% EOF