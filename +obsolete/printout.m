function rep = printout(varargin)

warning('iris:obsolete','PRINTOUT is an obsolete function. Use REPORT instead.');
rep = report(varargin{:});

end