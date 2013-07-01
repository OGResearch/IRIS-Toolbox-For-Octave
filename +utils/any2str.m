function c = any2str(x,prec)
% ANY2STR  [Not a public function] Convert various types of complex data into a Matlab syntax string.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if ~exist('prec','var')
    prec = 15;
end

%**************************************************************************

if isnumeric(x) || ischar(x) || islogical(x)
    c = xxnumeric(x,prec);
elseif iscell(x)
    c = xxcell(x,prec);
elseif isstruct(x)
    c = xxstruct(x,prec);
else
    utils.error('utils', ...
        'ANY2STR cannot currently handle this type of data: %s.', ...
        class(x));
end    

end

% Subfuntions.

%**************************************************************************
function c = xxnumeric(x,prec)

nd = ndims(x);

if nd == 2
    c = mat2str(x,prec);
else
    ref = cell(1,nd);
    ref(1:nd-1) = {':'};
    c = sprintf('cat(%g',nd);
    for i = 1 : size(x,nd)
        ref{nd} = i;
        c = [c,',',xxnumeric(x(ref{:}),prec)];
    end
    c = [c,')'];
end

end
% xxnumeric().

%**************************************************************************
function c = xxcell(x,prec)

if isempty(x)
  s = size(x);
  c = ['cell(',sprintf('%g',s(1)),sprintf(',%g',s(2:end)),')'];
  return
end

nd = ndims(x);

if nd == 2
    c = xxcell2d(x,prec);
else
    ref = cell(1,nd);
    ref(1:nd-1) = {':'};
    c = sprintf('cat(%g',nd);
    for i = 1 : size(x,nd)
        ref{nd} = i;
        c = [c,',{',xxnumeric(x{ref{:}},prec),'}'];
    end
    c = [c,')'];
end

end
% xxcell().

%**************************************************************************
function c = xxcell2d(x,prec)

[nrow,ncol] = size(x);

c = '{';
for i = 1 : nrow
    for j = 1 : ncol
        if j > 1
            c = [c,','];
        end
        c = [c,utils.any2str(x{i,j},prec)]; %#ok<*AGROW>
    end
    if i < nrow
        c = [c,';'];
    end
end
c = [c,'}'];

end
% xxcel2d().

%**************************************************************************
function c = xxstruct(x,prec)

len = length(x);
if len ~= 1
    utils.error('utils', ...
        'ANY2STR cannot currently handle struct arrays.');
end
    
list = fieldnames(x);
c = 'struct(';
for i = 1 : length(list)
    c1 = utils.any2str(x.(list{i}),prec);
    if iscell(x.(list{i}))
        c1 = ['{',c1,'}'];
    end
    if i > 1
        c = [c,','];
    end
    c = [c,'''',list{i},''',',c1];
end
c = [c,')'];

end
% xxstruct().
