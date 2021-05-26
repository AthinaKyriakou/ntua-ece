function[stft]=mySTFT(x,L,R)

fs=16000;
nfft=2^nextpow2(L); %number of fft points
w=hamming(L); %hamming window used for windowing

x_framed=buffer(x,L,R,'nodelay'); %framed signal

[rown,coln]=size(x_framed); 

for i=1:coln
    x_windowed(:,i)=x_framed(:,i).*w; %windowed signal 
end;

stft=fft(x_windowed,nfft); %2D STFT matrix

end