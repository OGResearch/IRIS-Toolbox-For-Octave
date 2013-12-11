function Flag = aeq(A,B)
% AEQ  [Not a public function]
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

Flag = true ;

% Check to see that net structure is the same
if ~strcmpi(A.Type,B.Type)
    Flag = false ;
end

% Check consistency
if size(A.Params,1)~=size(B.Params,1)
    Flag = false ;
end
if size(A.HiddenLayout)~=size(B.HiddenLayout)
    Flag = false ;
else
    if A.HiddenLayout~=B.HiddenLayout
        Flag = false ;
    end
end
if any(~strcmp(A.Inputs,B.Inputs)) || any(~strcmp(A.Outputs,B.Outputs)) ...
        || any(~strcmp(A.InputTransfer,B.InputTransfer)) ...
        || any(~strcmp(A.OutputTransfer,B.OutputTransfer)) ...
        || any(~strcmp(A.HiddenTransfer,B.HiddenTransfer))
    Flag = false ;
end

end