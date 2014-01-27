function varargout = myfind(This,Caller,varargin)
% myfind  [Not a public function] Find equations or names by their labels or descriptions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if strcmpi(Caller,'findeqtn')
    list = This.eqtn;
    label = This.eqtnlabel;
else
    list = This.name;
    label = This.namelabel;
end

if isequal(varargin{1},'-rexp')
    isRexp = true;
    varargin(1) = [];
else
    isRexp = false;
end

varargout = cell(size(varargin));
for i = 1 : length(varargin)
    if isRexp
        inx = regexp(label,sprintf('^%s$',varargin{i}));
        inx = ~cellfun(@isempty,inx);
        varargout{i} = list(inx);
    elseif length(varargin{i}) > 3 ...
            && strcmp(varargin{i}(end-2:end),'...')
        inx = strncmp(list,varargin{i}(1:end-3),length(varargin{i})-3);
        if any(inx)
            varargout{i} = list(find(inx,1));
        end
    else
        inx = strcmp(label,varargin{i});
        if any(inx)
            varargout{i} = list{find(inx,1)};
        end
    end
end

end