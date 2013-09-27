function hdatainit(This,Obj,Flags,NPer,varargin)
% hdatainit  [Not a public function] Initialise hdataobj for input object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

%--------------------------------------------------------------------------

if isstruct(Flags)
    list = fieldnames(Flags);
    for i = 1 : length(list)
        This.(list{i}) = Flags.(list{i});
    end
end

This.data = struct();

[solId,name] = hdatareq(Obj);

for i = 1 : length(solId)
    imagId = imag(solId{i});
    realId = real(solId{i});
    maxLag = -min(imagId);
    for j = find(imagId == 0)
        pos = realId(j);
        jName = name{pos};
        This.data.(jName) = nan(maxLag+NPer,varargin{:},This.Precision);
    end
end

end