clc
clear all
close all


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% DECLARING VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F_tone = 1e3;                       %Frequency of Tone
OSR = 32;
Fs = F_tone * OSR;                  %Sampling Frequency
time_step = 1/Fs;                   %Time between samples
total_number_of_cycles = 2^12;      %Total number of complete cycles to 
                                    %                      simulate for
FFT_number_of_cycles = 2^7;         %Number of cycles used in 1 FFT 
                                    %                      computation
Amplitude = 1;                      %Amplitude of the sine wave
OneSidedSpectrum = 1;%------------->%Set = 1 for 1 sided spectrum
                     %------------->%Set = 0 for 2 sided spectrum
Bits = 1;                                   
q = 2*Amplitude/2^Bits;             %Quantisation Interval
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% CREATING (y,t) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time_period = 1/F_tone;
t = 0:time_step:time_period * total_number_of_cycles;
y_noiseless = Amplitude*sin(2*pi*F_tone * t);
%%%%%%% Adding Additive White Gaussian Noise (0 mean, Amplitude/400 Variance)
y = y_noiseless+(q/2)*(rand(size(y_noiseless))*2-1);


figure
plot(t,y);
xlabel('Time');
ylabel('Waveform Units');
title('Waveform versus Time');
grid on
hold on;
plot(t,y_noiseless,'linewidth',2);
legend('With Noise','Noiseless');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% FFT COMPUTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N_fft = (OSR) * FFT_number_of_cycles;
Fmin = Fs/N_fft;
Hanning_correction_Factor = 1.5;

[S,F] = pwelch(y,hanning(N_fft),N_fft/2,N_fft,Fs,'onesided');
S = Fmin * Hanning_correction_Factor * S .* ((OneSidedSpectrum+1)/2);
S = 20*log10(S);

Noise_floor = (q^2/12) * 1/sqrt(2*max(F));
figure
semilogx(F,S);
xlabel('Frequency');
ylabel('dBV');
title('FFT');
grid on;
hold on;
semilogx(F,ones(size(S)) * 20*log10(Noise_floor/(Fmin)),'linewidth',2);