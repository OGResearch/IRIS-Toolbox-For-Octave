function testme()

myfunc = '-sin(x) +2*cos(x)/log(x)'; %'- (sin(x) - 1/(cos(x)*log(sqrt(x))))';

delete myfunc.m;
c = sprintf('function y = myfunc(x)\ny = %s;\nend',myfunc);
char2file(c,'myfunc.m');
rehash();

eq = 'x^2 + 2*sqrt(x + y) / (x + z*pi())^3 - 1/log(z + x) + z^y + normpdf(x)';

s = sym([eq,myfunc]);
sx = char(diff(s,'x'));
sx = regexprep(sx,'\s','');
sx = strrep(sx,'diff(normpdf(x),x)','sydney.d(''normpdf'',1,x)');
sy = char(diff(s,'y'));
sz = char(diff(s,'z'));

a = sydney([eq,'+myfunc(x)']);
da = diff(a,'x,y,z',1);
da = char(da);

sx = str2func(['@(x,y,z)',sx]);
sy = str2func(['@(x,y,z)',sy]);
sz = str2func(['@(x,y,z)',sz]);

da = str2func(['@(x,y,z)',da]);

m = [];
for i = 1 : 1000
    x = mean(rand(1,10)); % Make sure x is around 0.5 so that normpdf behaves well.
    y = rand();
    z = rand();
    eval1 = [sx(x,y,z);sy(x,y,z);sz(x,y,z)];
    eval2 = da(x,y,z);
    mi = maxabs(eval1./eval2 - 1);
    if isempty(m) || mi > m(1)
        m = [mi,x,y,z,eval1.',eval2.'];
    end
end

disp(m(1));

end