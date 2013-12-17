function D = addparam(This,D)
% addparam  Add model parameters to a database (struct).
%
% Syntax
% =======
%
%     D = addparam(M,D)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose parameters will be added to database
% (struct) `D`.
%
% * `D` [ struct ] - Database to which the model parameters will be added.
%
% Output arguments
% =================
%
% * `D [ struct ] - Database with the model parameters added.
%
% Description
% ============
%
% If there are database entries in `D` whose names conincide with the model
% parameters, they will be overwritten.
%
% Example
% ========
%
%     D = struct();
%     D = addparam(M,D);
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    D; %#ok<VUNUS>
catch %#ok<CTCH>
    D = struct();
end

%--------------------------------------------------------------------------

for iPar = find(This.nametype == 4)
    name = This.name{iPar};
    D.(name) = permute(This.Assign(1,iPar,:),[1,3,2]);
end

end
