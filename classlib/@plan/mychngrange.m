function This = mychngrange(This,NewRange)
% mychngrange  [Not a public function] Expand or reduce simulation plan range.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

doChkFreq();
doChngRange();
This.startDate = NewRange(1);
This.endDate = NewRange(end);

% Nested functions.

%**************************************************************************
    function doChkFreq()
        if ~freqcmp(This.startDate,NewRange(1)) ...
                || ~freqcmp(This.endDate,NewRange(end))
            utils.error('plan', ...
                ['Invalid date frequency of the new range ', ...
                'in subscripted reference to plan object.']);
        end
    end % doChkFreq().

%**************************************************************************
    function doChngRange()
        nx = size(This.xAnchors,1);
        nNReal = size(This.nAnchorsReal,1);
        nNImag = size(This.nAnchorsImag,1);
        nc = size(This.cAnchors,1);
        nq = size(This.qAnchors,1);
        
        if ~isinf(NewRange(1))
            if NewRange(1) < This.startDate
                nPre = round(This.startDate - NewRange(1));
                This.xAnchors = [false(nx,nPre),This.xAnchors];
                This.nAnchorsReal = [false(nNReal,nPre),This.nAnchorsReal];
                This.nAnchorsImag = [false(nNImag,nPre),This.nAnchorsImag];
                This.nWeightsReal = [zeros(nNReal,nPre),This.nWeightsReal];
                This.nWeightsImag = [zeros(nNImag,nPre),This.nWeightsImag];
                This.cAnchors = [false(nc,nPre),This.cAnchors];
                This.qAnchors = [false(nq,nPre),This.qAnchors];
            elseif NewRange(1) > This.startDate
                nPre = round(NewRange(1) - This.startDate);
                This.xAnchors = This.xAnchors(:,nPre+1:end);
                This.nAnchorsReal = This.nAnchorsReal(:,nPre+1:end);
                This.nAnchorsImag = This.nAnchorsImag(:,nPre+1:end);
                This.nWeightsReal = This.nWeightsReal(:,nPre+1:end);
                This.nWeightsImag = This.nWeightsImag(:,nPre+1:end);
                This.cAnchors = This.cAnchors(:,nPre+1:end);
                This.qAnchors = This.qAnchors(:,nPre+1:end);
            end
        end
        
        if ~isinf(NewRange(end))
            if NewRange(end) > This.endDate
                nPost = round(NewRange(end) - This.endDate);
                This.xAnchors = [This.xAnchors,false(nx,nPost)];
                This.nAnchorsReal = [This.nAnchorsReal,false(nNReal,nPost)];
                This.nAnchorsImag = [This.nAnchorsImag,false(nNImag,nPost)];
                This.nWeightsReal = [This.nWeightsReal,false(nNReal,nPost)];
                This.nWeightsImag = [This.nWeightsImag,false(nNImag,nPost)];
                This.cAnchors = [This.cAnchors,false(nc,nPost)];
                This.qAnchors = [This.qAnchors,false(nq,nPost)];
            elseif NewRange(end) < This.endDate
                nPost = round(This.endDate - NewRange(end));
                This.xAnchors = This.xAnchors(:,1:end-nPost);
                This.nAnchorsReal = This.nAnchorsReal(:,1:end-nPost);
                This.nAnchorsImag = This.nAnchorsImag(:,1:end-nPost);
                This.nWeightsReal = This.nWeightsReal(:,1:end-nPost);
                This.nWeightsImag = This.nWeightsImag(:,1:end-nPost);
                This.cAnchors = This.cAnchors(:,1:end-nPost);
                This.qAnchors = This.qAnchors(:,1:end-nPost);
            end
        end
        
    end % doChngRange().

end