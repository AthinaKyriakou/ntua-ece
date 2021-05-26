function[T_NM]=T_nm(bi,bj,Pnm)
  if (bi<=bj-3 || bi>= bj+8)
      T_NM=0;
  else 
      Db=bi-bj;
      SF=Sf(Db,Pnm);
          T_NM=Pnm-0.175*bj + SF - 2.025; % dB SPL
end