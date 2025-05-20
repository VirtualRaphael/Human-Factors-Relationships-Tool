function LGObj = ConstructLGObj( OriginalSample )

    LGObj.VarNumber = size( OriginalSample,2 );
    LGObj.CaseLength = size( OriginalSample,1 );
    
    LGObj.VarSample   = OriginalSample;
    [ LGObj.VarRange,LGObj.VarRangeLength ] = DimensionRangeValue( OriginalSample,1 : LGObj.VarNumber );
end


function [ Dim,DimLength ] = DimensionRangeValue(OriginalData,Vec) 
CountNumber = 0; 
D = size(Vec,2);
if size(Vec,1)>1, Vec = Vec'; end
DimLength = zeros( 1,D );
t = 0;
 for q = 1 : D
     TempVector = unique( OriginalData(:,Vec(q))' );    
     if TempVector(1) == -1 ,TempVector(1)=[]; end
     RangeNumber = size(TempVector,2);
     DimLength( q ) = RangeNumber;
     t = t + 1;
     if CountNumber == 0
         CountNumber = RangeNumber;
         Dim = zeros( D ,CountNumber );
         Dim(t,:) = TempVector ;
       elseif CountNumber >= RangeNumber
         Dim(t,:) = [TempVector, zeros(1,CountNumber - RangeNumber)];
       elseif CountNumber < RangeNumber
         Dim = [Dim, zeros( D,RangeNumber - CountNumber )];  %#ok<AGROW>
         CountNumber = RangeNumber;
         Dim(t,:) = TempVector;
     end    
 end
 
end
