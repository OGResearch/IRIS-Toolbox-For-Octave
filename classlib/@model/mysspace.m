function [T,R,K,Z,H,D,U,Omg,Zb] = mysspace(This,IAlt,Expand)
% mysspace  [Not a public function] General state space with forward expansion.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    if isequal(IAlt,Inf)
        IAlt = ':';
    end
catch %#ok<CTCH>
    IAlt = ':';
end

try
    Expand; %#ok<VUNUS>
catch %#ok<CTCH>
    Expand = false;
end

%--------------------------------------------------------------------------

T = This.solution{1}(:,:,IAlt);
R = This.solution{2}(:,:,IAlt); % Forward expansion.
K = This.solution{3}(:,:,IAlt);
Z = This.solution{4}(:,:,IAlt);
H = This.solution{5}(:,:,IAlt);
D = This.solution{6}(:,:,IAlt);
U = This.solution{7}(:,:,IAlt);
Y = This.solution{8}(:,:,IAlt); %#ok<NASGU>
Zb = This.solution{9}(:,:,IAlt);

nAlt = size(T,3);
nb = size(T,2);
ne = sum(This.nametype == 3);

if ~Expand
    R = R(:,1:ne);
end
if isempty(Z)    
    Z = zeros(0,nb,nAlt);
end
if isempty(Zb)
    Zb = zeros(0,nb,nAlt);
end
if isempty(H)
    H = zeros(0,ne,nAlt);
end
if isempty(D)
    D = zeros(0,1,nAlt);
end

if nargout > 7
    Omg = omega(This,[],IAlt);
end

end