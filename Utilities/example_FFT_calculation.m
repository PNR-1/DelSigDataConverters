clc
clear all
close all


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% DECLARING VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F_tone = 1e3;                       %Frequency of Tone
Fs = F_tone * 2048;                 %Sampling Frequency
time_step = 1/Fs;                   %Time between samples
total_number_of_cycles = 2^12;      %Total number of complete cycles to 
                                    %                      simulate for
FFT_number_of_cycles = 2^7;         %Number of cycles used in 1 FFT 
                                    %                      computation
Amplitude = 1;                      %Amplitude of the sine wave
OneSidedSpectrum = 1;               %Set = 1 for 1 sided spectrum
                                    %Set = 0 for 2 sided spectrum

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% CREATING (y,t) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time_period = 1/F_tone;
t = 0:time_step:time_period * total_number_of_cycles;
y = Amplitude*sin(2*pi*F_tone * t);

%%%%%%% Adding Additive White Gaussian Noise (0 mean, 0.1% Variance)
y = y + sqrt((Amplitude/1e4)) * randn(size(y));

figure
plot(t,y);
xlabel('Time');
ylabel('Waveform Units');
title('Waveform versus Time');
grid on

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% FFT COMPUTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N_fft = (Fs/F_tone) * FFT_number_of_cycles;
Fmin = Fs/N_fft;
Hanning_correction_Factor = 1.5;

[S,F] = pwelch(y,hanning(N_fft),N_fft/2,N_fft,Fs,'onesided');
S = Fmin * Hanning_correction_Factor * S .* ((OneSidedSpectrum+1)/2);
S = 20*log10(S);

figure
plot(F,S);
xlabel('Frequency');
ylabel('dBV');
title('FFT');