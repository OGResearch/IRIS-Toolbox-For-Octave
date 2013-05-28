function [Pdf,Count] = compilepdf(InpFile,varargin)
% compilepdf  [Not a public function] Publish latex file to PDF.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

opt = passvalopt('latex.compilepdf',varargin{:});

%--------------------------------------------------------------------------

config = irisget();
if isempty(config.pdflatexpath)
    error('iris:latex',...
        'PDFLATEX path unknown. Cannot compile PDF files.');
end

[inpPath,inpTitle] = fileparts(InpFile);

% Some PDFLATEX executables don't support the option `-include-directory`,
% and only accept a filename (no path). Using the option `'cd=' true` is a
% workaround.
if ~opt.cd
    inclDir = sprintf('-include-directory="%s" ',inpPath);
    outpDir = sprintf('-output-directory="%s" ',inpPath);
    haltOnError = '-halt-on-error ';
else
    inclDir = ' ';
    outpDir = ' ';
    haltOnError = ' ';
end

systemOpt = {};
if opt.echo
    opt.display = false;
    systemOpt = {'-echo'};
end

command = [ ...
    '"',config.pdflatexpath,'" ', ...
    haltOnError, ...
    inclDir, ...
    outpDir, ...
    inpTitle, ...
    ];

if opt.cd
    thisDir = pwd();
    cd(inpPath);
end

Count = 0;
while true
    Count = Count + 1;
    [status,result] = system(command,systemOpt{:});
    if Count < opt.minrerun
        continue
    elseif Count > opt.maxrerun
        break
    end
    isRerun = xxRerunTest(result,inpTitle);
    if status == 0 && ~isRerun
        break
    end
end

if opt.cd
    cd(thisDir);
end

if opt.display || status ~= 0
    disp(result);
end

Pdf = fullfile(inpPath,[inpTitle,'.pdf']);
fprintf('\n');

end

% Subfunctions.

%**************************************************************************
function IsRerun = xxRerunTest(Result,FTitle)
% xxRerunTest  Search in the screen message and the log file for hints
% indicating a need to rerun the compiler.

findFunc = @(A,B) ~isempty(strfind(A,B));

% Search in output screen message for hints.
IsRerun = findFunc(Result,'Rerun') ...
        || findFunc(Result,'undefined references') ...
        || ~isempty(regexp(Result,'No file \w+\.toc','once'));

% Search the log file for hints.
try %#ok<TRYNC>
    c = file2char([FTitle,'.log']);
    IsRerun = IsRerun || findFunc(c,'Rerun');
end

end % xxRerunTest().