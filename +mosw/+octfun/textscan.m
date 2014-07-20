function data = textscan(fid,varargin)
% textscan  [Not a public function] Implementation of textscan function
% with options missing in Octave
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if is.matlab()
    
    % Matlab
    %--------
    error('iris:octfun', 'This function must not be used in Matlab!');
else
    
    % Octave
    %--------
    if isnumeric(varargin{2}) && (varargin{2} == -1)
        varargin(2) = [];
    end
    bix = 2 + isnumeric(varargin{2});
    hlx = bix + find(strcmpi(varargin(bix:2:end),'headerlines'))*2 - 2;
    numHL = 0;
    if ~isempty(hlx)
        numHL = varargin{hlx+1};
        varargin(hlx:hlx+1) = [];
    end
    numHC = 0;
    hcx = bix + find(strcmpi(varargin(bix:2:end),'headercolumns'))*2 - 2;
    if ~isempty(hcx)
        numHC = varargin{hcx+1};
        varargin(hcx:hcx+1) = [];
    end
    cox = bix + find(strcmpi(varargin(bix:2:end),'collectoutput'))*2 - 2;
    data = textscan(fid,varargin{:});
    if numHC > 0
        if varargin{cox+1}
            data = {data{1}(1+numHL:end,1+numHC:end)};
        else
            data = data(1+numHL:end,1+numHC:end);
        end
    end
end

end
