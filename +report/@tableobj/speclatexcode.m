function C = speclatexcode(This)
% speclatexcode  [Not a public function] Latex code for table objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

br = sprintf('\n');
C = '';

if isempty(This.options.range)
    caption = This.title;
    if isempty(caption)
        caption = 'unnamed table';
    end
    utils.warning('report', ...
        ['Empty range in table ''%s''. ', ...
        'No table will be produced.'], ...
        caption);
    return
end

% Start the tabular environment.
This.ncol = length(This.options.range);
This.options.colspec = colspec(This);

C = [C,begin(This)];

% Create headline.
C = [C, br, '\hline', br, ...
    headline(This), ...
    '\\', br, '\hline', br ];

% If this is a long table (with the latex longtable package used), mark the
% end of headlines.
if This.options.long
    C = [C,'\endhead', br ];
end

% Cycle over children and create table rows.
nChild = length(This.children);
for i = 1 : nChild
    c1 = latexcode(This.children{i});
    C = [C,c1]; %#ok<AGROW>
    if isfield(This.children{i}.options,'separator') ...
            && ~isempty(This.children{i}.options.separator)
        C = [C, br, This.children{i}.options.separator]; %#ok<AGROW>
    end
    C = [C, br ]; %#ok<AGROW>
end

C = [C,finish(This)];
C = [C,footnotetext(This)];

end