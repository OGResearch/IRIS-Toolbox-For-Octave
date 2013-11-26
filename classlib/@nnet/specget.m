function [X,Flag,Query] = specget(This,Query)
% specget  [Not a public function] Implement GET method for nnet objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    
    Xcount = 0 ;
    
    switch Query
        
        case 'weight'
            X = NaN(This.nWeight,1) ;
            for iLayer = 1:This.nLayer+2
                if iLayer>1
                    for iNode = 1:numel(This.Params{iLayer}.Weight)
                        for iInput = 1:numel(This.Params{iLayer}.Weight{iNode})
                            Xcount = Xcount + 1 ;
                            X(Xcount) = This.Params{iLayer}.Weight{iNode}(iInput) ;
                        end
                    end
                end
            end
            Flag = true ;
            
        case 'bias'
            X = NaN(This.nBias,1) ;
            for iLayer = 1:This.nLayer+2
                for iNode = 1:numel(This.Params{iLayer}.Bias)
                    Xcount = Xcount + 1 ;
                    X(Xcount) = This.Params{iLayer}.Bias{iNode} ;
                end
            end
            Flag = true ;
            
        case 'transfer'
            X = NaN(This.nTransfer,1) ;
            for iLayer = 1:This.nLayer+2
                for iNode = 1:numel(This.Params{iLayer}.Transfer)
                    Xcount = Xcount + 1 ;
                    X(Xcount) = This.Params{iLayer}.Transfer{iNode} ;
                end
            end
            Flag = true ;
            
        case 'param'
            X = [specget(This,'bias'); specget(This,'transfer'); specget(This,'weight')] ;
            Flag = true ;
            
        otherwise
            Flag = false ;
            
    end
catch
    Flag = false ;
end

end
