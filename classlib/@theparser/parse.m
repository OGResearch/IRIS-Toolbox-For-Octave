function [S,Asgn] = parse(This,Opt)
% parse [Not a public function] Execute theparser object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

nBlk = length(This.BlkName);

% Replace alternative block syntax.
This = altsyntax(This);

% Output struct.
S = struct();

S.Blk = [];

S.name = cell(1,0);
S.nametype = zeros(1,0);
S.namelabel = cell(1,0);
S.namealias = cell(1,0);
S.NameValue = cell(1,0);
S.IxLog = false(1,0);

S.eqtn = cell(1,0);
S.eqtntype = zeros(1,0);
S.eqtnlabel = cell(1,0);
S.eqtnalias = cell(1,0);
S.EqtnLhs = cell(1,0);
S.EqtnRhs = cell(1,0);
S.EqtnSign = cell(1,0);
S.SstateLhs = cell(1,0);
S.SstateRhs = cell(1,0);
S.SstateSign = cell(1,0);

S.maxt = zeros(1,0);
S.mint = zeros(1,0);

S = S(ones(1,nBlk));

invalid = struct();
invalid.assign = {};
invalid.key = {};
invalid.allBut = false;
invalid.log = {};
invalid.timeSubs = {};
invalid.emptyEqtn = {};
invalid.stdcorr = {};

% Read individual blocks and check for unknown keywords.

[blk,invalid.key,invalid.allBut] = readblk(This);
for iBlk = 1 : nBlk
    S(iBlk).Blk = blk{iBlk};
end

% Read individual names and assignments within each name block.
for iBlk = find(This.IxNameBlk)
    [S(iBlk).name,S(iBlk).namelabel, ...
        S(iBlk).NameValue,S(iBlk).IxLog] ...
        = parsenames(This,S(iBlk).Blk);
    S(iBlk).nametype = This.NameType(iBlk)*ones(size(S(iBlk).name));
    if ~This.IxStdcorrAllowed(iBlk)
        % Report all names starting with `std_` or `corr_`.
        ixStd = strncmp(S(iBlk).name,'std_',4);
        ixCorr = strncmp(S(iBlk).name,'corr_',5);
        ixStdcorr = ixStd | ixCorr;
        if any(ixStdcorr)
            invalid.stdcorr = [invalid.stdcorr,S(iBlk).name(ixStdcorr)];
        end
    end
end

% Read names in log block.
if any(This.IxLogBlk)
    [S(This.IxLoggable),invalid.log] ...
        = parselog(This,S(This.IxLogBlk).Blk,S(This.IxLoggable));
end

% Read individual equations within each equation block; evaluate and
% validate time subscripts; check for empty equations consisting of labels
% only.
for iBlk = find(This.IxEqtnBlk)
    [S(iBlk).eqtn,S(iBlk).eqtnlabel, ...
        S(iBlk).EqtnLhs,S(iBlk).EqtnRhs,S(iBlk).EqtnSign, ...
        S(iBlk).SstateLhs,S(iBlk).SstateRhs,S(iBlk).SstateSign, ...
        S(iBlk).maxt,S(iBlk).mint,invalidTimeSubs,emptyEqtn] ...
        = parseeqtns(This,S(iBlk).Blk);
    nEqtn = length(S(iBlk).eqtn);
    S(iBlk).eqtntype = iBlk*ones(1,nEqtn);
    invalid.timeSubs = [invalid.timeSubs,invalidTimeSubs];
    invalid.emptyEqtn = [invalid.emptyEqtn,emptyEqtn];
end

doChkInvalid();

% Put back labels, and extract alias from each label.
for iBlk = 1 : nBlk
    S(iBlk).namelabel ...
        = restore(S(iBlk).namelabel,This.Labels,'delimiter=',false);
    S(iBlk).eqtnlabel ...
        = restore(S(iBlk).eqtnlabel,This.Labels,'delimiter=',false);
    [S(iBlk).namelabel,S(iBlk).namealias] = xxGetAlias(S(iBlk).namelabel);
    [S(iBlk).eqtnlabel,S(iBlk).eqtnalias] = xxGetAlias(S(iBlk).eqtnlabel);
end

if Opt.sstateonly
    % Use steady-state equations for full equations whenever possible.
    S = xxSstateOnly(S);
end

% Clear multiple names if allowed; the last occurence will be used within
% each block. Mutliple names defined in different blocks are never allowed,
% and will be caught in `doChkMultiple()`.
if Opt.multiple
    doClearMultiple();
end

% Collect in-file assignments, evaluate them, add to the Asgn database, and
% remove all references to stdcorr names in name blocks.
[This,S] = assign(This,S);
Asgn = This.Assign;

% Verify naming rules.
doChkNamingRules();

% Check for multiple names.
doChkMultiple();


% Nested functions...


%**************************************************************************

    
    function doChkNamingRules()
        % Names must not start with 0-9 or _.
        iinx = This.IxNameBlk;
        list = [S(iinx).name];
        valid = cellfun(@isempty,regexp(list,'^[0-9_]','once'));
        if any(~valid)
            utils.error('theparser:parse',[utils.errorparsing(This), ....
                'This is not a valid name: ''%s''.'], ...
                list{~valid});
        end
        % The name `ttrend` is a reserved name for time trend in
        % `!dtrends`.
        valid = ~strcmp(list,'ttrend');
        if any(~valid)
            utils.error('theparser:parse',[utils.errorparsing(This), ....
                'The reserved keyword ''ttrend'' ', ...
                'must not be used as a name.'], ...
                list{~valid});
        end
        % Shock names must not contain double scores because of the way
        % cross-correlations are referenced.
        iinx = This.IxStdcorrBasis;
        list = [S(iinx).name];
        valid = cellfun(@isempty,strfind(list,'__'));
        if any(~valid)
            utils.error('theparser:parse',[utils.errorparsing(This), ....
                'Names of shocks and residuals are not allowed to include ', ...
                'a double underscore: ''%s''.'], ...
                list{~valid});
        end
    end % doChkNamingRules()


%**************************************************************************
   
    
    function doClearMultiple()
        % Take the last defined/assigned name in each name block.
        for iiBlk = find(This.IxNameBlk)
            [~,ixRemove] = strfun.unique(S(iiBlk).name);
            if any(ixRemove)
                S(iiBlk).name(ixRemove) = [];
                S(iiBlk).nametype(ixRemove) = [];
                S(iiBlk).namelabel(ixRemove) = [];
                S(iiBlk).namealias(ixRemove) = [];
                S(iiBlk).NameValue(ixRemove) = [];
                S(iiBlk).IxLog(ixRemove) = [];
            end
        end
    end % doClearMultiple()


%**************************************************************************
   
    
    function doChkMultiple()
        % Check for multiple names unless `'multiple=' true`.
        iinx = This.IxNameBlk;
        list = [S(iinx).name];
        [~,~,ixMultiple] = strfun.unique(list);
        if any(ixMultiple)
            utils.error('theparser:parse',[utils.errorparsing(This), ...
                'This name is declared more than once: ''%s''.'], ...
                list{ixMultiple});
        end
    end % doChkMultiple()


%**************************************************************************
   
    
    function doChkInvalid()
        ep = utils.errorparsing(This);
        
        % Blocks marked as IxEssential cannot be empty.
        for iiBlk = find(This.IxEssential)
            caller = strtrim(This.Caller);
            if ~isempty(caller)
                caller(end+1) = ' '; %#ok<AGROW>
            end
            if isempty(S(iiBlk).Blk) || all(S(iiBlk).Blk <= char(32))
                utils.error('theparser:parse',[ep,...
                    'Cannot find a non-empty ''%s'' block. ', ...
                    'This is not a valid ',caller,'file.'], ...
                    This.BlkName{iiBlk});
            end
        end
        
        % Inconsistent use of `!all_but` in `!log_variables` sections.
        if invalid.allBut
            utils.error('theparser:parse',[ep, ...
                'The keyword !all_but may appear in either all or none of ', ...
                'the !log_variables sections.']);
        end
        
        % Invalid keyword.
        if ~isempty(invalid.key)
            utils.error('theparser:parse',[ep, ...
                'This is not a valid keyword: ''%s''.'], ...
                invalid.key{:});
        end
        
        % Invalid names on the log-variable list.
        if ~isempty(invalid.log)
            IxLogBlkname = This.BlkName{This.IxLogBlk};
            utils.error('theparser:parse',[ep, ...
                'This name is not allowed ', ...
                'in the ''',IxLogBlkname,''' list: ''%s''.'], ...
                invalid.log{:});
        end
        
        % Invalid time subscripts.
        if ~isempty(invalid.timeSubs)
            invalid.timeSubs = restore(invalid.timeSubs,This.Labels);
            utils.error('theparser:parse',[ep, ...
                'Cannot evaluate time index in this equation: ''%s''.'], ...
                invalid.timeSubs{:});
        end
        
        % Equations that consist of labels only (throw a warning, not error).
        if ~isempty(invalid.emptyEqtn)
            invalid.emptyEqtn = restore(invalid.emptyEqtn,This.Labels);
            utils.warning('theparser:parse',[ep, ...
                'This equation is empty, and will be removed: ''%s''.'], ...
                invalid.emptyEqtn{:});
        end            
        
        % Names starting with 'std_' or 'corr_' except those allowed.
        if ~isempty(invalid.stdcorr)
            utils.error('theparser:parse',[ep, ...
                'This is not a valid name of its type: ''%s''.'], ...
                invalid.stdcorr{:});
        end
    end % doChkInvalid()


end


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
        if isempty(S(i).SstateLhs{j}) && isempty(S(i).SstateRhs{j}) ...
                && isempty(S(i).SstateSign{j})
            continue
        end
        S(i).EqtnLhs{j} = S(i).SstateLhs{j};
        S(i).EqtnRhs{j} = S(i).SstateRhs{j};
        S(i).EqtnSign{j} = S(i).SstateSign{j};
        S(i).SstateLhs{j} = '';
        S(i).SstateRhs{j} = '';
        S(i).SstateSign{j} = '';
        pos = strfind(S(i).eqtn{j},'!!');
        if ~isempty(pos)
            S(i).eqtn{j}(1:pos+1) = '';
        end
    end
end
end %% xxSstateOnly()
