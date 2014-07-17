function Outp = datarequest(Req,This,Data,Range,Opt)
% datarequest  [Not a public function] Request input data.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    Opt; %#ok<VUNUS>
catch %#ok<CTCH>
    Opt = struct();
end

%--------------------------------------------------------------------------

retX = ~isempty(strfind(Req,'x'));
mustX = ~isempty(strfind(Req,'x*'));
retI = ~isempty(strfind(Req,'i'));
mustI = ~isempty(strfind(Req,'i*'));

X = [];
I = [];

Outp = datarequest@varobj(Req,This,Data,Range,Opt);

Range = Outp.Range;

if isempty(Data)
    Data = struct();
end

if isstruct(Data)
    doDbase();
end

% Transpose and return data.
if retX
    Outp.X = permute(X,[2,1,3]);
end
if retI
    Outp.I = permute(I,[2,1,3]);
end


% Nested functions...


%**************************************************************************

    
    function doDbase()        
        sw = struct();
        sw.Warn.SizeMismatch = true;
        sw.Warn.FreqMismatch = true;
        sw.Warn.NoRangeFound = true;
        sw.LagOrLead = [];
        sw.IxLog = [];
        sw.BaseYear = This.BaseYear;
        
        if retX && ~isempty(This.XNames)
            sw.Warn.NotFound = mustX;
            sw.Warn.NonTseries = mustX;
            X = db2array(Data,Range,This.XNames,sw);
        end
        
        if retI && ~isempty(This.INames)
            sw.Warn.NotFound = mustI;
            sw.Warn.NonTseries = mustI;
            I = db2array(Data,Range,This.INames,sw);
        end
    end % doDbase()


end