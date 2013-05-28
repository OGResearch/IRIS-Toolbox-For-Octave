function vec = myvector(this,varargin)
% myvector  [Not a public function] Vectors of variables in the state space.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**********************************************************************

if ischar(varargin{1})
    type = lower(varargin{1});
    switch type
        case 'y'
            % Vector of measurement variables.
            realkey = this.solutionid{1};
            vec = this.name(realkey);
            vec = sub_wrapinlog(vec,this.log(realkey));
        case 'x'
            % Vector of transition variables.
            realkey = real(this.solutionid{2});
            imagkey = imag(this.solutionid{2});
            vec = this.name(realkey);
            for i = find(imagkey ~= 0)
                vec{i} = sprintf('%s{%g}',vec{i},imagkey(i));
            end
            vec = sub_wrapinlog(vec,this.log(realkey));
        case 'e'
            % Vector of shocks.
            realkey = this.solutionid{3};
            vec = this.name(realkey);
    end
else
    realkey = real(varargin{1});
    imagkey = imag(varargin{1});
    vec = this.name(realkey);
    for i = find(imagkey ~= 0)
        vec{i} = sprintf('%s{%g}',vec{i},imagkey(i));
    end
    vec = sub_wrapinlog(vec,this.log(realkey));
end

end

% Subfunctions.

%**************************************************************************
function vec = sub_wrapinlog(vec,islog)
for i = find(islog)
    vec{i} = sprintf('log(%s)',vec{i});
end
end
% sub_wrapinlog().
