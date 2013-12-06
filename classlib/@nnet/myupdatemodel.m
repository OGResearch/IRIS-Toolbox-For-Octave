function [This,UpdateOk] = myupdatemodel(This,X,options)
% myupdatemodel  [Not a public function] Update parameters.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    
    Xcount = 1 ;
    
    if any(strcmpi(options.Estimate,'bias'))
        for iLayer = 1:This.nLayer+2
            for iNode = 1:numel(This.Params{iLayer}.Bias)
                This.Params{iLayer}.Bias{iNode} = X(Xcount) ;
                Xcount = Xcount + 1 ;
            end
        end
    end
    
    if any(strcmpi(options.Estimate,'transfer'))
        for iLayer = 1:This.nLayer+2
            for iNode = 1:numel(This.Params{iLayer}.Transfer)
                This.Params{iLayer}.Transfer{iNode} = X(Xcount) ;
                Xcount = Xcount + 1 ;
            end
        end
    end
    
    if any(strcmpi(options.Estimate,'weight'))
        for iLayer = 1:This.nLayer+2
            if iLayer>1
                for iNode = 1:numel(This.Params{iLayer}.Weight)
                    for iInput = 1:numel(This.Params{iLayer}.Weight{iNode})
                        This.Params{iLayer}.Weight{iNode}(iInput) = X(Xcount) ;
                        Xcount = Xcount + 1 ;
                    end
                end
            end
        end
    end
    
    UpdateOk = true ;
    
catch
    
    UpdateOk = false ;
    
end

end

