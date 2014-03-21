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
        {'/*','*'}, ... Block comments.
        {'%{','%}'}, ... Block comments.
        {'<!--','-->'}, ... Block comments.
        '%', ... Line comments.
        '\.\.\.', ... Line comments.
        '//', ... Line comments.
        };
end

%--------------------------------------------------------------------------

for i = 1 : length(varargin)
    
    if ischar(varargin{i})
        
        % Remove line comments.
        % Line comments can be specified as regexps.
        Text = regexprep(Text,[varargin{i},'[^\n]*\n'],'\n');
        Text = regexprep(Text,[varargin{i},'[^\n]*$'],'');
        
    elseif iscell(varargin{i}) && length(varargin{i}) == 2
        
        % Remove block comments.
        % Block comments cannot be specified as regexps.
        Text = strrep(Text,varargin{i}{1},char(1));
        Text = strrep(Text,varargin{i}{2},char(2));
        textLen = 0;
        while length(Text) ~= textLen
            textLen = length(Text);
            Text = regexprep(Text,'\x{1}[^\x{1}]*?\x{2}','');
        end
        Text = strrep(Text,char(1),varargin{i}{1});
        Text = strrep(Text,char(2),varargin{i}{2});
        
    end
    
end

end
