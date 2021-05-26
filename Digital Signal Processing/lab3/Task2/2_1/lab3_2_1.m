%____________________2.1 Beaforming in simulated signals___________________

%___________________A. Delay and Sum Beamforming___________________________

clear all; clc; close all; 

N=7;        %number of mics
d=0.04;     %distance between mics
fs=48000;   %sampling frequency
c=340;      %sound velocity in air

theta_source = pi/4; %angle of source

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
audiowrite('sim_ds.wav',y_output,fs);

%only the noise part of the signal is captured
sound(noise,fs);

%Waveforms of unoised signal,output of the beamformer and noisy signal from the central mic
figure('Name', 'Waveform of the Unoised Signal')
k=0:(1/fs):(length(source)-1)/fs; %%time (samples) for xaxis
plot(k,source);
title('Unoised (Clear) Voice Signal');
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
title('Unoised (Clear) Voice Signal');
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

%SNR of noisy signal from central mic and of y(t)
sx=mean(mic(4,:).^2)-mean(mic(4,:))^2;
noise_mic=(mic(4,:))'-source;
ss=mean(noise_mic.^2)-mean(noise_mic)^2;
SNR_centralmic=10*log10(sx/ss);
display(SNR_centralmic);

sx=mean(y_output.^2)-mean(y_output)^2;
noise_beamformer=y_output-source;
ss=mean(noise_beamformer.^2)-mean(noise_beamformer)^2;
SNR_beamformer=10*log10(sx/ss);
display(SNR_beamformer);

SNR_total=SNR_beamformer/SNR_centralmic;
display(SNR_total);

%___________________B. Wiener Filtering in Simulated Signals___________________________
%frame parameters
t_start=0.36;
t_stop=0.39;
x=mic(4,:);
y=x';
noise=y-source;
st=source(t_start*fs:t_stop*fs);
ut=noise(t_start*fs:t_stop*fs);
xt=y(t_start*fs:t_stop*fs);
[Pu,f]=pwelch(ut,[],[],length(ut),fs,'twosided');
[Px,f]=pwelch(xt,[],[],length(xt),fs,'twosided');
[Ps,f]=pwelch(st,[],[],length(st),fs,'twosided');
H_w=1-(Pu./Px); %the response
%___________PLOTTING_________
figure('Name', 'Filter Response IIR Wiener');
plot(f,10*log10(abs(H_w)));
title(['The Filter Response IIR Wiener']);
xlabel('frequency (Hz)');
ylabel('Gain Hw(ù) (dB)');
xlim([0,8000]);

%calculate the speech distortion index 
nsd = (abs(1-H_w)).^2;

%___________PLOTTING__________
figure('Name', 'Speech distortion');
plot(f,10*log10(nsd));
title(['Speech Distotion Index']);
xlabel('frequency (Hz)');
ylabel('Gain nsd(dB)');
xlim([0,8000]);

%Wiener filtering and signals' comparison (Q3)
X_w = fft(xt); %DFT of the input signal x(t)
H_w(1201:1440) = H_w(1200); %making Hw the same size as Xw (number of samples)
Wiener_out_t=ifft(H_w.* X_w); %output of filtering in time domain
[P_out_Wiener,f] = pwelch(Wiener_out_t,[],[],length(Wiener_out_t),fs,'twosided');
%___________PLOTTING__________
figure('Name', 'Wiener output for different inputs');
hold on
plot(f,10*log10(Px),'b');           %noisy signal input
plot(f,10*log10(Pu),'g');           %noise
plot(f,10*log10(Ps),'m');           %clear signal
plot(f,10*log10(P_out_Wiener),'r'); %wiener output
title(['Wiener outputs']);
xlabel('frequency (Hz)');
ylabel('Gain (dB)');
xlim([0,8000]);
hold off
legend('noisy signal input','noise','clear signal','wiener output');

%SNR calculations 
out_t_real= real(Wiener_out_t);
SNR_out_t = snr(out_t_real, out_t_real-st); %SNR of the output
SNR_xt = snr(xt, ut); %SNR of the input x(t)
display(SNR_out_t);
display(SNR_xt);


%Comparison
difference=SNR_beamformer-SNR_out_t; %SNR difference between the 2 methods
beltiwsh_SNR=(difference/SNR_out_t)*100; % percent
%display(difference);
display(beltiwsh_SNR); 

%estimation of the power spectrum of the output of the beamformer
beamf=y_output(t_start*fs:t_stop*fs);
[P_out_beam,f]=pwelch(beamf,[],[],length(beamf),fs,'twosided');
%___________PLOTTING__________
figure('Name', 'comparison between Wiener filtering and Beamforming');
hold on
plot(f,10*log10(Px),'b');   %input
plot(f,10*log10(Ps),'m');   %clear signal
plot(f,10*log10(P_out_beam),'r');%beamforming output
plot(f,10*log10(P_out_Wiener),'g');%wiener output
title(['Wiener output and beamforming output']);
xlabel('frequency (Hz)');
ylabel('Gain (dB)');
xlim([0,8000]);
hold off
legend('input','clear signal','beamforming output','wiener output');
