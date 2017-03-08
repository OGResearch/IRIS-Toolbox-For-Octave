range = qq(2000,1):qq(2015,4);
d = struct();
d.x = hpf2(cumsum(tseries(range,@randn)));
d.y = hpf2(cumsum(tseries(range,@randn)));
d.z = hpf2(cumsum(tseries(range,@randn)));
d.a = hpf2(cumsum(tseries(range,@randn)));
d.b = hpf2(cumsum(tseries(range,@randn)));