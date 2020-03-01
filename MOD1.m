clc
clear all
close all
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
Amplitude = Vref/2;                 %Amplitude of the sine wave
Amax = Vref/2;

Bits = 6+2;                           %6-BIT ADC                          
q = Vref/2^Bits;                    %Quantisation Interval
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
y_noise = y_noiseless;
%%y_noise=0.5;
%y = floor( y_noise/q )* q; % Removing the normal quantiser
%% %%%%%%%MOD 1
%
%   u ----> (+) --(er)--> 1/(1-z^-1) ---> y ---> (Quantizer) --|z^-1|---> v
%             ^ (-)                                                   |
%             |                                                       |
%             |                                                       |
%             |                                                       |
%             ---------------------------------------------------------
%% %%%%%%%%
yn = 0; yn_1 = 0;
ern = 0; ern_1 = 0;
v = zeros(1,length(t)); %u is y_noise
for i = 2:length(v)
    yn_1 = yn;
    ern_1 = ern;
    
    yn = yn_1+ern_1;
    v(i) = floor(yn/q) * q + (4*q) * (rand() - 1/2);   
    ern = y_noise(i) - v(i);
end %end for


figure
plot(t,v);
xlabel('Time');
ylabel('Waveform Units');
title('Waveform versus Time');
grid on
hold on;
plot(t,y_noise,'linewidth',2);
%%plot(t,y_noiseless,'linewidth',2);
legend('Quantised','With Noise','Clean');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% FFT COMPUTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N_fft = OSR * FFT_number_of_cycles;
Fmin = Fs/N_fft;
sn = (NG * Fmin) / (CG)^2;

[S,F] = pwelch(v-mean(v),hanning(N_fft),N_fft/2,N_fft,Fs,'onesided');
figure
semilogx(F,20*log10(S*sn))

Theoretical_SNR = 1.76 + 6.02*(Bits-2) + 20*log10(Amplitude/Amax) - 3
% minus 3 because MOD1 doubles the noise, while shaping it out

signal_indx = F_tone/Fmin+1;
Fundamental = (sum(S(signal_indx-20:signal_indx+20)));
Noise = (sum(S(2:signal_indx-21)) + sum(S(signal_indx+21:end)));
SNR = 10*log10(Fundamental/Noise)
