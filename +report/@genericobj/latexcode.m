function C = latexcode(This)
% latexcode  [Not a public function] Generate LaTeX code to represent a report object.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

C = speclatexcode(This);

if ~isempty(This.options.saveas)
    % Save in the current working directory, not the
    % temporary directory.
    [~,fileTitle] = fileparts(This.options.saveas);
    char2file(C,[fileTitle,'.tex']);
end

end