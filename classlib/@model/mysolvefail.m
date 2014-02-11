function [Body,Args] = mysolvefail(This,NPath,NanDeriv,Sing2)

sna = 'Solution not available. ';

printAltFunc = @(x) sprintf(' #%g',find(x));

inx = NPath == -4;
if any(inx)
	Body = [sna, ...
		'The model is declared non-linear but fails to solve because of problems with the steady state.'];
	Args = { printAltFunc(inx) };
	return
end

inx = NPath == -2;
if any(inx)
    Body = [sna, ...
        'Singularity or linear dependency in some equations in%s.'];
    Args = { printAltFunc(inx) };
    return
end

inx = NPath == 0;
if any(inx)
    Body = [sna,'No stable solution in%s.'];
    Args = { printAltFunc(inx) };
    return
end

inx = isinf(NPath);
if any(inx)
    Body = [sna,'Multiple stable solutions in%s.'];
    Args = { printAltFunc(inx) };
    return
end

inx = imag(NPath) ~= 0;
if any(inx)
    Body = [sna,'Complex derivatives in%s.'];
    Args = { printAltFunc(inx) };
    return
end

inx = isnan(NPath);
if any(inx)
    Body = [sna,'NaNs in system matrices in%s.'];
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
            'Singularity or NaN in this measurement equation in%s: ''%s''.'];
	elseif isnan(This) && issolved(solve(This,'linear=',true))
		Args = {};
		Body = [sna, ...
			'Model is linear but is not declared linear and does not have a steady state solution:%s'];
    else
        Args = {};
        Body = [sna, ...
            'Singularity in state-space matrices:%s.'];
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
        'NaN in derivatives of this equation in%s: ''%s''.'];
end

end