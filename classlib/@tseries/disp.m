function disp(This,Name,Disp2DFunc)
% disp  [Not a public function] Disp method for tseries objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    Name; %#ok<VUNUS>
catch %#ok<CTCH>
    Name = '';
end

try
    Disp2DFunc; %#ok<VUNUS>
catch %#ok<CTCH>
    Disp2DFunc = @xxDisp2d;
end

%--------------------------------------------------------------------------

mydispheader(This);

start = This.start;
data = This.data;
dataNDim = ndims(data);
config = irisget();
xxDispND(start,data,This.Comment,[],Name,Disp2DFunc,dataNDim,config);

disp@userdataobj(This);
disp(' ');

end


% Subfunctions...


%**************************************************************************


function xxDispND(Start,Data,Comment,Pos,Name,Disp2DFUnc,NDim,Config)
lastDimSize = size(Data,NDim);
nPer = size(Data,1);
tab = sprintf('\t');
sep = sprintf(':  ');
num2StrFunc = @(x) xxNum2Str(x,Config.tseriesformat);
if NDim > 2
    subsref = cell([1,NDim]);
    subsref(1:NDim-1) = {':'};
    for i = 1 : lastDimSize
        subsref(NDim) = {i};
        xxDispND(Start,Data(subsref{:}),Comment(subsref{:}), ...
            [i,Pos],Name,Disp2DFUnc,NDim-1,Config);
    end
else
    if ~isempty(Pos)
        fprintf('%s{:,:%s} =\n',Name,sprintf(',%g',Pos));
        strfun.loosespace();
    end
    if nPer > 0
        X = Disp2DFUnc(Start,Data,tab,sep,num2StrFunc);
        % Reduce the number of white spaces between numbers to 5 at most.
        X = xxReduceSpaces(X,Config.tseriesmaxwspace);
        % Print the dates and data.
        disp(X);
    end
    % Make sure long scalar comments are never displayed as `[1xN char]`.
    if length(Comment) == 1
        if isempty(regexp(Comment{1},'[\r\n]','once'))
            fprintf('\t''%s''\n',Comment{1});
        else
            fprintf('''%s''\n',Comment{1});
        end
        strfun.loosespace();
    else
        strfun.loosespace();
        disp(Comment);
    end
end
end % xxDispND()


%**************************************************************************


function X = xxDisp2d(Start,Data,Tab,Sep,Num2StrFunc)
dateFormat = 'YFP';
dateFormatW = '$ (Thu DD-Mmm-YYYY)';
nPer = size(Data,1);
range = Start + (0 : nPer-1);
dates = strjust(dat2char(range,'dateFormat=',dateFormat));
if datfreq(range(1)) == 52
    dates = [dates, ...
        strjust(dat2char(range,'dateFormat=',dateFormatW))];
end
dates = [ ...
    Tab(ones(1,nPer),:), ...
    dates, ...
    Sep(ones(1,nPer),:), ...
    ];
dataChar = Num2StrFunc(Data);
X = [dates,dataChar];
end % xxDisp2DDefault()


%**************************************************************************


function C = xxReduceSpaces(C,Max)
inx = all(C == ' ',1);
s = char(32*ones(size(inx)));
s(inx) = 'S';
s = regexprep(s,sprintf('(?<=S{%g})S',Max),'X');
C(:,s == 'X') = '';
end % xxReduceSpaces().


%**************************************************************************


function C = xxNum2Str(X,Fmt)
if isempty(Fmt)
    C = num2str(X);
else
    C = num2str(X,Fmt);
end
end % xxNum2Str()
