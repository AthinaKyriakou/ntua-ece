%____________________2.2 Beaforming in real signals___________________

%___________________A. Delay and Sum Beamforming and SSNR___________________________

clear all; clc; close all; 

N=7;        %number of mics
d=0.04;     %distance between mics
fs=48000;   %sampling frequency
c=340;      %sound velocity in air

theta_source = 90*pi/180; %angle of source (deg)

%read sound signal and noise signal
source = audioread('source.wav');
mic(1,:) = audioread('sensor_0.wav');
mic(2,:) = audioread('sensor_1.wav');
mic(3,:) = audioread('sensor_2.wav');
mic(4,:) = audioread('sensor_3.wav');
mic(5,:) = audioread('sensor_4.wav');
mic(6,:) = audioread('sensor_5.wav');
mic(7,:) = audioread('sensor_6.wav');

%fourier transform of microphone noised signals 
for i=1:N
    dft_mic(i,:)=fft(mic(i,:));
end

%calculate weights w
w = -pi:((2*pi)/length(mic(1,:))):pi-((2*pi)/length(mic(1,:)));

%calculate d(ks)
for i=1:N
    d_ks(i,:) = exp(1i*(N-1)*w*fs*d*(cos(theta_source))/(2*c)).*exp(-1i*(i-1)*w*fs*d*(cos(theta_source))/c);
end


%delay filter
for i=1:N
    Y(i,:)=(d_ks(i,:)).*(dft_mic(i,:));   %frequency      
    y(i,:)=ifft(Y(i,:));                  %time
    real_y(i,:)=real(y(i,:)); %take only the real part of the signal
end

%final signal
y_output=zeros;
for i=1:N
    y_output=y_output + real_y(i,:);
end
y_output=y_output/N; %average
y_output = y_output';
noise = y_output - source;
audiowrite('real_ds.wav',y_output,fs);

%only the noise part of the signal is captured
%sound(noise,fs);

%___________PLOTTING__________
%Waveforms of unoised signal,output of the beamformer and noisy signal from the central mic
figure('Name', 'Waveform of the Unoised Signal')
k=0:(1/fs):(length(source)-1)/fs; %time (samples) for xaxis
plot(k,source);
title('Unoised (Clear) Voiced Signal');
xlabel('time (samples)');
ylabel('Amplitude');
figure('Name', 'Waveform of the Noisy Signal (central mic)')
k=0:(1/fs):(length(mic(4,:))-1)/fs;
plot(k,mic(4,:));
title('Noisy Signal (central mic)');
xlabel('time (samples)');
ylabel('Amplitude');
figure('Name', 'Waveform of the Output of DS Beamformer')
k=0:(1/fs):(length(y_output)-1)/fs; 
plot(k,y_output);
title('y(t)Output of DS Beamformer');
xlabel('time (samples)');
ylabel('Amplitude');


%Spectrogramms
%window_length=0.005*fs;       %(samples)   
%overlap=window_length/2;  % 50% overlap
figure('Name', 'Spectogramm of the Unoised Signal')
[s,f,t,ps] = spectrogram(source);
surf(t,f,10*log10(ps),'edgecolor','none');
title('Unoised Signal');
view(0,90);
figure('Name', 'Spectogramm of the Noisy Signal (central mic)')
[s,f,t,ps] = spectrogram(mic(4,:));
surf(t,f,10*log10(ps),'edgecolor','none');
view(0,90);
title('Noisy Signal from the central mic');
figure('Name', 'Spectogramm of y(t) Output of DS Beamformer')
[s,f,t,ps] = spectrogram(y_output);
surf(t,f,10*log10(ps),'edgecolor','none');
view(0,90);
title('y(t) Output of DS Beamformer');

%Calculate SSNR
x=mic(4,:);
mic_noise=x(1:15000); %only noise from the central mic
%sound(mic_noise,fs);
t = 0.025; %seconds
win_len= t*fs;  %window length (samples)
M=0;
sum=0;
P_mic_noise=mean(mic_noise.^2);
mic_framed=buffer(x',win_len);
[n,m]=size(mic_framed);
for i=1:m
    Px=mean(mic_framed(:,i).^2);
    Ps=abs(Px-P_mic_noise);
    SNR=10*log10(Ps/P_mic_noise);
    if SNR>0
        M=M+1;
        if SNR>35
            SNR=35;
        end
        sum=sum+SNR;
    end
end
SSNR_centralmic=sum/M;
display(SSNR_centralmic);


beamformer_noise=y_output(1:15000);
%sound(beamformer_noise,fs);
M=0;
sum=0;
P_beamformer_noise=mean(beamformer_noise.^2);
beamformer_framed=buffer(y_output,win_len);
[n,m]=size(beamformer_framed);
for i=1:m
    Px=mean(beamformer_framed(:,i).^2);
    Ps=abs(Px-P_beamformer_noise);
    SNR=10*log10(Ps/P_beamformer_noise);
    if SNR>0
        M=M+1;
        if SNR>35
            SNR=35;
        end
        sum=sum+SNR;
    end
end
SSNR_beamformer=sum/M;
display(SSNR_beamformer);


%___________________B. Post-Wiener Filtering___________________________
overlap=0.5*win_len; 
step=win_len-overlap;
sig_framed=buffer(y_output,win_len,overlap);
[r,c]=size(sig_framed);
w=hamming(win_len);

u_noise=sig_framed(:,4); %only noise from the central mic
%sound(u_noise,fs);
for i=1:c
    [Px_framed,f]=pwelch(sig_framed(:,i),[],[],length(sig_framed(:,i)),'twosided');
    [Pu_noise,f]=pwelch(u_noise,[],[],length(u_noise),'twosided');
    H_w=1-(Pu_noise./Px_framed);
    y_windowed=sig_framed(:,i).*w;
    X_w=fft(y_windowed);
    filter_output(:,i)=ifft(H_w.*X_w);  %filter output for each frame
end
len=length(y_output);
wiener_output=zeros(len,1);
%first 720 frames
for n=1:step
    wiener_output(n)=filter_output(n,1);
end 
for i=2:(c-1)
    for n=1:win_len
        wiener_output((i-2)*step+n)=wiener_output((i-2)*step+n) + filter_output(n,i);
    end
end
for n=(((c-1)*step)+1):len
    wiener_output(n)=filter_output(n-(step*(c-1)),c);
end

sound(wiener_output,fs);
audiowrite('real_mmse.wav',wiener_output,fs);

%___________PLOTTING__________
figure('Name','Waveform of the Wiener output');
k=0:(1/fs):(length(wiener_output)-1)/fs;
plot(k,wiener_output);
title(['Wiener Output']);
xlabel('time (samples)');
ylabel('Amplitude');

figure('Name','Spectrogramm of the Wiener output');
[s,f,t,ps] = spectrogram(wiener_output);
surf(t,f,10*log10(ps),'edgecolor','none');
view(0,90);
title('Output of wiener filtering');

%Calculate SSNR
noise=wiener_output(1:15000); %only noise 
M=0;
sum=0;
P_noise=mean(noise.^2);
wiener_framed=buffer(wiener_output,win_len);
[n,m]=size(wiener_framed);
for i=1:m
    Px=mean(wiener_framed(:,i).^2);
    Ps=abs(Px-P_noise);
    SNR=10*log10(Ps/P_noise);
    if SNR>0
        M=M+1;
        if SNR>35
            SNR=35;
        end
        sum=sum+SNR;
    end
end
SSNR_wiener=sum/M;
display(SSNR_wiener);

%Calculate SSNRs average
SSNRs_average=(SSNR_beamformer+SSNR_centralmic)/2;
display(SSNRs_average);

veltiwsh_SSNR=((SSNR_wiener-SSNRs_average)/SSNRs_average)*100;
display(veltiwsh_SSNR);
