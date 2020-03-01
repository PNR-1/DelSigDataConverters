clc
clear all
close all

%% This code models a 6bit ADC. Bits is set as 8, and 4LSB of noise is added
%% This will make the effective BITS as 6
%% It also calculates the Predicted Noise floor and Obtained Noise floor
%% and the Theoretical SNR versus Obtained SNR
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% DECLARING VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F_tone = 3.5e3;                       %Frequency of Tone
OSR = 64;
Fs = F_tone * OSR;                  %Sampling Frequency
time_step = 1/Fs;                   %Time between samples
total_number_of_cycles = 2^15;      %Total number of complete cycles to 
                                    %                      simulate for
FFT_number_of_cycles = 2^9;         %Number of cycles used in 1 FFT 
                                    %                      computation
Vref = 2; 
Amplitude = Vref/2;                     %Amplitude of the sine wave
Amax = Vref/2;

Bits = 8;                                   
q = Vref/2^Bits;             %Quantisation Interval
NG = 0.375; %Hanning
CG = 0.5; %Hanning
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% CREATING (y,t) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time_period = 1/F_tone;
t = 0:time_step:time_period * total_number_of_cycles;
y_noiseless = (Amplitude)*sin(2*pi*F_tone * t);
%%%%%%% Adding Uniform Noise of 4 LSB. That should reduce the 8bit ADC to a
%%%%%%% 6bit ADC. Otherwise, because my sampling frequency is a multiple of
%%%%%%% my Tone, the spectrum will skirt.
y_noise = y_noiseless + (2*q) * (rand(size(t))*2 - 1);
y = floor( y_noise/q )* q; %


figure
plot(t,y);
xlabel('Time');
ylabel('Waveform Units');
title('Waveform versus Time');
grid on
hold on;
plot(t,y_noise,'linewidth',2);
plot(t,y_noiseless,'linewidth',2);
legend('Quantised','With Noise','Clean');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% FFT COMPUTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N_fft = OSR * FFT_number_of_cycles;
Fmin = Fs/N_fft;
sn = (NG * Fmin) / (CG)^2;

[S,F] = pwelch(y-mean(y),hanning(N_fft),N_fft/2,N_fft,Fs,'onesided');
semilogx(F,20*log10(S*sn))

N_floor = 20*log10((4*q)^2/(6*Fs))
Plot_floor = 20*log10(median(S))
Plot_higher_by = 10^(((Plot_floor - N_floor)/20))

Theoretical_SNR = 1.76 + 6.02*(Bits-2) + 20*log10(Amplitude/Amax)

signal_indx = F_tone/Fmin+1;
Fundamental = (sum(S(signal_indx-20:signal_indx+20)));
Noise = (sum(S(2:signal_indx-21)) + sum(S(signal_indx+21:end)));
SNR = 10*log10(Fundamental/Noise)
