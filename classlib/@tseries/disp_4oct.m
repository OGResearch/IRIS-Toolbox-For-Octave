function disp_4oct(This,Name,Disp2D)
% disp  [Not a public function] Disp method for tseries objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    Name; %#ok<VUNUS>
catch %#ok<CTCH>
    Name = '';
end

try
    Disp2D; %#ok<VUNUS>
catch %#ok<CTCH>
    Disp2D = @xxDisp2DDefault;
end

%--------------------------------------------------------------------------

mydispheader(This);

start = This.start;
data = This.data;
dataNDim = ndims(data);
config = irisget();
xxDispND(start,data,This.Comment,[],Name,Disp2D,dataNDim,config);

%disp@userdataobj(This); % commented out while this syntax is not yet implemented in Octave
   %- block from disp@userdataobj -begin- -%
      % Print comments.
      dispcomment(This);
      % Print userdata.
      dispuserdata(This);
   %- block from disp@userdataobj -end- -%
disp(' ');

end

% Subfunctions.

%**************************************************************************
function xxDispND(Start,Data,Comment,Pos,Name,Disp2D,NDim,Config)
lastDimSize = size(Data,NDim);
nPer = size(Data,1);
if NDim > 2
    subsref = cell([1,NDim]);
    subsref(1:NDim-1) = {':'};
    for i = 1 : lastDimSize
        subsref(NDim) = {i};
        xxDispND(Start,Data(subsref{:}),Comment(subsref{:}), ...
            [i,Pos],Name,Disp2D,NDim-1,Config);
    end
else
    if ~isempty(Pos)
        fprintf('%s{:,:%s} =\n',Name,sprintf(',%g',Pos));
        strfun.loosespace();
    end
    if nPer > 0
        [dates,Data] = Disp2D(Start,Data);
        try
            dataStr = num2str(Data,Config.tseriesformat);
            if ~ismatlab && isempty(Config.tseriesformat), error(); end
        catch %#ok<CTCH>
            dataStr = num2str(Data);
        end
        % Reduce the number of white spaces between numbers to 5 at most.
        dataStr = xxReduceSpaces(dataStr,Config.tseriesmaxwspace);
        % Print the dates and data.
        disp([dates,dataStr]);
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
end % xxDispND().

%**************************************************************************
function [Dates,Data] = xxDisp2DDefault(Start,Data)
nPer = size(Data,1);
range = Start + (0 : nPer-1);
tab = sprintf('\t');
sep = sprintf(':  ');
Dates = [ ...
    tab(ones(1,nPer),:), ...
    strjust(dat2char(range)),sep(ones(1,nPer),:), ...
    ];
end % xxDisp2DDefault().

%**************************************************************************
function C = xxReduceSpaces(C,Max)
inx = all(C == ' ',1);
s = char(32*ones(size(inx)));
s(inx) = 'S';
s = regexprep(s,sprintf('(?<=S{%g})S',Max),'X');
C(:,s == 'X') = '';
end % xxReduceSpaces().
