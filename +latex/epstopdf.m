function epstopdf(List,CmdArgs,varargin)
% epstopdf  [Not a public function] Run EPSTOPDF to convert EPS grapics to PDF.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    CmdArgs; %#ok<VUNUS>
catch %#ok<CTCH>
   if ispc()
      % Add a border to the image. The --enlarge option doesn't exist on
      % Unix/Linux platforms.
      CmdArgs = '--enlarge=10';
      % cmdArguments = '';
   else
      CmdArgs = '';
   end
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
      if opt.display
         fprintf('Converting \% to PDF.\n',fullfile(fPath,tmp(j).name));
      end
      command = ['"',epstopdf,'" ',tmp(j).name,' ',CmdArgs];
      system(command);
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