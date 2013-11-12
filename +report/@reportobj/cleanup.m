function cleanup(This,LatexFile,Temps)
% cleanup  [Not a public function] Clean up temporary files.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ~This.options.cleanup
    return
end

% Delete all helper files produced when TeX files was compiled.
[latexPath,latexTitle] = fileparts(LatexFile);
latexFiles = fullfile(latexPath,[latexTitle,'.*']);
if ~isempty(dir(latexFiles))
    delete(latexFiles);
end

% Delete all helper files produced when latex codes for children were
% built.
for i = 1 : length(Temps)
    if exist(Temps{i},'file')
        delete(Temps{i});
    end
end

% Delete temporary dir if empty.
status = rmdir(This.tempDirName); %#ok<NASGU>

end