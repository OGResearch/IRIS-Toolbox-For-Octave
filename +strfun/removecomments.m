function text = removecomments(text,varargin)
% removecomments  Remove comments from text.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if nargin == 1
    % Standard IRIS commments.
    varargin = { ...
        {'/*','*'}, ... Block comments.
        {'%{','%}'}, ... Block comments.
        {'<!--','-->'}, ... Block comments.
        '%', ... Line comments.
        '\.\.\.', ... Line comments.
        '//', ... Line comments.
        };
end

%**************************************************************************

for i = 1 : length(varargin)
    
    if ischar(varargin{i})
        
        % Remove line comments.
        % Line comments can be specified as regexps.
        text = regexprep(text,[varargin{i},'[^\n]*\n'],'\n');
        text = regexprep(text,[varargin{i},'[^\n]*$'],'');
        
    elseif iscell(varargin{i}) && length(varargin{i}) == 2
        
        % Remove block comments.
        % Block comments cannot be specified as regexps.
        text = strrep(text,varargin{i}{1},char(1));
        text = strrep(text,varargin{i}{2},char(2));
        textlength = 0;
        while length(text) ~= textlength
            textlength = length(text);
            text = regexprep(text,'\x{1}[^\x{1}]*?\x{2}','');
        end
        text = strrep(text,char(1),varargin{i}{1});
        text = strrep(text,char(2),varargin{i}{2});
        
    end
    
end

end
