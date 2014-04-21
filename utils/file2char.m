function [C,Flag] = file2char(FName,Type,Lines)

try
    Lines(round(Lines) ~= Lines | Lines < 1) = [];
    if isempty(Lines)
        C = '';
        return
    else
        selectLines = ~isequal(Lines,Inf);
    end    
catch %#ok<CTCH>
    Lines = Inf;
    selectLines = false;
end

try
    if isempty(Type)
        Type = 'char';
    end
catch %#ok<CTCH>
    Type = 'char';
end

%--------------------------------------------------------------------------

if iscellstr(FName) && length(FName) == 1
    C = FName{1};
    Flag = true;
    return
end

Flag = true;
fid = fopen(FName,'r');
if fid == -1
    if ~exist(FName,'file')
        error('FILE2CHAR cannot find file ''%s''.',FName);
    else
        error('FILE2CHAR cannot open file ''%s'' for reading.',FName);
    end
end

if strcmpi(Type,'cellstrl')
    % Remove new line characters.
    C = {};
    while ~feof(fid)
        C{end+1} = fgets(fid); %#ok<AGROW>
    end
    doLastEmpty();
    if selectLines
        n = length(C);
        Lines(Lines < 1 | Lines > n) = [];
        C = C(Lines);
    end
elseif strcmpi(Type,'cellstrs') || selectLines
    % Keep new line characters.
    C = {};
    while ~feof(fid)
        C{end+1} = fgets(fid); %#ok<AGROW>
    end
    doLastEmpty();
    if selectLines
        n = length(C);
        Lines(Lines < 1 | Lines > n) = [];
        C = C(Lines);
    end
    if ~strcmpi(Type,'cellstrs')
        C = [C{:}];
    end
else
    C = char(transpose(fread(fid,Type)));
end

if fclose(fid) == -1
    warning('iris:utils', ...
        'FILE2CHAR cannot close file ''%s'' after reading.',FName);
end

% Nested functions.

%**************************************************************************
    function doLastEmpty()
        try %#ok<TRYNC>
            % If the last character is newline or return, there is an empty
            % line at the end of the file which is not read by `fgets`. We need
            % to add this empty line to `c`.
            fseek(fid,-1,'eof');
            test = fread(fid,1);
            if test == 10 || test == 13
                C{end+1} = '';
            end
        end
    end

end
