function rep = beginprintout(rep,varargin)

warning('iris:obsolete','BEGINPRINTOUT is an obsolete function. Start report with REPORT.');
rep = report(varargin{:});

end