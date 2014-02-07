function char2file(Char,File,Type)
% char2file  [Not a public function] Write character string to text file.
%
% Backend IRIS function.
% No help provided.

% -The IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if nargin < 3
    Type = 'char';
end

%--------------------------------------------------------------------------

fid = fopen(File,'w+');
if fid == -1
    error('IRIS:filewrite:cannotOpenFile', ...
        'Cannot open file ''%s'' for writing.',File);
end

if iscellstr(Char)
    Char = sprintf('%s\n',Char{:});
    if ~isempty(Char)
        Char(end) = '';
    end
end

count = fwrite(fid,Char,Type);
if count ~= length(Char)
    fclose(fid);
    error('IRIS:filewrite:cannotWrite', ...
        'Cannot write character string to file ''%s''.',File);
end

fclose(fid);

end
