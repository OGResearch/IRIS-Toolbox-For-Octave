function S = parse(This,Opt)
% parse [Not a public function] Execute theparser object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

nBlk = length(This.blkName);

% Replace alternative block syntax.
This = altsyntax(This);

% Output struct.
S = struct();

S.blk = [];
S.name = cell(1,0);
S.nametype = zeros(1,0);
S.namelabel = cell(1,0);
S.namealias = cell(1,0);
S.namevalue = cell(1,0);
S.nameflag = false(1,0);
S.eqtn = cell(1,0);
S.eqtntype = zeros(1,0);
S.eqtnlabel = cell(1,0);
S.eqtnalias = cell(1,0);
S.eqtnlhs = cell(1,0);
S.eqtnrhs = cell(1,0);
S.eqtnsign = cell(1,0);
S.sstatelhs = cell(1,0);
S.sstaterhs = cell(1,0);
S.sstatesign = cell(1,0);
S.maxt = zeros(1,0);
S.mint = zeros(1,0);

S = S(ones(1,nBlk));

invalid = struct();
invalid.assign = {};
invalid.key = {};
invalid.allbut = false;
invalid.flag = {};
invalid.timesubs = {};

% Read individual blocks and check for unknown keywords.
[blk,invalid.key,invalid.allbut] = readblk(This);
for iBlk = 1 : nBlk
    S(iBlk).blk = blk{iBlk};
end

% Read individual names and assignments within each name block.
for iBlk = find(This.nameBlk)
    [S(iBlk).name,S(iBlk).namelabel, ...
        S(iBlk).namevalue,S(iBlk).nameflag] ...
        = parsenames(This,S(iBlk).blk);
    S(iBlk).nametype = This.nameType(iBlk)*ones(size(S(iBlk).name));
end

% Read names in flag block (only one flag block allowed).
if any(This.flagBlk)
    [S(This.flaggable),invalid.flag] ...
        = parseflags(This,S(This.flagBlk).blk,S(This.flaggable));
end

% Read individual equations within each equation block.
for iBlk = find(This.eqtnBlk)
    [S(iBlk).eqtn,S(iBlk).eqtnlabel, ...
        S(iBlk).eqtnlhs,S(iBlk).eqtnrhs,S(iBlk).eqtnsign, ...
        S(iBlk).sstatelhs,S(iBlk).sstaterhs,S(iBlk).sstatesign] ...
        = parseeqtns(This,S(iBlk).blk);
    nEqtn = length(S(iBlk).eqtn);
    S(iBlk).eqtntype = iBlk*ones(1,nEqtn);
    % Evaluate and check time subscripts, find max and min time subscript.
    [S(iBlk).maxt,S(iBlk).mint,invalidTimeSubs, ...
        S(iBlk).eqtnlhs,S(iBlk).eqtnrhs, ...
        S(iBlk).sstatelhs,S(iBlk).sstaterhs] ...
        = xxEvalTimeSubs(S(iBlk).eqtnlhs,S(iBlk).eqtnrhs, ...
        S(iBlk).sstatelhs,S(iBlk).sstaterhs);
    invalid.timesubs = [invalid.timesubs,invalidTimeSubs];
end

% Put back labels, and extract alias from each label.
for iBlk = 1 : nBlk
    S(iBlk).namelabel ...
        = restore(S(iBlk).namelabel,This.labels,'delimiter=',false);
    S(iBlk).eqtnlabel ...
        = restore(S(iBlk).eqtnlabel,This.labels,'delimiter=',false);
    [S(iBlk).namelabel,S(iBlk).namealias] = xxGetAlias(S(iBlk).namelabel);
    [S(iBlk).eqtnlabel,S(iBlk).eqtnalias] = xxGetAlias(S(iBlk).eqtnlabel);
end

% Use steady-state equations for full equations whenever possible.
if Opt.sstateonly
    S = xxSstateOnly(S);
end

doChkInvalid();


% Nested functions.


%**************************************************************************

    
    function doChkInvalid()
        
        % Blocks marked as essential cannot be empty.
        for iiBlk = find(This.essential)
            caller = strtrim(This.caller);
            if ~isempty(caller)
                caller(end+1) = ' '; %#ok<AGROW>
            end
            if isempty(S(iiBlk).blk) || all(S(iiBlk).blk <= char(32))
                utils.error('model',[errorparsing(This), ...
                    'Cannot find a non-empty ''%s'' block. ', ...
                    'This is not a valid ',caller,'file.'], ...
                    This.blkName{iiBlk});
            end
        end
        
        % Inconsistent use of `!all_but` inn `!log_variables` sections.
        if invalid.allbut
            utils.error('model',[errorparsing(This), ...
                'The keyword !all_but may appear in either all or none of ', ...
                'the !log_variables sections.']);
        end
        
        % Invalid keyword.
        if ~isempty(invalid.key)
            utils.error('model',[errorparsing(This), ...
                'This is not a valid keyword: ''%s''.'], ...
                invalid.key{:});
        end
        
        % Invalid names on the log-variable list.
        if ~isempty(invalid.flag)
            flagBlkname = This.blkName{This.flagBlk};
            utils.error('model',[errorparsing(This), ...
                'This name is not allowed ', ...
                'on the ''',flagBlkname,''' list: ''%s''.'], ...
                invalid.flag{:});
        end
        
        % Invalid time subscripts.
        if ~isempty(invalid.timesubs)
            % Error evaluating time subscripts.
            utils.error('model',[errorparsing(This), ...
                'Cannot evaluate this time index: ''%s''.'], ...
                invalid.timesubs{:});
        end
        
    end % doChkInvalid()

end % parse()


% Subfunctions.


%**************************************************************************


function [Label,Alias] = xxGetAlias(Label)
% xxGetAlias  Extract alias from raw label.

if isempty(Label)
    Alias = Label;
    return
end

Alias = cell(size(Label));
Alias (:) = {''};
for i = 1 : length(Label)
    pos = strfind(Label{i},'!!');
    if isempty(pos)
        continue
    end
    Alias{i} = Label{i}(pos+2:end);
    Label{i} = Label{i}(1:pos-1);
end
Alias = strtrim(Alias);
Label = strtrim(Label);

end % xxGetAlias()


%**************************************************************************


function S = xxSstateOnly(S)
% sstateonly  Replace full equations with steady-state equatoins when
% present.

for i = 1 : length(S)
    if isempty(S(i).eqtn)
        continue
    end
    for j = 1 : length(S(i).eqtn)
        if isempty(S(i).sstatelhs{j}) && isempty(S(i).sstaterhs{j}) ...
                && isempty(S(i).sstatesign{j})
            continue
        end
        S(i).eqtnlhs{j} = S(i).sstatelhs{j};
        S(i).eqtnrhs{j} = S(i).sstaterhs{j};
        S(i).eqtnsign{j} = S(i).sstatesign{j};
        S(i).sstatelhs{j} = '';
        S(i).sstaterhs{j} = '';
        S(i).sstatesign{j} = '';
        pos = strfind(S(i).eqtn{j},'!!');
        if ~isempty(pos)
            S(i).eqtn{j}(1:pos+1) = '';
        end
    end
end

end %% xxSstateOnly()


%**************************************************************************
%**************************************************************************
function [MaxT,MinT,Invalid,varargout] = xxEvalTimeSubs(varargin)
% xxEvalTimeSubs  Validate and evaluate time subscripts.

varargout = varargin;
MaxT = 0;
MinT = 0;
Invalid = {};

replaceFunc = @doReplace; %#ok<NASGU>
for i = 1 : length(varargout)
    varargout{i} = ...
        regexprep(varargout{i},'\{([^\}\{;]*)\}','${replaceFunc($1)}');
end

    function C = doReplace(C)
        if strcmp(C,'0')
            C = '';
            return
        end
        % Try `sscanf` first, it's faster than `eval`.
        tmp = sscanf(C,'%g');
        if length(tmp) == 1 && isnumeric(tmp) && ~isnan(tmp)
            tmp = round(tmp);
            if tmp == 0
                C = '';
            else
                C = sprintf('{%+g}',tmp);
                MaxT = max([MaxT,tmp]);
                MinT = min([MinT,tmp]);
            end
            return
        end
        % If `sscanf` fails, try eval.
        tmp = xxProtectedEval(C);
        if length(tmp) == 1 && isnumeric(tmp) && ~isnan(tmp)
            tmp = round(tmp);
            if tmp == 0
                C = '';
            else
                C = sprintf('{%+g}',tmp);
                MaxT = max([MaxT,tmp]);
                MinT = min([MinT,tmp]);
            end
            return
        end
        Invalid{end+1} = ['{',C,'}'];
        C = '';
    end % doReplace()

end %% xxEvalTimeSubs()


%**************************************************************************


function ProtectedArg = xxProtectedEval(ProtectedArg)
% xxProtectedEval  Protected eval.

try
    t = 0; %#ok<NASGU>
    ProtectedArg = eval([ProtectedArg,';']);
catch %#ok<CTCH>
    ProtectedArg = NaN;
end

end % xxProtectedEval()