clear all; clc; close all;
fs=1000;
window_sec=0.04;   
L=window_sec*fs;    %the window length

%~~~~~~~3.1a Signal x[n]~~~~~~~
t=[0:1/fs:2];           %sampling
u=randn(1,length(t));   %gaussian white noise 
xn=1.5*cos(2*pi*80*t)+2.5*sin(2*pi*150*t)+0.15*u;
figure;
plot(t,xn);
title(['Signal x[n]']);
xlabel('Samples');
ylabel('Sample Values');
grid on;

%~~~~~~~3.1b Short Time Fourier Transform ~~~~~~~
[S,F,T]=spectrogram(xn,L,L/2,2^ (nextpow2(L)),fs,'yaxis'); %calculate stft with spectrogram routine ~ Gabor
figure;
surf(T,F,abs(S),'edgecolor','none');
shading interp; 
title(['|STFT(t,f)|']);
xlabel('Time(s)');
ylabel('Frequency(Hz)');
zlabel('Amplitude');
grid on;
colorbar;

%~~~~~~~3.1c Discrete Time Continuous Wavelet Transform~~~~~~~
[s,f]=wavescales('morl',fs);    %use function [s,f]= wavescales(wavelet,Fs) with wavelet=Morlet
%   CWTSTRUCT = CWTFT(SIG,'scales',SCA,'wavelet',WAV)
%from the file 
%==== To obtain the CWT coefficients =======
% cwtstruct = cwtft({x,1/Fs},'Scales',scales,'Wavelet','morl');
% cfs = cwtstruct.cfs; 

cwtstruct=cwtft({xn,1/fs},'scales',s,'wavelet','morl'); 
figure;
cfs=cwtstruct.cfs;      %cfs:coefficients of wavelet transform.
surf(t, f, abs(cfs) , 'edgecolor' , 'none');
title(['|DTCWT(t,f)|']);
xlabel('Time(s)');
ylabel('Frequency(Hz)');
zlabel('Amplitude');
grid on;
colorbar;

%~~~~~~~3.2a Signal x[n]~~~~~~~
xn=1.5*cos(2*pi*40*t) +1.5*cos(2*pi*100*t)+0.15*u;
xn(625)  = xn(625) + 5;     %5ä(t-0.625) dirac 
xn(650) = xn(650) + 5;      %5ä(t-0.650) dirac
figure;
plot(t,xn);
title(['Signal x[n]']);
xlabel('Samples');
ylabel('Sample Values');
grid on;

%~~~~~~~3.2b Short Time Fourier Transform ~~~~~~~
for i=0.02:0.02:0.06
    [S,F,T] = spectrogram(xn,i*fs,i*fs/2,2^(nextpow2(i*fs)),fs,'yaxis'); 
    figure;
    contour(T,F,abs(S));
    title(['|STFT(t,f)| of window length=' num2str(i) 'sec']);
    xlabel('Time(s)');
    ylabel('Frequency(Hz)');
    grid on;
end;
%%~~~~~~~3.2c Discrete Time Continuous Wavelet Transform~~~~~~~
cwtstruct = cwtft({xn,1/fs},'scales',s,'wavelet','morl');
cfs=cwtstruct.cfs; 
figure;
contour(t, f, abs(cfs));
title(['|DT_CWT(t,f)|']);
xlabel('Time(s)');
ylabel('Frequency(Hz)');
grid on;