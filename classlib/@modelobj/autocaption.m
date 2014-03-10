function C = autocaption(This,X,Template,varargin)
% autocaption  Create captions for graphs of model variables or parameters.
%
% Syntax
% =======
%
%     C = autocaption(M,X,Template,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `X` [ cellstr | struct | poster ] - A cell array of model names, a
% struct with model names, or a [`poster`](poster/Contents) object.
%
% * `Template` [ char ] - Prescription for how to create the caption; see
% Description for details.
%
% Output arguments
% =================
%
% * `C` [ cellstr ] - Cell array of captions, with one for each model name
% (variable, shock, parameter) found in `X`, in order of their appearance
% in `X`.
%
% Options
% ========
%
% * `'corr='` [ char | *`'Corr $shock1$ X $shock2$'`* ] - Template to
% create `$descript$` and `$alias$` for correlation coefficients based on
% `$descript$` and `$alias$` of the underlying shocks.
%
% * `'std='` [ char | *`'Std $shock$'`* ] - Template to create
% `$descript$` and `$alias$` for std deviation based on `$descript$` and
% `$alias$` of the underlying shock.
%
% Description
% ============
%
% The function `autocaption` can be used to supply user-created captions to
% title graphs in `grfun/plotpp`, `grfun/plotneigh`, `model/shockplot`,
% `dbase/dbplot`, and `qreport/qplot`, through their option `'caption='`.
%
% The `Template` can contain the following substitution strings:
%
% * `$name$` -- will be replaced with the name of the respective variable,
% shock, or parameter;
%
% * `$descript$` -- will be replaced with the description of the respective
% variable, shock, or parameter;
%
% * `$alias$` -- will be replaced with the alias of the respective
% variable, shock, or parameter.
%
% The options `'corr='` and `'std='` will be used to create `$descript$`
% and `$alias$ for std deviations and cross-correlations of shocks (which
% cannot be created in the model code). The options are expected to use the
% following substitution strings:
%
% * `'$shock$'` -- will be replaced with the description or alias of the
% underlying shock in a std deviation;
%
% * `'$shock1$'` -- will be replaced with the description or alias of the
% first underlying shock in a cross correlation;
%
% * `'$shock2$'` -- will be replaced with the description or alias of the
% second underlying shock in a cross correlation.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

opt = passvalopt('modelobj.autocaption',varargin{:});

%--------------------------------------------------------------------------

if isa(X,'poster')
    List = X.paramList;
elseif isstruct(X)
    List = fieldnames(X);
elseif iscellstr(X)
    List = preparser.labeledexpr(X);
else
    utils.error('model', ...
        ['The second input argument must be a poster object, ', ...
        'a struct, or a cellstr.']);
end

% Take the first word, discard all other characters.
List = regexp(List,'[A-Za-z]\w*','match','once');

if isempty(Template)
    C = List;
    return
end

Template = strrep(Template,'\\',sprintf('\n'));
opt.std = strrep(opt.std,'\\',sprintf('\n'));
opt.corr = strrep(opt.corr,'\\',sprintf('\n'));

eList = This.name(This.nametype == 3);
nList = length(List);
C = cell(1,nList);
for i = 1 : nList
    name = List{i};
    [assignInx,stdcorrInx,shkInx1,shkInx2] ...
        = model.mynameindex(This.name,eList,name);
    if ~any(assignInx) && ~any(stdcorrInx)
        C{i} = List{i};
        continue
    end
    if any(assignInx)
        descript = This.namelabel{assignInx};
        alias = This.namealias{assignInx};
    elseif any(shkInx1) && ~any(shkInx2)
        % Look up position of the underlying shock in the Assign vector.
        assignInx = strcmp(This.name,eList{shkInx1});
        descript = opt.std;
        descript = strrep(descript,'$shock$',This.namelabel{assignInx});
        alias = opt.std;
        alias = strrep(alias,'$shock$',This.namealias{assignInx});
    else
        % Look up positions of the underlying shocks in the Assign vector.
        assignInx1 = strcmp(This.name,eList{shkInx1});
        assignInx2 = strcmp(This.name,eList{shkInx2});
        descript = opt.corr;
        descript = strrep(descript,'$shock1$',This.namelabel{assignInx1});
        descript = strrep(descript,'$shock2$',This.namelabel{assignInx2});
        alias = opt.corr;
        alias = strrep(alias,'$shock1$',This.namealias{assignInx1});
        alias = strrep(alias,'$shock2$',This.namealias{assignInx2});
    end
    C{i} = Template;
    C{i} = strrep(C{i},'$name$',name);
    C{i} = strrep(C{i},'$descript$',descript);
    C{i} = strrep(C{i},'$alias$',alias);
end

end