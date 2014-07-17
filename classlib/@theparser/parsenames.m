function [Name,Label,Value,NameFlag] = parsenames(This,Blk)
% parsenames [Not a public function] Parse names within a name block.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(Blk)
    Name = cell(1,0);
    Label = cell(1,0);
    Value = cell(1,0);
    NameFlag = false(1,0);
    return
end

% Protect first-level round and square brackets. This is to handle e.g.
% assignments with function calls and multiple input arguments to those
% functions separated with commas (commas are valid separator of
% parameters).
f = fragileobj(Blk);
[Blk,f] = protectbrackets(Blk,f);

% Parse names with labels and assignments.
ptn = [ ...
    '((',regexppattern(This.Labels),')?)\s*', ... % Label.
    '([a-zA-Z]\w*)\s*', ... % Name.
    '((=[^;,\n]+[;,\n])?)', ... % Value.
    ]; 

x = regexp(Blk,ptn,'tokens');
x = [x{:}];

Label = x(1:3:end);
Name = x(2:3:end);
Value = x(3:3:end);
Value = strrep(Value,'=','');
Value = strrep(Value,'!','');
% Restore protected brackets.
Value = restore(Value,f);
Value = strtrim(Value);
NameFlag = false(size(Name));

end
