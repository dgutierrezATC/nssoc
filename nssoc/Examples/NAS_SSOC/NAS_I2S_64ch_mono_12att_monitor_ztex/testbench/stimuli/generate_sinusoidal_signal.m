function wave = generate_sinusoidal_signal(fs, amp, frequency, duration, delay, add_noise)
    ts = 1/fs;
    t = [0:ts:duration];
    
    t_offset = delay * fs;

    wave = amp * sin(2 * pi * frequency * (t-t_offset));

    if add_noise == 1
        wave = awgn(wave, 1, 'measured');
    end

    figure()
    stem(t, wave);
end