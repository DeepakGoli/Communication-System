clear
close
L = 200000;                %length of input sequence
signal_power = 1;
x=randi([0 1],1 ,L);    %input sequence
%% BPSK
x_bpsk = zeros(1,L);
for k = 1:L
    if (x(k) == 1)
        x_bpsk(k) = 1;
    else 
        x_bpsk(k) = -1;
    end
end
%% BPSK+noise i,e received signal
SNR = -3:8;
itr = 1;
x_bpsk_noise = zeros(1,L);
error_prob = zeros(1,length(SNR));
theoritical_ber = zeros(1,length(SNR));
for m = 1:length(SNR)
    noise_power = signal_power/power(10,0.1*SNR(m));
    theoritical_ber(m) = 0.5.*erfc(sqrt(power(10,0.1*SNR(m))));
    for itr = 1:itr
        noise = (1/sqrt(2))*(randn(1,L)+1i*randn(1,L));
        x_bpsk_noise =  x_bpsk.*sqrt(signal_power)+noise.*sqrt(noise_power);
        x_demodulated = BPSK_demodulation(x_bpsk_noise);
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
function x_demodulated = BPSK_demodulation(x_received)
x_received = real(x_received);
L = length(x_received);
x_demodulated = zeros(1,L);
for k = 1:L
    if( x_received(k)>=0)
        x_demodulated(k) = 1;
    else
        x_demodulated(k) = 0;
    end
end
end
%% calculating bit error
function error_percentage = bit_error(x,x_demodulated)
error_percentage = 0;
L=length(x);
error_percentage = sum(abs(x-x_demodulated))/L;
end
