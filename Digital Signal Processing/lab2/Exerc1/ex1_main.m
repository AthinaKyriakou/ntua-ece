%main program
%calls function T_G that takes as input the WINDOWED SIGNAL and
%returns as output the total threshold Tg(i) (256x1271 matrix)


clear all; close all; clc;

%read the signal with audioread
fs=44100;
[s,fs]=audioread('music_0.wav');
s=s(:,1); %keeping only the one channel

frame=100; %specific frame for our analysis
L=512; %window_length
f=[1:L/2]*(fs/L); %frequency
b=13.*atan(0.00076.*f)+3.5.*atan((f/7500).^2); %bark scale
Tq=3.64.*(f/1000).^(-0.8)-6.5.*exp(-0.6.*((f/1000)-3.3).^2)+10.^(-3).*(f/1000).^4; %Absolute Threshold of Hearing

figure(1);
plot(Tq,'r--');
title(['Absolute Threshold of Hearing']);
xlabel('Frequency (Hz)');
ylabel('SPL (dB)'); 

%normalization of the signal s 
s_normalized=s/max(abs(s));

%plotting input normalized signal
figure(2);
t=[0:length(s_normalized)-1]/fs; %time
plot(t,s_normalized);
title(['Input Signal ']);
xlabel('Time(samples)');
ylabel('Amplitude ');

%framing of the signal
s_framed=buffer(s_normalized,L,0,'nodelay'); %framed signal

%windowing of the signal
w=hanning(L); %hanning window used for windowing
[rown,coln]=size(s_framed); 
for i=1:coln
    s_windowed(:,i)=s_framed(:,i).*w; %windowed signal 
end

%plotting windowed
figure(3);
n=[1:L];
plot(n,s_windowed(:,frame));
title(['Windowed signal']);
xlabel('Samples');
ylabel('Amplitude');

%calculation of the total threshold Tg
Tg=T_G(s_windowed,L,frame,Tq,b); 


