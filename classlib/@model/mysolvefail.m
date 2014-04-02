function [Body,Args] = mysolvefail(This,NPath,NanDeriv,Sing2)
% mysolvefail  [Not a public function] Create error/warning message when function solve fails.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

sna = 'Solution not available. ';

printAltFunc = @(x) strtrim(sprintf(' #%g',find(x)));

inx = NPath == -4;
if any(inx)
	Body = [sna, ...
		'The model is declared non-linear but fails to solve ', ...
        'because of problems with steady state [%s].'];
	Args = { printAltFunc(inx) };
	return
end

inx = NPath == -2;
if any(inx)
    Body = [sna, ...
        'Singularity or linear dependency in some equations [%s].'];
    Args = { printAltFunc(inx) };
    return
end

inx = NPath == 0;
if any(inx)
    Body = [sna,'No stable solution [%s].'];
    Args = { printAltFunc(inx) };
    return
end

inx = isinf(NPath);
if any(inx)
    Body = [sna,'Multiple stable solutions [%s].'];
    Args = { printAltFunc(inx) };
    return
end

inx = imag(NPath) ~= 0;
if any(inx)
    Body = [sna,'Complex derivatives [%s].'];
    Args = { printAltFunc(inx) };
    return
end

inx = isnan(NPath);
if any(inx)
    Body = [sna,'NaNs in system matrices [%s].'];
    Args = { printAltFunc(inx) };
    return
end

% Singularity in state space or steady state problem
inx = NPath == -1;
if any(inx)
    if any(Sing2(:))
        pos = find(any(Sing2,2));
        pos = pos(:).';
        Args = {};
        for ieq = pos
            Args{end+1} = preparser.alt2str(Sing2(ieq,:)); %#ok<AGROW>
            Args{end+1} = This.eqtn{ieq}; %#ok<AGROW>
        end
        Body = [sna, ...
            'Singularity or NaN in this measurement equation [%s]: ''%s''.'];
	elseif ~This.linear && isnan(This,'sstate')
		Args = {};
		Body = [sna, ...
			'Model is declared nonlinear but has some NaNs in its steady state [%s].'];
    else
        Args = {};
        Body = [sna, ...
            'Singularity in state-space matrices [%s].'];
    end
    return
end

inx = NPath == -3;
if any(inx)
    Args = {};
    for ii = find(inx)
        for jj = find(NanDeriv{ii})
            Args{end+1} = printAltFunc(ii); %#ok<AGROW>
            Args{end+1} = This.eqtn{jj}; %#ok<AGROW>
        end
    end
	Body = [sna, ...
        'NaN in derivatives of this equation [%s]: ''%s''.'];
end

end