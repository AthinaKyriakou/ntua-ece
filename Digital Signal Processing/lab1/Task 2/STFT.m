%calculating the STFT using stft function
clear all;
close all;
clc;

fs=16000;
[y,fs]=audioread('speech_utterance.wav');
N=length(y);
win_t=0.04;
step_t=0.02; 
L=win_t*fs; %window length
nfft=2^nextpow2(L);
R=step_t*fs; %hop (overlap) length
w=hamming(nfft); %hamming window used for reconstruction

%___2.1_____
%calculation of the STFT 2D matrix of the input signal y
stft=mySTFT(y,L,R);

%_______2.2______
%vowel /a/ and /o/
window_o=stft(:,round(0.580/step_t):round(0.600/step_t));
window_a=stft(:,round(0.770/step_t):round(0.790/step_t));

%column number and row number of the stft matrix
[rown,coln]=size(stft); 

%time and frequency vectors
t=(L/2:R:L/2+(coln-1)*R)/fs;
f=(0:rown-1)*fs/nfft;

%STFT Amplitude(spectrogram)
figure(1);
surf(t,f,abs(stft));
shading interp;
xlabel('Time(s)');
ylabel('Frequency (Hz)');
zlabel('Amplitude');
title('Amplitude Spectrogram of the Input Signal');
grid on;
colorbar;

%/o/ plot
figure(2);
surf(0:step_t:(size(window_o,2)-1)*step_t,f,abs(window_o));
shading interp;
xlabel('Time(s)');
ylabel('Frequency (Hz)');
zlabel('Amplitude');
title('Amplitude Spectrogram of Vowel /o/');
grid on;
colorbar;

%/a/ plot
figure(3);
surf(0:step_t:(size(window_a,2)-1)*step_t,f,abs(window_a));
shading interp;
xlabel('Time(s)');
ylabel('Frequency (Hz)');
zlabel('Amplitude');
title('Amplitude Spectrogram of Vowel /a/');
grid on;
colorbar;

%_____2.3____
%signal reconstruction
y_rwindowed=ifft(stft,nfft);   %reconstructed windows

for i=1:coln
    y_rframed(:,i)=real(y_rwindowed(:,i)).*w;   %reconstructed frames
end;

ynew=zeros(N,1);     %initialization reconstructed signal

%time_shift
for n=1:coln
  index=(n-1)*R;
  if index+nfft>N, break; end
  ynew(index+1:index+nfft)=ynew(index+1:index+nfft)+y_rframed(:,n);
end

sound([y;ynew],fs);
audiowrite('speech_utterance_rec.wav',ynew,fs);

