function[Tg]=T_G2(s_windowed,L,Tq,b,fs) 

     %----------ex 1.1 estimation of spectrum (SPL)------------------
    ssym_fft=fft(s_windowed); 
    s_fft=ssym_fft(1:L/2,:);
    PN=90.302;
    s_P=PN+10.*log10((abs(s_fft)).^2);
    %s_P=s_P(1:L/2,:); 

    f=[1:L/2]*(fs/L);

    %b=13.*atan(0.00076.*f)+3.5.*atan((f/7500).^2); %bark scale
    %Tq=3.64.*(f/1000).^(-0.8)-6.5.*exp(-0.6.*((f/1000)-3.3).^2)+10.^(-3).*(f/1000).^4;

    %----------ex 1.2 masks------------------
    s_ST=St(s_P); %binary matrix of masks
    [rown,coln]=size(s_ST);

    for i=1:coln
            for k=1:256
                if (s_ST(k,i)==1)
                    P_TM(k,i)=10*log10((10.^(0.1.*s_P(k-1,i)))+10.^(0.1.*s_P(k,i))+10.^(0.1.*s_P(k+1,i)));
                else
                    P_TM(k,i)=0;
                end
                ks(k,i)=P_TM(k,i);
            end
    end

    for i=1:L/2
            ks_frame(i)=ks(i,3);
    end

    ks_frame=ks_frame';

    for i=1:coln
        P_NM(:,i)=findNoiseMaskers(s_P(:,i),P_TM(:,i),b);
    end

    for i=1:coln
            for k=1:256
                ks(k,i)=P_NM(k,i);
            end
    end

    for i=1:L/2
            ks_frame(i)=ks(i,20);
    end

    P_NM;

    ks_frame=ks_frame';

    
    %----------ex 1.3 Reduction of masks------------------
    for i=1:coln
        [P_TMnew(:,i),P_NMnew(:,i)]=checkMaskers(P_TM(:,i)',P_NM(:,i)',Tq,b);
    end

    %----------ex 1.4 individual Masking Thresholds------------------

    %Threshold for each sample ie[1,256] Tone masks

    %find the max number of tone masks in a frame in the whole signal

    max_num_TM=0;

    for num_frame=1:coln %check each frame to find the max_num of noise masks
        max_new=length(find(P_TMnew(:,num_frame)>0));
        if(max_new>max_num_TM)
            max_num_TM=max_new;
        end
    end

    T_TM=zeros(L/2,max_num_TM,coln); %make a 3d array of zeros size 256 x max_num_NM x 1271

    for num_frame=1:coln %for each frame there is a threshold

        TM_places_array=find(P_TMnew(:,num_frame)>0);  %places of masks in the frame

        for num_mask=1:length(TM_places_array)   %for each noise mask in the frame

            j=TM_places_array(num_mask);

            for i=1:L/2     %for each i frequency

                T_TM(i,num_mask,num_frame)=T_tm(b(i),b(j),P_TMnew(j,num_frame));

            end
        end
    end


    %Threshold for each sample ie[1,256] Noise masks

    %find the max number of noise masks in a frame in the whole signal

    max_num_NM=0;

    for num_frame=1:coln %check each frame to find the max_num of noise masks
        max_new=length(find(P_NMnew(:,num_frame)>0));
        if(max_new>max_num_NM)
            max_num_NM=max_new;
        end
    end

    T_NM=zeros(L/2,max_num_NM,coln); %make a 3d array of zeros size 256 x max_num_NM x 1271

    for num_frame=1:coln %for each frame there is a threshold

        NM_places_array=find(P_NMnew(:,num_frame)>0);  %places of masks in the frame

        for num_mask=1:length(NM_places_array)   %for each noise mask in the frame

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
            for TM_mask=1:max_num_TM
                Tg(i,num_frame)=Tg(i,num_frame)+10^(0.1*T_TM(i,TM_mask,num_frame));
            end
            for TN_mask=1:max_num_NM
                Tg(i,num_frame)=Tg(i,num_frame)+10^(0.1*T_NM(i,TN_mask,num_frame));
            end
            Tg(i,num_frame)=10*log10(Tg(i,num_frame));
        end
    end   
end






