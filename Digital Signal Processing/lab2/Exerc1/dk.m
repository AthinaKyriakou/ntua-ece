function[DK]=dk(k)
    if (k>2) && (k<63)
        DK=2; 
    elseif(k>=63) && (k<127)
        DK=23; 
    elseif (k>=127) && (k<=250)
        DK=23456;    
    end
    %l=length(DK);
end

   