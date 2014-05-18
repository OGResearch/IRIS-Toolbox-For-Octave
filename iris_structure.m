function iStruct = iris_structure(root)

if nargin < 1
    root = fileparts(which('irisstartup.m'));
end

iStruct = xxAnalyzeFolderStruct('',root,false,false);

% create csv with structure
csvStr = xxMakeStruct(iStruct,'',sprintf('%s,%s,%s,%s\n',...
    'pkgOrFolder','class','method','auxScript'));
% show it
fprintf(csvStr);
% write it to csv-file
fid = fopen(fullfile(root,'iris_structure.csv'),'w+');
fprintf(fid,csvStr);
fclose(fid);

end

function fStruct = xxAnalyzeFolderStruct(base,fldr,ispkg,iscls,fromPkg)

fullFldr = fullfile(base,fldr);
if isempty(base)
    fldr = ['iris',irisversion];
end

if nargin < 5
    fromPkg = '';
end

if ispkg
    fromPkg = [fromPkg,fldr(2:end),'.'];
end

fStruct.fldrName = fldr;
if ~isfield(fStruct,'belongsTo')
    fStruct.belongsTo = ['IRIS' filesep];
end
fStruct.isPkg = ispkg;
fStruct.isCls = iscls;
fStruct.fldrStruct = struct('files',[],'subFolders',[]);

% get names and types of contents
fldrLst = dir(fullFldr);
dirIx = [fldrLst.isdir];
pkgIx = dirIx & strncmp({fldrLst.name},'+',1);
clsIx = dirIx & strncmp({fldrLst.name},'@',1);
exclIx = dirIx & ...
    (strncmp({fldrLst.name},'.',1) | strncmp({fldrLst.name},'-',1));
fldrIx = dirIx & ~pkgIx & ~clsIx & ~exclIx;
scriptIx = ~dirIx & ~cellfun(@isempty,regexp({fldrLst.name},'\.m$','once'));

% record class methods
if iscls
    clsName = regexp(fullFldr,'\w+$','match','once');
    clsName = [fromPkg, clsName];
    metaObj = meta.class.fromName(clsName);
    metLst = {metaObj.MethodList.Name};
    for ix = 1 : numel(metLst)
        fStruct.fldrStruct.files(ix).name = metLst{ix};
        fStruct.fldrStruct.files(ix).isMeth = true;
        [fStruct.fldrStruct.files(ix).hasFile,ix2del] = ...
            ismember([metLst{ix},'.m'],{fldrLst(scriptIx).name});
        if ix2del > 0
            ixs = find(scriptIx);
            scriptIx(ixs(ix2del)) = false;
        end
    end
end

% record auxiliary m-files
for ix = find(scriptIx)
    fStruct.fldrStruct.files(end+1).name = fldrLst(ix).name(1:end-2); % drop ".m"
    fStruct.fldrStruct.files(end).isMeth = false;
    fStruct.fldrStruct.files(end).hasFile = true;
end

% initialize subFolders structure
if any(pkgIx | clsIx | fldrIx)
    fStruct.fldrStruct.subFolders = ...
        struct('fldrName',[],'belongsTo',[],'isPkg',[],'isCls',[],'fldrStruct',[]);
    sfIx = 1;
end

% analyze ordinary subfolders
for ix = find(fldrIx)
    fStruct.fldrStruct.subFolders(sfIx) = ...
        xxAnalyzeFolderStruct(fullFldr,fldrLst(ix).name,false,false,fromPkg);
    fStruct.fldrStruct.subFolders(sfIx).belongsTo = ...
        [fStruct.fldrStruct.subFolders(sfIx).belongsTo,fldr,filesep];
    sfIx = sfIx + 1;
end

% analyze subfolders with classes
for ix = find(clsIx)
    fStruct.fldrStruct.subFolders(sfIx) = ...
        xxAnalyzeFolderStruct(fullFldr,fldrLst(ix).name,false,true,fromPkg);
    fStruct.fldrStruct.subFolders(sfIx).belongsTo = ...
        [fStruct.fldrStruct.subFolders(sfIx).belongsTo,fldr,filesep];
    sfIx = sfIx + 1;
end

% analyze subfolders with packages
for ix = find(pkgIx)
    fStruct.fldrStruct.subFolders(sfIx) = ...
        xxAnalyzeFolderStruct(fullFldr,fldrLst(ix).name,true,false,fromPkg);
    fStruct.fldrStruct.subFolders(sfIx).belongsTo = ...
        [fStruct.fldrStruct.subFolders(sfIx).belongsTo,fldr,filesep];
    sfIx = sfIx + 1;
end

end % xxAnalyzeFolderStruct

function csvStr = xxMakeStruct(st,pkg,csvStr)

if isempty(pkg)
    pkg = st.fldrName;
else
    pkg = [pkg,'/',st.fldrName];
end

if st.isCls
    cls = st.fldrName;
    pkg = strrep(pkg,cls,'');
    pkg = pkg(1:end-1);
else
    cls = '';
end

for ix = 1 : numel(st.fldrStruct.files)
    if st.fldrStruct.files(ix).isMeth
        mth = st.fldrStruct.files(ix).name; axl = '';
    else
        mth = ''; axl = st.fldrStruct.files(ix).name;
    end
    csvStr = [csvStr,sprintf('%s,%s,%s,%s\n',pkg,cls,mth,axl)];
end

for ix = 1 : numel(st.fldrStruct.subFolders)
    csvStr = xxMakeStruct(st.fldrStruct.subFolders(ix),pkg,csvStr);
end

end % xxMakeStruct