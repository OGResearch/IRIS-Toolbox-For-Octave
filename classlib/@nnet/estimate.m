function Obj = estimate(This,Data,Range,varargin)

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

pp = inputParser() ;
pp.addRequired('This',@(x) isa(x,'nnet')) ;
pp.addRequired('Data',@isstruct) ;
pp.addRequired('Range',@(x) isnumeric(x) && isvector(x)) ;
pp.parse(This,Data,Range) ;
if This.nAlt>1
    utils.error('nnet:estimate',...
        'Estimate does not support input neural network objects with multiple parameterizations.') ;
end

% Parse options
options = passvalopt('nnet.estimate',varargin{:}) ;

% Get data
[InData,OutData] = datarequest('Inputs,Outputs',This,Data,Range) ;

% Test objective function
Obj = objfunc(This,InData,OutData,Range,options) ;

disp(Obj) ;

end

