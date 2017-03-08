a = tseries(dd(1,1,1),1) ;
b = tseries(qq(2,2),2) ;

try
    [a,b];
catch err
    if isempty(strfind(err.message,'tseries/horzcat method failed'))
        rethrow(err);
    end
end


try
    [a;b];
catch err
    if isempty(strfind(err.message,'tseries/vertcat method failed'))
        rethrow(err);
    end
end

