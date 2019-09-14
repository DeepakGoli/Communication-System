clear
close
L = 400000;                %length of input sequence
signal_power = 1;
x=randi([0,1],1,L);      %input Sequence

%% QPSK
x_qpsk = zeros(1,round(L/2));
k=1;
while k<= L    
    idx = round((k+1)/2);
    if x(k)==0 && x(k+1)==0
        x_qpsk(idx) =  1+1i;                    
    elseif x(k)==0 && x(k+1)==1
        x_qpsk(idx) = -1+1i;
    elseif x(k)==1 && x(k+1)==1
        x_qpsk(idx) = -1-1i;
    else
        x_qpsk(idx) =  1-1i;
    end
    k=k+2;
end
%% QPSK+noise ie received signal
SNR = -3:8;
itr = 1;
x_qpsk_noise = zeros(1,round(L/2));
error_prob = zeros(1,length(SNR));
theoritical_ber = zeros(1,length(SNR));
for m = 1:length(SNR)
    noise_power = signal_power/power(10,0.1*SNR(m));
    theoritical_ber(m) = 0.5.*erfc(sqrt(power(10,0.1*SNR(m))));
    for itr = 1:itr
        noise = (1/sqrt(2))*(randn(1,round(L/2))+1i*randn(1,round(L/2)));
        x_qpsk_noise =  x_qpsk.*sqrt(signal_power)+noise.*sqrt(noise_power);
        x_demodulated = QPSK_demodulation(x_qpsk_noise);
        error_percentage = bit_error(x,x_demodulated);
        error_prob(m) = error_prob(m)+(error_percentage/itr);
    end
end
semilogy(SNR,error_prob,'--bs') ;
title('BER vs SNR');xlabel('SNR(db)');ylabel('Bit Error Rate');
hold on
semilogy(SNR,theoritical_ber,':m*')
legend('Simulated','Theoretical');
%% demodulation
% encoding decoding logic in binary to decimal
%if logic=0 => -1-i
%if logic=1 => -1+i
%if logic=2 =>  1-i
%if logic=3 =>  1+i
function x_demodulated = QPSK_demodulation(x_received)
L = length(x_received);
x_demodulated = zeros(1,L*2);
k=1;
while k<= 2*L
    x_real = real(x_received(round((k+1)/2)));
    x_imaginary = imag(x_received((k+1)/2));
    logic = 2*(x_real>=0)+1*(x_imaginary>=0);
    if (logic == 0)
        x_demodulated(k)   = 1;
        x_demodulated(k+1) = 1;
    elseif (logic == 1)
        x_demodulated(k)   = 0;
        x_demodulated(k+1) = 1;
    elseif (logic == 2)
        x_demodulated(k)   = 1;
        x_demodulated(k+1) = 0;
    else
        x_demodulated(k)   = 0;
        x_demodulated(k+1) = 0;
    end
    k=k+2;
end
end
%% calculating bit error

function error_percentage = bit_error(x,x_demodulated)
L=length(x);
error_percentage = sum(abs(x-x_demodulated))./L;
end
