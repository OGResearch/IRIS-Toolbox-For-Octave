function cleanup(This)
% cleanup  [Not a public function] Clean up temporary files and folders.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Delete all helper files produced when latex codes for children were
% built.
nTempFile = length(This.tempFile);
isDeleted = false(1,nTempFile);
for i = 1 : nTempFile
    file = This.tempFile{i};
    if ~isempty(dir(file))
        delete(file);
        isDeleted(i) = true;
    end
end
This.tempFile(isDeleted) = [];

% Delete temporary dir if empty.
if ~isempty(This.tempDirName)
    status = rmdir(This.tempDirName);
    if status == 1
        This.tempDirName = '';
    end
end

end