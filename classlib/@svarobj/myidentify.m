function [This,Data,B,Count] = myidentify(This,Data,Opt)
% myidentify  [Not a public function] Convert reduced-form VAR to structural VAR.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(This.A,1);
nAlt = size(This.A,3);

A = poly.var2poly(This.A);
Omg = This.Omega;

% Handle residuals.
isData = nargin > 1 && nargout > 1 && ~isempty(Data);

if isData
    % Get data.
    [outpFmt,range,y,e] = mydatarequest(This,Data,Inf,Opt);
    if size(e,3) == 1 && nAlt > 1
        y = y(:,:,ones(1,nAlt));
        e = e(:,:,ones(1,nAlt));
    end
else
    y = [];
    e = [];
end

% Std dev of structural residuals requested by the user.
This.std(1,:) = Opt.std(1,ones(1,nAlt));

B = zeros(ny,ny,nAlt);
Count = 1;
switch lower(Opt.method)
    case 'chol'
        This.method = 'Cholesky';
        doReorder();
        for ialt = 1 : nAlt
            B(:,:,ialt) = chol(Omg(:,:,ialt)).';
        end
        if Opt.std ~= 1
            B = B / Opt.std;
        end
        doBackOrder();
        doConvertResid();
    case 'qr'
        This.method = 'QR';
        doReorder();
        C = sum(A,3);
        for ialt = 1 : nAlt
            B0 = transpose(chol(Omg(:,:,ialt)));
            if rank(C(:,:,1,ialt)) == ny
                Q = qr(transpose(C(:,:,1,ialt)\B0));
            else
                Q = qr(transpose(pinv(C(:,:,1,ialt))*B0));
            end
            B(:,:,ialt) = B0*Q;
        end
        if Opt.std ~= 1
            B = B / Opt.std;
        end
        doBackOrder();
        doConvertResid();
    case 'svd'
        This.method = 'SVD';
        q = Opt.rank;
        [B,e] = covfun.orthonorm(Omg,q,Opt.std,e);
        % Recompute covariance matrix of reduced-form residuals if it is
        % reduced rank.
        if q < ny
            var = Opt.std .^ 2;
            for ialt = 1 : nAlt
                This.Omega(:,:,ialt) = ...
                    B(:,1:q,ialt)*B(:,1:q,ialt)'*var;
            end
            % Cannot produce structural residuals for reduced-rank cov matrix.
            Data = [];
            isData = false;
        else
            doConvertResid();
        end
    case 'householder'
        This.method = 'Householder';
        % Use Householder transformations to draw random SVARs. Test each SVAR
        % using teh `'test='` string to decide whether to keep it or discard.
        if nAlt > 1
            utils.error('VAR', ...
                ['Cannot run SVAR() with ''method=householder'' on ', ...
                'a VAR object with multiple parameterisation.']);
        end
        if isempty(Opt.test)
            utils.error('VAR', ...
                ['Cannot run SVAR() with ''method=householder'' and ', ...
                'empty ''test=''.']);
        end
        if any(Opt.ndraw <= 0)
            utils.warning('VAR', ...
                ['Because ''ndraw='' is zero, ', ...
                'empty SVAR object is returned.']);
        end
        [B,Count] = xxDraw(This,Opt);
        nAlt = size(B,3);
        if nAlt > 0
            if Opt.std ~= 1
                B = B / Opt.std;
            end
            This = alter(This,nAlt);
            if isData
                % Expand the number of data sets to match the number of
                % newly created structural parameterisations.
                y = y(:,:,ones(1,nAlt));
                e = e(:,:,ones(1,nAlt));
            end
            doConvertResid();
        else
            isData = false;
            This = alter(This,0);
            Data = [];
        end
end

This.B(:,:,:) = B;
if isData
    % Output data.
    names = get(This,'names');
    Data = myoutpdata(This,outpFmt,range,[y;e],[],names);
end


% Nested functions...


%**************************************************************************
    function doReorder()
        if ~isempty(Opt.reorder)
            if iscellstr(Opt.reorder)
                list = Opt.reorder;
                nList = length(list);
                valid = true(1,nList);
                Opt.reorder = nan(1,nList);
                for i = 1 : nList
                    pos = strcmp(This.Ynames,list{i});
                    valid(i) = any(pos);
                    if valid(i);
                        Opt.reorder(i) = find(pos);
                    end
                end
                if any(~valid)
                    utils.error('VAR:myidentify', ...
                        ['This variable name does not exist ', ...
                        'in the VAR object: ''%s''.'], ...
                        list{~valid});
                end
            end
            Opt.reorder = Opt.reorder(:)';
            if any(isnan(Opt.reorder)) ...
                    || length(Opt.reorder) ~= ny ...
                    || length(intersect(1:ny,Opt.reorder)) ~= ny
                utils.error('VAR:myidentify', ...
                    'Invalid reordering vector.');
            end
            A = A(Opt.reorder,Opt.reorder,:,:);
            Omg = Omg(Opt.reorder,Opt.reorder,:);
        end
    end % doReorder()


%**************************************************************************
    function doBackOrder()
        % Put variables (and residuals, if requested) back in order.
        if ~isempty(Opt.reorder)
            [~,backOrder] = sort(Opt.reorder);
            if Opt.backorderresiduals
                B = B(backOrder,backOrder,:);
            else
                B = B(backOrder,:,:);
            end
        end
    end % doBackOrder()


%**************************************************************************
    function doConvertResid()
        if isData
            for iLoop = 1 : nAlt
                e(:,:,iLoop) = B(:,:,iLoop) \ e(:,:,iLoop);
            end
        end
    end % doConvertResid()

end


% Subfunctions...


%**************************************************************************
function [BB,Count] = xxDraw(This,Opt)
%
% * Rubio-Ramirez J.F., D.Waggoner, T.Zha (2005) Markov-Switching Structural
% Vector Autoregressions: Theory and Application. FRB Atlanta 2005-27.
%
% * Berg T.O. (2010) Exploring the international transmission of U.S. stock
% price movements. Unpublished manuscript. Munich Personal RePEc Archive
% 23977, http://mpra.ub.uni-muenchen.de/23977.

test = Opt.test;
A = poly.var2poly(This.A);
C = sum(A,3);
Ci = inv(C);
ny = size(A,1);

[h,isy] = myparsetest(This,test);

P = covfun.orthonorm(This.Omega);
Count = 0;
maxFound = Opt.ndraw;
maxIter = Opt.maxiter;
BB = nan(ny,ny,0);
SS = nan(ny,ny,h,0);
YY = nan(ny,ny,0);

% Create command-window progress bar.
if Opt.progress
    pbar = progressbar('IRIS VAR.SVAR progress');
end

nb = 0;
while Count < maxIter && nb < maxFound
    Count = Count + 1;
    % Candidate rotation. Note that we need to call `qr` with two
    % output arguments to get the unitary matrix `Q`.
    [Q,ans] = qr(randn(ny)); %#ok<NASGU,NOANS>
    B = P*Q;
    % Compute impulse responses T = 1 .. h.
    if h > 0
        S = timedom.var2vma(This.A,B,h);
    else
        S = zeros(ny,ny,0);
    end
    % Compute asymptotic cum responses.
    if isy
        Y = Ci*B; %#ok<MINV>
    end
    % Test impulse responses, and include successful candidates.
    doTestNInclude();
    nb = size(BB,3);
    if Opt.progress
        update(pbar,max(Count/maxIter,nb/maxFound));
    end
end


% Nested functions...


    function doTestNInclude()
        try
            pass = isequal(eval(test),true);
            if pass
                BB(:,:,end+1) = B;
                SS(:,:,:,end+1) = S; %#ok<SETNU>
                if isy
                    YY(:,:,end+1) = Y; %#ok<SETNU>
                end
            else
                % Test minus the structure.
                B = -B;
                S = -S;
                if isy
                    Y = -Y;
                end
                pass = isequal(eval(test),true);
                if pass
                    BB(:,:,end+1) = B;
                    SS(:,:,:,end+1) = S;
                    if isy
                        YY(:,:,end+1) = Y;
                    end
                end
            end
        catch err
            utils.error('VAR', ...
                ['Error evaluating the test string ''%s''.\n', ...
                '\tMatlab says: %s'], ...
                test,err.message);
        end
    end % doTest()


end % xxDraw()
