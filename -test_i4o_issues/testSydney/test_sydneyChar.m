func = { ...
    'x*a*(y-z)*z/b*(-x*z/c/z*(x-c))', ...
    'x*a + b*y - c*z + a*(b*c - z*y)', ...
    'x/y/z/a/b/c * (-x/-y/-z/-a/-b) + a*b - z*y', ...
    'x + x*a - x*b + x*c - y + y*a - y*b + y*c', ...
    '-a/-b/-c/(-x*y*z)*b*c/a', ...
    '(a+0) + (b*1) - (c*-1) + x*y*z*1 - 0*a', ...
    'a^b *(c + 0*a) + x^(2*a - 0 + b*0)', ...
    '--+-++-+--x--+--+-+--y', ...
    };

nFunc = length(func);
actValue = nan(1,nFunc);
expValue = nan(1,nFunc);
for i = 1 : nFunc
    expFunc = eval(['@(a,b,c,x,y,z) ',func{i}]);
    actFunc = sydney(func{i},{});
    actFunc = reduce(actFunc);
    actFunc = char(actFunc);
    actFunc = eval(['@(a,b,c,x,y,z) ',actFunc]);
    a = 1 + rand*10;
    b = 1 + rand*10;
    c = 1 + rand*10;
    x = 1 + rand*10;
    y = 1 + rand*10;
    z = 1 + rand*10;
    expValue(i) = expFunc(a,b,c,x,y,z);
    actValue(i) = actFunc(a,b,c,x,y,z);
end

absTol = eps()^(2/3);
myassert(actValue, expValue, absTol);