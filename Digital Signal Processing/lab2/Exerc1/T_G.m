function[Tg]=T_G(s_windowed,L,frame,Tq,b)
    %----------ex 1.1 estimation of spectrum (SPL)------------------
    ssym_fft=fft(s_windowed); %DFT with the use of fft function
    s_fft=ssym_fft(1:L/2,:);
    PN=90.302;
    s_P=PN+10.*log10((abs(s_fft)).^2); %power spectrum


    %plotting s_P in SPL
    figure(4);
    plot(s_P(:,frame));
    title(['Power Spectrum P(k)']);
    xlabel('Samples');
    ylabel('Magnitude (dB)');
    
    %----------ex 1.2 masks------------------
    s_ST=St(s_P); %binary matrix of masks
    [rown,coln]=size(s_ST);
    for i=1:coln
            for k=1:256
                if (s_ST(k,i)==1)
                    P_TM(k,i)=10*log10(10.^(0.1.*s_P(k-1,i))+10.^(0.1.*s_P(k,i))+10.^(0.1.*s_P(k+1,i)));
                else
                    P_TM(k,i)=0;
                end
                ks(k,i)=P_TM(k,i);       
            end
    end

    for i=1:L/2
            ks_frame(i)=ks(i,frame);    %k potition of a tone mask for a specific frame
    end

    ks_frame=ks_frame';
    ks_frame(ks_frame==0)=NaN;  %plot non zero samples

    %plotting Tone Maskers Frequency(Hz)
    figure(5);
    subplot(2,1,1);
    p1=plot(Tq,'r--');
    hold on
    p2=plot(s_P(:,frame));
    hold on
    stem(ks_frame,'o','k')
    hold off
    title(['Tone Maskers (Hz scale)']);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    legend([p1,p2],{'Absolute Threshold of hearing','Power Spectrum'}); 
    %plotting Tone Maskers Frequency(bark)
    subplot(2,1,2);
    p1=plot(b,Tq,'r--');
    hold on
    p2=plot(b,s_P(:,frame));
    hold on
    stem(b,ks_frame,'o','k')
    hold off
    title(['Tone Maskers (Bark scale)']);
    xlabel('Frequency (bark)');
    ylabel('Magnitude');
    legend([p1,p2],{'Absolute Threshold of hearing','Power Spectrum'});

    %Calculate Noise Maskers
    for i=1:coln
        P_NM(:,i)=findNoiseMaskers(s_P(:,i),P_TM(:,i),b);
    end

    for i=1:coln
            for k=1:256
                ks(k,i)=P_NM(k,i);
            end
    end

    for i=1:L/2
            ks_frame(i)=ks(i,frame); %k potition of a noise mask for a specific frame 
    end

    ks_frame=ks_frame';
    ks_frame(ks_frame==0)=NaN;  %plot non zero samples
    
    %plotting Noise Maskers Frequency(Hz)
    figure(6);
    subplot(2,1,1);
    p1=plot(Tq,'r--');
    hold on
    p2=plot(s_P(:,frame));
    hold on
    stem(ks_frame,'x','k')
    hold off   
    title(['Noise Maskers (Hz scale)']);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    legend([p1,p2],{'Absolute Threshold of hearing','Power Spectrum'});
    %plotting Noise Maskers Frequency(Bark)
    subplot(2,1,2);
    p1=plot(b,Tq,'r--');
    hold on
    p2=plot(b,s_P(:,frame));
    hold on
    stem(b,ks_frame,'x','k')
    hold off   
    title(['Noise Maskers (Bark scale)']);
    xlabel('Frequency (bark)');
    ylabel('Magnitude');
    legend([p1,p2],{'Absolute Threshold of hearing','Power Spectrum'});


    %----------ex 1.3 Reduction of masks------------------
    for i=1:coln
        [P_TMnew(:,i),P_NMnew(:,i)]=checkMaskers(P_TM(:,i)',P_NM(:,i)',Tq,b);
    end

    for i=1:coln
            for k=1:256
                ktm(k,i)=P_TMnew(k,i);
                knm(k,i)=P_NMnew(k,i);
            end
    end

    for i=1:L/2
            ktm_frame(i)=ktm(i,frame); 
            knm_frame(i)=knm(i,frame);
    end

    ktm_frame(ktm_frame==0)=NaN;
    knm_frame(knm_frame==0)=NaN;

    %plotting Checked Tone Maskers Frequency(Hz)
    figure(7);
    subplot(2,1,1);
    p1=plot(Tq,'r--');
    hold on
    p2=plot(s_P(:,frame));
    hold on
    stem(ktm_frame,'o','k')
    hold off
    title(['Checked Tone Maskers (Hz scale)']);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    legend([p1,p2],{'Absolute Threshold of hearing','Power Spectrum'}); 
    %plotting Checked Tone Maskers Frequency(bark)
    subplot(2,1,2);
    p1=plot(b,Tq,'r--');
    hold on
    p2=plot(b,s_P(:,frame));
    hold on
    stem(b,ktm_frame,'o','k')
    hold off
    title(['Checked Tone Maskers (Bark scale)']);
    xlabel('Frequency (bark)');
    ylabel('Magnitude');
    legend([p1,p2],{'Absolute Threshold of hearing','Power Spectrum'});

    %plotting Checked Noise Maskers Frequency(Hz)
    figure(8);
    subplot(2,1,1);
    p1=plot(Tq,'r--');
    hold on
    p2=plot(s_P(:,frame));
    hold on
    stem(knm_frame,'x','k')
    hold off   
    title(['Checked Noise Maskers (Hz scale)']);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    legend([p1,p2],{'Absolute Threshold of hearing','Power Spectrum'});
    %plotting Checked Noise Maskers Frequency(Bark)
    subplot(2,1,2);
    p1=plot(b,Tq,'r--');
    hold on
    p2=plot(b,s_P(:,frame));
    hold on
    stem(b,knm_frame,'x','k')
    hold off   
    title(['Checked Noise Maskers (Bark scale)']);
    xlabel('Frequency (bark)');
    ylabel('Magnitude');
    legend([p1,p2],{'Absolute Threshold of hearing','Power Spectrum'});


    %----------ex 1.4 individual Masking Thresholds------------------

    %Threshold for each sample ie[1,256] Tone maskers

    %find the max number of tone masks in a frame in the whole signal

    max_num_TM=0;

    for num_frame=1:coln %check each frame to find the max_num of tone masks
        max_new=length(find(P_TMnew(:,num_frame)>0)); %how tone maskers we have
        if(max_new>max_num_TM)
            max_num_TM=max_new;
        end
    end

    T_TM=zeros(L/2,max_num_TM,coln); %make a 3d array of zeros size 256 x max_num_TM x 1271

    for num_frame=1:coln %for each frame there is a threshold

        TM_places_array=find(P_TMnew(:,num_frame)>0);  %places of tones maskers in the frame

        for num_mask=1:length(TM_places_array)   %for each tone masker in the frame
        
            j=TM_places_array(num_mask);
    
            for i=1:L/2     %for each i frequency
            
                T_TM(i,num_mask,num_frame)=T_tm(b(i),b(j),P_TMnew(j,num_frame));
        
            end
        end
    end


    %Threshold for each sample ie[1,256] Noise maskers

    %find the max number of noise maskers in a frame in the whole signal

    max_num_NM=0;

    for num_frame=1:coln %check each frame to find the max_num of noise masks
        max_new=length(find(P_NMnew(:,num_frame)>0));
        if(max_new>max_num_NM)
            max_num_NM=max_new;
        end
    end

    T_NM=zeros(L/2,max_num_NM,coln); %make a 3d array of zeros size 256 x max_num_NM x 1271

    for num_frame=1:coln %for each frame there is a threshold
 
        NM_places_array=find(P_NMnew(:,num_frame)>0);  %places of noise maskers in the frame

        for num_mask=1:length(NM_places_array)   %for each noise masker in the frame

            j=NM_places_array(num_mask);

            for i=1:L/2     %for each i frequency

                T_NM(i,num_mask,num_frame)=T_nm(b(i),b(j),P_NMnew(j,num_frame));

            end
        end
    end


    %----------ex 1.5 Global Masking Threshold------------------

    for num_frame=1:coln
        for i=1:L/2
            Tg(i,num_frame)=10^(0.1.*Tq(i));
            for TTM_mask=1:max_num_TM %number of tone maskers
                Tg(i,num_frame)=Tg(i,num_frame)+10^(0.1*T_TM(i,TTM_mask,num_frame));
            end
            for TNM_mask=1:max_num_NM 
                Tg(i,num_frame)=Tg(i,num_frame)+10^(0.1*T_NM(i,TNM_mask,num_frame));
            end
            Tg(i,num_frame)=10*log10(Tg(i,num_frame));
        end
    end

    %plotting Global Masking Threshold
    figure(9);
    p1=plot(b,Tg(:,frame));
    hold on
    p2=plot(b,Tq,'r--');
    hold on
    p3=plot(b,s_P(:,frame),'g');
    hold off
    title(['Global Masking Threshold ']);
    xlabel('Frequency (bark)');
    ylabel('Magnitude');
    legend([p1,p2,p3],{'Overall Threshold','Absolute Threshold of hearing','Original PSD'});  
        
end






