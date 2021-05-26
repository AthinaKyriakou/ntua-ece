%ola_call
clear all; 

fs=16000;
win_t=0.04;
step_t=0.03;

M=win_t*fs; %window length
R=step_t*fs;  %hop size
N=3*M;  % winoverlap-add span

ola(M,R,N);
