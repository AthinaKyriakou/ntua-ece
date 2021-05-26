function[SF]=Sf(Db,Pmasker)
  if (Db>=-3 && Db<-1)
      SF=17*Db-0.4*Pmasker+11;
  elseif (Db>=-1 && Db<0)
      SF=(0.4*Pmasker + 6) * Db;
  elseif (Db>=0 && Db<1)
      SF=-17*Db;
  elseif (Db>=1 && Db<8)
      SF=(0.15*Pmasker-17)*Db-0.15*Pmasker;
  end
end