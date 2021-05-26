function[ST]=St(P_matrix)
    [rown,coln]=size(P_matrix);
    for i=1:coln %for each frame of the signal
        for k=1:256
            if (k>=3 && k<=250)
                DK=dk(k);
                if(DK==2)
                    ST(k,i)=((P_matrix(k,i)>P_matrix(k+1,i)) && (P_matrix(k,i)>P_matrix(k-1,i)) && (P_matrix(k,i)>(P_matrix(k+2,i)+7)) && (P_matrix(k,i)>(P_matrix(k-2,i)+7)));
                elseif(DK==23)
                    ST(k,i)=((P_matrix(k,i)>P_matrix(k+1,i)) && (P_matrix(k,i)>P_matrix(k-1,i)) && (P_matrix(k,i)>(P_matrix(k+2,i)+7)) && (P_matrix(k,i)>(P_matrix(k-2,i)+7)) && (P_matrix(k,i)>(P_matrix(k+3,i)+7)) && (P_matrix(k,i)>(P_matrix(k-3,i)+7)));
                elseif(DK==23456)
                    ST(k,i)=((P_matrix(k,i)>P_matrix(k+1,i)) && (P_matrix(k,i)>P_matrix(k-1,i)) && (P_matrix(k,i)>(P_matrix(k+2,i)+7)) && (P_matrix(k,i)>(P_matrix(k-2,i)+7)) && (P_matrix(k,i)>(P_matrix(k+3,i)+7)) && (P_matrix(k,i)>(P_matrix(k-3,i)+7)) && (P_matrix(k,i)>(P_matrix(k+4,i)+7)) && (P_matrix(k,i)>(P_matrix(k-4,i)+7))&& (P_matrix(k,i)>(P_matrix(k+5,i)+7)) && (P_matrix(k,i)>(P_matrix(k-5,i)+7))&& (P_matrix(k,i)>(P_matrix(k+6,i)+7)) && (P_matrix(k,i)>(P_matrix(k-6,i)+7)));
                end
            else
                ST(k,i)=0;
            end
        end
    end
end