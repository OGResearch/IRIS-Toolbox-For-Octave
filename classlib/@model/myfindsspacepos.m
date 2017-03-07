function [SspacePos,NamePos,SSpacePosLag,SspaceInx] ...
    = myfindsspacepos(This,List,varargin)
% myfindsspacepos  [Not a public function] Find position of variables in combined state-space vector.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

throwErr = any(strcmp(varargin,'-error'));

if ischar(List)
    List = regexp(List,'[\w\{\}\(\)\+\-]+','match');
end

% Remove blank spaces.
List = regexprep(List,'\s+','');

%--------------------------------------------------------------------------

nz = length(List);

% Vector of measurement and transition variables.
yxVec = myvector(This,'yx');

SspacePos = nan(1,nz);
NamePos = nan(1,nz);
for i = 1 : nz
    % Position of the requested variable in the state-space vector.
    index = strcmp(List{i},yxVec);
    if ~any(index)
        continue
    end
    SspacePos(i) = find(index);
    
    % Position of the requested variable in the list of model names.
    index = strcmp(This.name,List{i}) & This.nametype <= 2;
    if ~any(index)
        continue
    end
    NamePos(i) = find(index);
end

if nargout == 1
    nanPos = isnan(SspacePos);
    if throwErr && any(nanPos)
        utils.error('model', ...
            'Cannot find this variable in the state-space vectors: ''%s''.', ...
            List{nanPos});
    end
    return
end

if nargout == 2
    nanPos = isnan(NamePos);
    if throwErr && any(nanPos)
        utils.error('model', ...
            'Cannot find this variable in the state-space vectors: ''%s''.', ...
            List{nanPos});
    end
    return
end

SSpacePosLag = xxSspacePosLag(This,List,SspacePos);

nanPos = isnan(SSpacePosLag);
if throwErr && any(nanPos)
    utils.error('model', ...
        'Cannot find this variable in the state-space vectors: ''%s''.', ...
        List{nanPos});
end

x = SspacePos;
x(isnan(x)) = [];
SspaceInx = false(1,length(yxVec));
SspaceInx(x) = true;

end


% Subfunctions...


%**************************************************************************


function X = xxSspacePosLag(This,UsrName,SspacePos)
% xxsspaceposlag  Return position in the extended solutionid vector for
% transition variables with a lag larger than the maximum lag present in
% `solutionid`.
X = SspacePos;
solutionId = [This.solutionid{1:2}];
name = This.name;
name(This.IxLog) = strcat('log(',name(This.IxLog),')');
for i = find(isnan(X))
    usrName = UsrName{i};
    lag  = regexp(usrName,'\{.*?\}','match','once');
    usrName = regexprep(usrName,'\{.*?\}','','once');
    if isempty(lag)
        continue
    end
    namePos = strcmp(name,usrName) & This.nametype == 2;
    if ~any(namePos)
        continue
    end
    namePos = find(namePos,1);
    % `lag` is a negative number.
    lag = sscanf(lag,'{%g}');
    if ~isnumericscalar(lag) || ~isfinite(lag)
        continue
    end
    % `maxlag` is a negative number.
    maxLag = min(imag(solutionId(real(solutionId) == namePos)));
    inx = solutionId == namePos + 1i*maxLag;
    solutionPos = find(inx,1);
    X(i) = solutionPos + 1i*round(lag - maxLag);
end
end % xxSspacePosLag()
