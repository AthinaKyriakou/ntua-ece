%function quantizer2
%use of NON ADAPTABLE quantizer

function[x_rec,B_total]=non_adaptable_quantizer(x_framed,L,M,fs,Tg,length_x) 
    %----------ex 2.0 Defining the filters------------

    %initialization of the filters (represented as matrices)
    %total number of filters is M=32 and length of each filter is L=2*M=64 

    h_filter=zeros(2*M,M);   %analysis
    g_filter=zeros(2*M,M);   %synthesis

    for k=1:M %num_filter
        for n=1:2*M   %num_sample
            h_filter(n,k)=sin((n+1/2)*(pi/(2*M)))*sqrt(2/M)*cos((2*n+M+1)*(2*k+1)*pi/(4*M));
        end
    end

    for k=1:M %num_filter
        for n=0:2*M-1   %num_sample
            g_filter(n+1,k)=h_filter(2*M-n,k);
        end
    end


    %------ex 2.1 Convolution and undersampling of the x with the filters------

    [rown,frames]=size(x_framed);

     %convolution of each signal frame with the filters
     %for each frame, 32 filtering -> 3D matrix

    for num_frame=1:frames %num_frame
        for k=1:M   %num_filter
             v_conv(:,k,num_frame)=conv(h_filter(:,k)',x_framed(:,num_frame));
        end
    end

    %downsampling
    for num_frame=1:frames
        for k=1:M   %num_filter
            y_downsamp(:,k,num_frame)=downsample(v_conv(:,k,num_frame),M);
        end
    end

    %----------ex 2.2 Quantization of the signal y_downsamp--------------------

    R=2^16;

    %partitioning the global masking threshold of each frame into 32 frames of
    %length 8
    for num_frame=1:frames
        Tg_framed(:,:,num_frame)=buffer(Tg(:,num_frame),8,0,'nodelay');
    end

    Bk=8;   %constant number of coding bits for each sample, of each filter and frame
    
    B_total=Bk*M*frames;

    Dk=2/(2^Bk);   %constant quantization step Dk=1-(-1)/(2^Bk)
    
    %quantization of y_downsamp with
    for num_frame=1:frames
        for k=1:M
            y_quantized(:,k,num_frame)=Dk*(ceil(y_downsamp(:,k,num_frame)/Dk)+1/2);
        end
    end


    %-------------ex 2.3 Synthesis of the signal y_downsamp--------------------

     %upsampling

    [rown_y,coln_y,frames]=size(y_quantized);

    w=zeros(rown_y*M,M,frames);
    for num_frame=1:frames
        for k=1:M   %num_filter
            w(:,k,num_frame)=upsample(y_quantized(:,k,num_frame),M);
        end
    end

    %convolution with synthesis filter
    for num_frame=1:frames
        for k=1:M
            w_conv(:,k,num_frame)=conv(g_filter(:,k)',w(:,k,num_frame));
        end
    end

    %reconstructed framed signal: x_rec_windowed (639x1271)

    [rown_w,coln_w,frames]=size(w_conv);

    x_rec_framed=zeros(rown_w,frames); 

    for num_frame=1:frames
        for n=1:rown_w
            for k=1:M
                x_rec_framed(n,num_frame)=x_rec_framed(n,num_frame)+w_conv(n,k,num_frame);
            end
        end
    end


    %final reconstructed signal: x_rec

    x_rec_shifted(1:rown_w)=x_rec_framed(1:rown_w,1);   %first 639 samples of 1st frame inserted

    index=rown_w; %639 samples are added

    overlap=rown_w-L;  %overlap=127

    for num_frame=2:frames
        for n=1:overlap  %the first 127 samples of the frame are added to the previous one
            x_rec_shifted(index+n-overlap)=x_rec_framed(n,num_frame); 
        end
        for n=overlap+1:rown_w
            index=index+1;
            x_rec_shifted(index)=x_rec_framed(n,num_frame);
        end
    end

    x_rec_shifted=x_rec_shifted';


    %reducing the delay, there is a shift of 2*M=64

    x_rec=zeros(length_x,1);
    for n=1:length_x
        x_rec(n,1)=x_rec_shifted(2*M+n-1,1);
    end
end