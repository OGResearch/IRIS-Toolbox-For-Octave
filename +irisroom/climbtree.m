function Tree = climbtree()
% climbtree  Create tree structure based on Contents files.

%--------------------------------------------------------------------------

[~,inDescript,inFile,inHelpText] = xxHeadline('Contents/index');

Tree = struct();
Tree.SYNTAX = 'index';
Tree.FILENAME = inFile;
Tree.DESCRIPT = inDescript;
Tree.HELPTEXT = inHelpText;

[chFileName,chSyntax,chDescript,chHelpText] = xxPopulateFile(inFile);
nChapter = length(chFileName);

for i = 1 : nChapter

    thisChField = chSyntax{i};
    x = struct();
    x.FILENAME = chFileName{i};
    x.DESCRIPT = chDescript{i};
    x.HELPTEXT = chHelpText{i};
    x.SYNTAX = chSyntax{i};
    Tree.(thisChField) = x;
    
    [foFileName,foSyntax,foDescript,foHelpText] ...
        = xxPopulateFile(chFileName{i});
    nFolder = length(foFileName);
    for j = 1 : nFolder
        thisFoField = foSyntax{j};
        x = struct();
        x.SYNTAX = foSyntax{j};
        x.FILENAME = foFileName{j};
        x.DESCRIPT = foDescript{j};
        x.HELPTEXT = foHelpText{j};
        Tree.(thisChField).(thisFoField) = x;
        [fiFileName,fiSyntax,fiDescript,fiHelpText] = ...
            xxPopulateFile(foFileName{j});
        nFile = length(fiFileName);
        for k = 1 : nFile
            if ~isempty(fiFileName{k}) && ~isequaln(fiFileName{k},NaN)
                [~,thisFiField] = fileparts(fiFileName{k});
            else
                thisFiField = fiSyntax{k};
            end
            x = struct();
            x.SYNTAX = fiSyntax{k};
            x.FILENAME = fiFileName{k};
            x.DESCRIPT = fiDescript{k};
            x.HELPTEXT = fiHelpText{k};
            Tree.(thisChField).(thisFoField).(thisFiField) = x;
        end
    end
end

end


% Subfunctions...


%**************************************************************************


function [List,Syntax,Descript,HelpText,C] = xxPopulateFile(File,IsSave)
    try
        IsSave; %#ok<VUNUS>
    catch %#ok<CTCH>
        IsSave = true;
    end
    fprintf('Populating TOC in %s...',File);
    C = file2char(File);
    C = strfun.converteols(C);
    [C,List,Syntax,Descript,HelpText] = xxExpandLinks(C,File);
    if IsSave
        fprintf(' Saving...');
        char2file(C,File);
    end
    fprintf('\n');
end % xxPopulateFile()


%**************************************************************************


function [C,List,Syntax,Descript,HelpText] = xxExpandLinks(C,File) %#ok<*INUSD>
    List = {};
    Syntax = {};
    Descript = {};
    HelpText = {};
    replaceFunc = @doReplace; %#ok<NASGU>
    C = regexprep(C,'^(\s*% \* )\[(.*?)\]\(([^\)]+)\) -([^\n]*)', ...
        '${replaceFunc($1,$2,$3)}','lineanchors');
    
    function C = doReplace(C1,C2,C3)
        % fprintf('%s %s %s\n',C1,C2,C3);
        [syntax,descript,file,helpText] = xxHeadline(C3);
        C = [C1,'[',C2,'](',C3,') - ',descript,'.'];
        List{end+1} = file;
        Syntax{end+1} = syntax;
        Descript{end+1} = descript;
        HelpText{end+1} = helpText;
    end

end % xxExpandLinks()


%**************************************************************************


function [Syntax,Descript,File,H] = xxHeadline(Ref)

H = help(Ref);
File = xxRef2File(Ref);

if isempty(H)
    H = help(File);
end

% Remove 'Help for XXXX/XXX is inherited from superclass...')
H = regexprep(H,'^[ ]*Help for \w+/\w+ is inherited [^\n]*\n', ...
    '','lineanchors');

% Read H1 line.
tok = regexp(H,'^  ([^ ]+)  ([^\n]+)','tokens','once');
if isempty(tok) || isempty(tok{1}) || isempty(tok{2})
    error('iris:help','Invalid H1 line in ''%s''.',Ref);
end

Syntax = strtrim(tok{1});
Descript = strtrim(tok{2});
if ~isempty(Descript) && Descript(end) == '.'
    Descript(end) = '';
end
end % xxHeadLine()


%**************************************************************************


function File = xxRef2File(Ref)

trimfunc = @(x) strtrim(regexprep(x,'%.*',''));

% Existing folder/file reference.
File = which(Ref);
if ~isempty(File)
    File = trimfunc(File);
    return
end

[folder,title] = fileparts(Ref);
if strcmpi(folder,'contents')
    folder = 'Contents';
end

% Existing folder.file reference.
File = which([folder,'.',title]);
if ~isempty(File)
    File = trimfunc(File);
    return
end

% Chapter master file.
File = which(['+',folder,'/',title]);
if ~isempty(File)
    File = trimfunc(File);
    return
end

if ~isempty(strfind(Ref,'config')) && isempty(strfind(Ref,'Contents'))
    File = which(title);
    return
end

% Package contents.
File = which(['+',folder,'/Contents']);
if ~isempty(File)
    File = trimfunc(File);
    return
end

% Class constructor.
if ~strcmpi(folder,'contents') && strcmpi(title,'contents')
    File = which(folder);
    if ~isempty(File)
        File = trimfunc(File);
        return
    end
end

File = NaN;

end % xxRef2File()