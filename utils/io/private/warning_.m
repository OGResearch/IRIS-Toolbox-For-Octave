function warning_(code,list,varargin)

if ~iswarning('exim')
    return
end

switch code
    
    case 1
        msg = 'Cannot determine name for TSD series%s.';
        
    case 2
        msg = 'Cannot determine time range for TSD series%s.';
        
    case 3
        msg = 'Invalid frequency identifier(s) for TSD series%s.';
        
    case 4
        msg = 'Length of range does not match number of observations for for TSD series%s.';
        
end

if nargin == 1
    list = {};
end

utils.warning('io',msg,list{:});

end