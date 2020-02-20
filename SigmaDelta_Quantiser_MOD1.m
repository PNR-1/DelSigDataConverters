%% %%%%%%%MOD 1
%
%   u ----> (+) --(er)--> (z^-1)/(1-z^-1) ---> y ---> (Quantizer) -----> v
%             ^ (-)                                                |
%             |                                                    |
%             |                                                    |
%             |                                                    |
%             ------------------------------------------------------
%% %%%%%%%%

Delta = 1;
NumLevels = 5;
Type = 'MidRise';

yn = 0; yn_1 = 0;
ern = 0; ern_1 = 0;

%% %%%%%%%%

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
x = y + sqrt((Amplitude/1e4)) * randn(size(y));
v = zeros(1,length(x));
%% %%%%%%%%
for i = 2:length(v)
    yn_1 = yn;
    ern_1 = ern;
    
    ern = x(i) - v(i-1);
    yn = yn_1 + ern_1;
    
    [v(i),overload,Qmin,Qmax] = util_quantizer(yn,Delta,NumLevels,Type);
    v(i) = v(i) + 1;
end

v = lowpass(v,F_tone*2,Fs);
v= v(1:Fs/(16*2*F_tone):end)
Fs = 32*F_tone;
%% %%%%%%%%%%%%%%%%%%%%%%%%%

N_fft = (Fs/F_tone) * FFT_number_of_cycles;
Fmin = Fs/N_fft;
Hanning_correction_Factor = 1.5;

[S,F] = pwelch(v,hanning(N_fft),N_fft/2,N_fft,Fs,'onesided');
S = Fmin * Hanning_correction_Factor * S .* ((OneSidedSpectrum+1)/2);
S = 20*log10(S);

figure
plot(F ,S);
xlabel('Frequency');
ylabel('dBV');
title('FFT');
grid on;




