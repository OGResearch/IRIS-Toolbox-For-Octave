function [S,Invalid] = parse(This,Opt)
% parse [Not a public function] Execute theparser object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

nBlk = length(This.blkname);

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

Invalid = struct();
Invalid.key = {};
Invalid.allbut = false;
Invalid.flag = {};
Invalid.timesubs = {};

% Read individual blocks and check for unknown keywords.
[blk,Invalid.key,Invalid.allbut] = readblk(This);
for iBlk = 1 : nBlk
    S(iBlk).blk = blk{iBlk};
end

% Read individual names within each name block.
for iBlk = find(This.nameblk)
    [S(iBlk).name,S(iBlk).namelabel, ...
        S(iBlk).namevalue,S(iBlk).nameflag] ...
        = theparser.parsenames(S(iBlk).blk);
    S(iBlk).nametype = This.nameType(iBlk)*ones(size(S(iBlk).name));
end

% Read names in the flag block (only one flag block allowed).
if any(This.flagblk)
    [S(This.flaggable),Invalid.flag] ...
        = theparser.parseflags(S(This.flagblk).blk,S(This.flaggable));
end

% Read individual equations within each equation block.
for iBlk = find(This.eqtnblk)
    [S(iBlk).eqtn,S(iBlk).eqtnlabel, ...
        S(iBlk).eqtnlhs,S(iBlk).eqtnrhs,S(iBlk).eqtnsign, ...
        S(iBlk).sstatelhs,S(iBlk).sstaterhs,S(iBlk).sstatesign] ...
        = theparser.parseeqtns(S(iBlk).blk);
    neqtn = length(S(iBlk).eqtn);
    S(iBlk).eqtntype = iBlk*ones(1,neqtn);
    % Evaluate and check time subscripts, find max and min time subscript.
    [S(iBlk).maxt,S(iBlk).mint,invalidtimesubs, ...
        S(iBlk).eqtnlhs,S(iBlk).eqtnrhs, ...
        S(iBlk).sstatelhs,S(iBlk).sstaterhs] ...
        = theparser.evaltimesubs(S(iBlk).eqtnlhs,S(iBlk).eqtnrhs, ...
        S(iBlk).sstatelhs,S(iBlk).sstaterhs);
    Invalid.timesubs = [Invalid.timesubs,invalidtimesubs];
end

% Put back labels, and split each label into the label proper and the
% alias.
for iBlk = 1 : nBlk
    S(iBlk).namelabel ...
        = preparser.labelsback(S(iBlk).namelabel,This.labels,'%s');
    S(iBlk).eqtnlabel ...
        = preparser.labelsback(S(iBlk).eqtnlabel,This.labels,'%s');
    [S(iBlk).namelabel,S(iBlk).namealias] ...
        = theparser.getalias(S(iBlk).namelabel);
    [S(iBlk).eqtnlabel,S(iBlk).eqtnalias] ...
        = theparser.getalias(S(iBlk).eqtnlabel);
end

% Use steady-state equations for full equations whenever possible.
if Opt.sstateonly
    S = theparser.sstateonly(S);
end

doChkInvalid();

% Nested functions.

%**************************************************************************
    function doChkInvalid()
        
        % Blocks marked as essential cannot be empty.
        for iiblk = find(This.essential)
            caller = strtrim(This.caller);
            if ~isempty(caller)
                caller(end+1) = ' '; %#ok<AGROW>
            end
            if isempty(S(iiblk).blk) || all(S(iiblk).blk <= char(32))
                utils.error('model',[errorparsing(This), ...
                    'Cannot find a non-empty ''%s'' block. ', ...
                    'This is not a valid ',caller,'file.'], ...
                    This.blkname{iiblk});
            end
        end
        
        % Some of the `!log_variables` section have `!allbut`, some do not have.
        if Invalid.allbut
            utils.error('model',[errorparsing(This), ...
                'The keyword !allbut may appear in either all or none of ', ...
                'the !log_variables sections.']);
        end
        
        % Invalid keyword.
        if ~isempty(Invalid.key)
            utils.error('model',[errorparsing(This), ...
                'This is not a valid keyword: ''%s''.'], ...
                Invalid.key{:});
        end
        
        % Invalid names on the log-variable list.
        if ~isempty(Invalid.flag)
            flagblkname = This.blkname{This.flagblk};
            utils.error('model',[errorparsing(This), ...
                'This name is not allowed ', ...
                'on the ''',flagblkname,''' list: ''%s''.'], ...
                Invalid.flag{:});
        end
        
        % Invalid time subscripts.
        if ~isempty(Invalid.timesubs)
            % Error evaluating time subscripts.
            utils.error('model',[errorparsing(This), ...
                'Cannot evaluate this time index: ''%s''.'], ...
                Invalid.timesubs{:});
        end
        
    end % doChkInvalid().

end