%Task 1
clear all; clc; close all;
%___________1.4 delay-and-sum beam pattern for uniform linear arrays(ULA)_________
f=2000;         %frequency Hz
theta_s=pi/2;   %90 (deg)
w=2*pi*f; 
c=340;          %340 m/s velocity of sound
theta=linspace(0,pi,1000);  %èe[0,2ð]

%1.4.1
d=0.04;  %distance cm
N=4;     %number of microphones
figure('Name','Delay-and-Sum beam pattern for differents microphones') ;
title('Delay-and-Sum beam pattern N=4,8,16');
xlabel('angle (deg)')
ylabel('Gain (dB)')
hold on
B_a = abs((1/N)*sin((N/2)*(w/c)*d*(cos(theta) - cos(theta_s)))./sin((1/2)*(w/c)*d*(cos(theta) - cos(theta_s))));
semilogy((180/pi)*theta,B_a,'b')
B_a = abs((1/(2*N))*sin(((2*N)/2)*(w/c)*d*(cos(theta) - cos(theta_s)))./sin((1/2)*(w/c)*d*(cos(theta) - cos(theta_s))));
semilogy((180/pi)*theta,B_a,'r')
B_a = abs((1/(4*N))*sin(((4*N)/2)*(w/c)*d*(cos(theta) - cos(theta_s)))./sin((1/2)*(w/c)*d*(cos(theta) - cos(theta_s))));
semilogy((180/pi)*theta,B_a,'g')
legend('N=4','N=8','N=16')
grid on; 
%1.4.2
N=8;
d=0.04;
figure('Name','Delay-and-Sum beam pattern for differents distances of microphones') ;
title('Delay-and-Sum beam pattern d=4cm,8cm,16cm');
xlabel('Angle (deg)')
ylabel('Gain (dB)')
hold on
B_a = abs((1/N)*sin((N/2)*(w/c)*d*(cos(theta) - cos(theta_s)))./sin((1/2)*(w/c)*d*(cos(theta) - cos(theta_s))));
semilogy((180/pi)*theta,B_a,'b')
B_a = abs((1/N)*sin((N/2)*(w/c)*(2*d)*(cos(theta) - cos(theta_s)))./sin((1/2)*(w/c)*(2*d)*(cos(theta) - cos(theta_s))));
semilogy((180/pi)*theta,B_a,'r')
B_a = abs((1/N)*sin((N/2)*(w/c)*(4*d)*(cos(theta) - cos(theta_s)))./sin((1/2)*(w/c)*(4*d)*(cos(theta) - cos(theta_s))));
semilogy((180/pi)*theta,B_a,'g')
legend('d=0.04','d=0.08','d=0.16')
grid on;

%1.4.3
N=8;
d=0.04;
theta_new=linspace(-pi,pi,30000);
for i= 0:0.5:1
    B_a = abs((1/N)*sin((N/2)*(w/c)*d*(cos(theta_new) - cos(i*theta_s)))./sin((1/2)*(w/c)*d*(cos(theta_new) - cos(i*theta_s))));
    figure;
    semilogr_polar(theta_new,B_a)
    title(['Delay-and-Sum beam pattern N=8,d=4cm and ès=' num2str(i*90) 'deg'])
end



