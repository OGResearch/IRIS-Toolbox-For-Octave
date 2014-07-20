function publishfolder(Folder,X,OnlyFiles)

thisDir = fullfile(irisroot(),'-help',Folder);
fprintf('%s in %s\n',Folder,thisDir);

if isempty(OnlyFiles)
    delete(fullfile(thisDir,'*.tex'));
    delete(fullfile(thisDir,'*.html'));
end

[file,nFile] = irisroom.branchnames(X,'sort');
for i = 1 : nFile
    ref = [Folder,'/',file{i}];
    if isempty(OnlyFiles) || any(strcmpi(ref,OnlyFiles))        
        irisroom.pandoc('file',X.(file{i}),ref);
        disp(['    ',ref]);
    end
end

ref = [Folder,'/Contents'];
irisroom.pandoc('folder',X,ref);

end