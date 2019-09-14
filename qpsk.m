clc
close all
clear all
input_signal=randi([0,1],1,10000);      %input bits
k=1;
i=sqrt(-1);
for j=1:2:length(input_signal)          % mapping input bits to symbols
    if input_signal(j)==0 && input_signal(j+1)==0
        modulated_signal(k)=(1+i);                     %modulated symbols
    elseif input_signal(j)==0 && input_signal(j+1)==1
        modulated_signal(k)=(-1+i);
    elseif input_signal(j)==1 && input_signal(j+1)==1
        modulated_signal(k)=(-1-i);
    else
        modulated_signal(k)=(1-i);
    end
    k=k+1;
end
transmitted_signal=modulated_signal;     % transmitted signals
num=1;
signal_power=2;                          % Power of input signal
SNR=0:10;
errorprobability=zeros(1,length(SNR));   %Probability of error for each SNR
for SNR=0:10
    for iterations=1:100
        noise_power=signal_power/power(10,0.1*SNR);     % Power of Noise Signal
        noise=(1/sqrt(2))*(randn(1,length(transmitted_signal))+i*randn(1,length(transmitted_signal)));   %noise signal
        k=1;
        received_signal=sqrt(signal_power)*transmitted_signal+(sqrt(noise_power))*noise;    %Received signal
        for j=1:length(received_signal)
            if real(received_signal(j))>=0
                if imag(received_signal(j))>=0
                    demodulated_signal(k)=0;demodulated_signal(k+1)=0;
                else
                    demodulated_signal(k)=1;demodulated_signal(k+1)=0;
                end
            else
                if imag(received_signal(j))>=0
                    demodulated_signal(k)=0;demodulated_signal(k+1)=1;
                else
                    demodulated_signal(k)=1;demodulated_signal(k+1)=1;
                end
            end
            k=k+2;
        end
        error_count(num)=0;                                 %error count
        for j=1:length(demodulated_signal)                  %Detection of errors
            if demodulated_signal(j)~=input_signal(j)
                error_count(num)=error_count(num)+1;
            else
                error_count(num)=error_count(num);
            end
        end
        errorprobability(num)=error_count(num)/(100*length(demodulated_signal))+errorprobability(num);   %Probability of error
    end
    num=num+1;
 end
SNR=0:10;
theoritical=qfunc(sqrt(2*power(10,0.1*SNR)));       % Theoretical probability of errors
semilogy(SNR,errorprobability,'--bs');title('BER vs SNR');xlabel('SNR(db)');ylabel('Bit Error Rate');
hold on;
semilogy(SNR,theoritical,':m*');
legend('Simulated','Theoretical');