function data = textscan(fid,varargin)
% textscan  [Not a public function] Implementation of textscan function
% with options missing in Octave
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if false % ##### MOSW
    
    % Matlab
    %--------
    data = textscan(fid,varargin{:});
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
    % remove header lines if `fid` is text
    if numHL > 0 && ischar(fid)
        nlIx = strfind(fid,sprintf('\n'));
        fid = fid(nlIx(numHL)+1:end);
    end
    % remove header columns if `fid` is text
    if numHC > 0 && ischar(fid)
        fid = [fid,sprintf('\n')];
        fid = regexprep(fid,[repmat('[^,]*,',1,numHC),'(.*?)\n'],'$1\n');
        fid = fid(1:end-1);
    end
    % make sure end of line is not empty
    emptyVal = 0;
    evx = bix + find(strcmpi(varargin(bix:2:end),'emptyvalue'))*2 - 2;
    if ~isempty(evx)
        emptyVal = varargin{evx+1};
    end
    emptyVal = num2str(emptyVal);
    fid = regexprep(regexprep(fid,',\n',[',',emptyVal,'\n']),',$',[',',emptyVal]);
    % run Octave's textscan()
    data = textscan(fid,varargin{:});
end

end
