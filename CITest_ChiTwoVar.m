function CI = CITest_ChiTwoVar( MI, R, M, a )
   CI = 0; 
   Threshold = chi2inv( 1-a,R );
   if  Threshold < 2*M*MI      %|| ThresholdLarge < 2*N*MI
       CI = 1;    
   end
end
