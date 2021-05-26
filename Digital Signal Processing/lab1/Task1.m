clear all; clc; close all;

fs=16000;
[y,fs]=audioread('speech_utterance.wav');
hamming_t = 0.02;
w= hamming_t*fs;                        %the window length
h=hamming(w);                           %hamming window

%~~~~~~~1.1 Short Time Energy ~~~~~~
sig_framed=buffer(y,w,w-1,'nodelay');   %the framed signal
[n,m]=size(sig_framed);                 %n=rows, m=columns
for i=1:m
    sig_windowed(:,i)=sig_framed(:,i).*h;   %windowing
end;

En=sum(sig_windowed.^2,1);              %Short Time Energy (STE)

figure;
subplot(2,1,1);
t2=[0:length(y)-1]/fs;
plot(t2,y);
title(['Input Signal y']);
xlabel('Time(Samples)');
ylabel('Amplitude y');

subplot(2,1,2);
t1=[0:length(En)-1]/fs;
plot(t1,En);
title(['Short Time Energy En']);
xlabel('Time(Samples)');
ylabel('Amplitude');
grid on;

%~~~~~~~1.1 Zero Crossing Rate ~~~~~~
sig_signed(1)=abs(sign(y(1)));
for i=2:length(y)
    sig_signed(i)=abs(sign(y(i))-sign(y(i-1)));     %signal=|sgn(y)-sgn(y-1)|
end;

sig_signed=sig_signed';

sig_framed=buffer(sig_signed,w,w-1,'nodelay');      %new framed signal

[n,m]=size(sig_framed);
for i=1:m
    sig_windowed(:,i)=sig_framed(:,i).*h;
end;

Zn=sum(sig_windowed,1);                             %Zero Crossing Rate (ZCR) 

figure;
subplot(2,1,1);
t2=[0:length(y)-1]/fs;
plot(t2,y);
title(['Input Signal ']);
xlabel('Time(samples)');
ylabel('Amplitude ');

subplot(2,1,2);
t1=[0:length(Zn)-1]/fs;
plot(t1,Zn);
title(['Zero Crossing Rate Zn']);
xlabel('Time(samples)');
ylabel('Amplitude ');
grid on;
