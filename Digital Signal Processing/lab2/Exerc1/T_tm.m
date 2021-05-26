function[T_TM]=T_tm(bi,bj,Ptm)
  if (bi<=bj-3 || bi>= bj+8)
      T_TM=0; %there is not a mask in 12 bark bandwidth
  else 
      Db=bi-bj;
      SF=Sf(Db,Ptm);
          T_TM=Ptm-0.275*bj + SF - 6.025; % dB SPL
  end
end
