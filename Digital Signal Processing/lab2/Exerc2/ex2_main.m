clear all; close all; clc;

%read the signal with audioread
fs=44100;
[x,fs]=audioread('music_dsp18.wav');
x=x(:,1); %keeping only the one channel

%specific signal parameters
L=512; %window_length
f=[1:L/2]*(fs/L); %frequency
b=13.*atan(0.00076.*f)+3.5.*atan((f/7500).^2); %bark scale
Tq=3.64.*(f/1000).^(-0.8)-6.5.*exp(-0.6.*((f/1000)-3.3).^2)+10.^(-3).*(f/1000).^4; %Absolute Threshold of Hearing
M=32;  %total number of filters

%normalization of the signal
x_normalized=x/max(abs(x));

%framing of the signal
x_framed=buffer(x_normalized,L,0,'nodelay');

%windowing of the signal for Tg
w=hanning(L); %hanning window used for windowing
[rown,coln]=size(x_framed); 
for i=1:coln
    x_windowed(:,i)=x_framed(:,i).*w; %windowed signal 
end
Tg=T_G2(x_windowed,L,Tq,b,fs);


%use of psychoascoustic model and ADAPTABLE QUANTIZER
%function that returns the reconstructed signal and the total number of
%bits used

[x_rec_adapt,total_bits_adapt]=adaptable_quantizer(x_framed,L,M,fs,Tg,length(x));   


%use of NON-ADAPTABLE QUANTIZER
%function that returns the reconstructed signal and the total number of
%bits used

[x_rec_non_adapt,total_bits_non_adapt]=non_adaptable_quantizer(x_framed,L,M,fs,Tg,length(x));    


%sound([x_rec_adapt;x_rec_non_adapt],fs); 
%plotting inputs-outputs
figure;
plot(x);
title(['Input Sound Signal']);
xlabel('Time(samples)');
ylabel('Amplitude');
%Adaptive Quantizer
figure;
plot(x_rec_adapt,'m')
title(['Reconstructed Sound Signal - Adaptive Quantizer']);
xlabel('Time(samples)');
ylabel('Amplitude');

figure;
error_adapt=x-x_rec_adapt;
plot(error_adapt,'r')
title(['Error - Adaptive Quantizer']);
xlabel('Time(samples)');
ylabel('Amplitude');

%Non Adaptive Quantizer 
figure;
plot(x_rec_non_adapt,'m')
title(['Reconstructed Sound Signal - Non Adaptive Quantizer']);
xlabel('Time(samples)');
ylabel('Amplitude');

figure;
error_non_adapt=x-x_rec_non_adapt;
plot(error_non_adapt,'r')
title(['Error - Non Adaptive Quantizer']);
xlabel('Time(samples)');
ylabel('Amplitude');

%MSE
error1=error_adapt.^2;
error2=error_non_adapt.^2;
mse_adapt=0;
mse_non_adapt=0;
for i=1:length(x)
    mse_adapt=mse_adapt+error1(i);
    mse_non_adapt=mse_non_adapt+error2(i);
end
mse_adapt=mse_adapt/length(x);
mse_non_adapt=mse_non_adapt/length(x);
disp(mse_adapt);
disp(mse_non_adapt);


