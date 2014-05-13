function Text = removecomments(Text,varargin)
% removecomments  Remove comments from text.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if nargin == 1
    % Standard IRIS commments.
    varargin = { ...
        ... {'/*','*/'}, ... Block comments.
        {'%{','%}'}, ... Block comments.
        ... {'<!--','-->'}, ... Block comments.
        '%', ... Line comments.
        '\.\.\.', ... Line comments.
        ... '//', ... Line comments.
        };
end

%--------------------------------------------------------------------------

openCode = char(1);
closeCode = char(2);

for i = 1 : length(varargin)
    
    if ischar(varargin{i})
        
        % Remove line comments.
        % Line comments can be specified as regexps.
        Text = regexprep(Text,[varargin{i},'[^\n]*\n'],'\n');
        Text = regexprep(Text,[varargin{i},'[^\n]*$'],'');
        
    elseif iscell(varargin{i}) && length(varargin{i}) == 2
        
        % Remove block comments.
        % Block comments cannot be specified as regexps.
        open = varargin{i}{1};
        close = varargin{i}{2};
        Text = strrep(Text,open,openCode);
        Text = strrep(Text,close,closeCode);
        while true
            lenText = length(Text);
            ptn = [openCode,'[^',openCode,']*?',closeCode];
            Text = regexprep(Text,ptn,'');
            if length(Text) == lenText
                break
            end
        end
        Text = strrep(Text,openCode,open);
        Text = strrep(Text,closeCode,close);
    end
    
end

end
