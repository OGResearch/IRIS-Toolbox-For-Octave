function [AssignPos,StdcorrPos] = mynameposition(This,Input,varargin)
% mynameposition  [Not a public function] Position of a name in the Assign or stdcorr vector.
%
% Backend IRIS function.
% No help provided.

% If `Input` is a single char it can be a regular expression, and
% `AssignPos` and `StdcorrPos` are 1-by-nName logical indices of the same
% size as the `Assign` and `stdcorr` properties.
%
% If `Input` is a 1-by-n cellstr (also 1-by-1), then `AssignPos` and
% `StdcorrPos` are 1-by-n numeric arrays with pointers to the `Assign` and
% `stdcorr` positions or NaNs.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

name = This.name;
eList = This.name(This.nametype == 3);

if iscellstr(Input)
    
    % Input is a cellstr of names. Return an array of the same size with
    % pointers to the positions, or NaNs.
    n = length(Input);
    AssignPos = nan(1,n);
    StdcorrPos = nan(1,n);
    for i = 1 : n
        [assignInx,stdcorrInx] ...
            = modelobj.mynameindex(name,eList,Input{i});
        if any(assignInx)
            AssignPos(i) = find(assignInx);
        end
        if any(stdcorrInx)
            StdcorrPos(i) = find(stdcorrInx);
        end
    end
    if any(strcmp(varargin,'error'))
        found = ~isnan(AssignPos) | ~isnan(StdcorrPos);
        if any(~found)
            utils.error('model','#Name_not_exists',Input{~found});
        end
    end
    
elseif ischar(Input)
    
    % Single input can be regular expression. Return all possible matches.
    [AssignPos,StdcorrPos] = modelobj.mynameindex(name,eList,Input);
    
else
    
    AssignPos = [];
    StdcorrPos = [];
    
end

end
