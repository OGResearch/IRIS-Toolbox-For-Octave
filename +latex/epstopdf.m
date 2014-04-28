function epstopdf(List,CmdArgs,varargin)
% epstopdf  [Not a public function] Run EPSTOPDF to convert EPS graphics to PDF.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    CmdArgs; %#ok<VUNUS>
catch %#ok<CTCH>
    CmdArgs = '';
end

% Parse inputarguments.
pp = inputParser();
pp.addRequired('List',@(x) ischar(x) || iscellstr(x));
pp.addRequired('CmdArgs',@(x) ischar(x) || isempty(x));
pp.parse(List,CmdArgs);

% Parse options.
opt = passvalopt('latex.epstopdf',varargin{:});

%--------------------------------------------------------------------------

if ischar(List)
    List = regexp(List,'[^,;]+','match');
    List = strtrim(List);
end

thisDir = cd();
epstopdf = irisget('epstopdfpath');
if isempty(epstopdf)
    error('iris:latex',...
        'EPSTOPDF path unknown. Cannot convert EPS to PDF files.');
end

% Try to make sure GhostScript is on the system path on Unix/Linus/Mac.
% Otherwise, it's up to the user to export the path at the beginning of the
% Matlab executable.
changePath = false;
if isunix()
    try %#ok<TRYNC>
        path0 = getenv('PATH');
        [~,x0] = system('which gs');
        % This is the most likely location.
        [~,x1] = system('which /usr/local/bin/gs');
        if isempty(x0) && ~isempty(x1)
            setenv('PATH',[path0,':','/usr/local/bin']);
            changePath = true;
        end
    end
end

for i = 1 : length(List)
    [fPath,fTitle,fExt] = fileparts(List{i});
    fPath = strtrim(fPath);
    if ~isempty(fPath)
        cd(fPath);
    end
    tmp = dir([fTitle,fExt]);
    tmp([tmp.isdir]) = [];
    for j = 1 : length(tmp)
        jFile = tmp(j).name;
        isChanged = false;
        if opt.display
            fprintf('Converting \% to PDF.\n',fullfile(fPath,jFile));
        end
        % Enlarge bounding box.
        try %#ok<TRYNC>
            if opt.enlargebox > 0
                oldFileCont = xxEnlargeBox(jFile,opt.enlargebox);
                isChanged = true;
            end
        end
        command = ['"',epstopdf,'" ',jFile,' ',CmdArgs];
        system(command);
        if isChanged
            char2file(oldFileCont,jFile);
        end
    end
    cd(thisDir);
end

% Clean up.
if changePath
    try %#ok<TRYNC>
        setenv('PATH',path0);
    end
end

end


% Subfunctions...


%**************************************************************************
function OldFileCont = xxEnlargeBox(File,Enlarge)

c = file2char(File);
OldFileCont = c;
replaceFunc = @doEnlargeBox; %#ok<NASGU>
c = regexprep(c,'BoundingBox:\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)', ...
    '${replaceFunc($0,$1,$2,$3,$4)}');
char2file(c,File);

    function S = doEnlargeBox(S0,S1,S2,S3,S4)
        S1 = sscanf(S1,'%g');
        S2 = sscanf(S2,'%g');
        S3 = sscanf(S3,'%g');
        S4 = sscanf(S4,'%g');
        if ~is.numericscalar(S1) ...
                || ~is.numericscalar(S2) ...
                || ~is.numericscalar(S3) ...
                || ~is.numericscalar(S4) ...
                || ~isfinite(S1) ...
                || ~isfinite(S2) ...
                || ~isfinite(S3) ...
                || ~isfinite(S4)
            S = S0;
            return
        end
        S1 = S1 - Enlarge(min(1,end));
        S2 = S2 - Enlarge(min(2,end));
        S3 = S3 + Enlarge(min(3,end));
        S4 = S4 + Enlarge(min(4,end));
        S = sprintf('BoundingBox: %g %g %g %g',S1,S2,S3,S4);
    end

end % xxEnlargeBox()
