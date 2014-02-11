function OutData = sstate(This,InData,Range,varargin)

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if nargin<3
    Range = Inf ;
end
if ischar(Range)
    varargin = [Range, varargin] ;
    Range = Inf ;
end
pp = inputParser() ;
pp.addRequired('This',@(x) isa(x,'nnet')) ;
pp.addRequired('Data',@(x) isa(x,'tseries') || isa(x,'struct')) ;
pp.addOptional('Range',@(x) isnumeric(x) && isvector(x)) ;
pp.parse(This,InData,Range) ;
if This.nAlt>1
    utils.error('nnet:sstate',...
        'Sstate does not support input neural network objects with multiple parameterizations.') ;
end
Range = myrange(This,InData,Range) ;

% Parse options
options = passvalopt('nnet.sstate',varargin{:}) ;

% Handle data
if isstruct(InData)
    [InData] = datarequest('Inputs',This,InData,Range) ;
end

if mysameio(This)
    utils.error('nnet:sstate','Input and output variables must be the same.') ;
end

% Body
nObs = size(InData,1) ;
OutData = InData ;
for iObs = 1:nObs
    crit = Inf ;
    it = 0 ;
    while ( crit>options.tolerance ) && ( it<options.maxit )
        it = it+1 ;
        last = OutData(iObs,:) ;
        OutData(iObs,:) = eval(This,OutData(iObs,:),Range) ;
        crit = max(abs(OutData(iObs,:)-last)) ;
    end
end

% Output
if strcmpi(options.Output,'dbase')
	OutData = array2db(OutData,Range,This.Outputs) ;
end

end


















