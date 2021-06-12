function [tau_corr, val] = func_calc_delay(XA, XB, fc)
% вычисляет задержку XB относительно XA
fs = 50e6;
fsys = 200e6;
fcfsys = fc / fsys;
FRAC = 20;

f_countA = XA(1);
f_countB = XB(1);
tau_countA = (7-XA(2)) * 2.5;
tau_countB = (7-XB(2)) * 2.5;
YA = XA(3:2:end) + 1j*XA(4:2:end);
YB = XB(3:2:end) + 1j*XB(4:2:end);

f_getA = f_countA * fcfsys;
f_getB = f_countB * fcfsys;
df = f_getA - f_getB;

fsA = f_countA / 4;
fsB = f_countB / 4;

NA = round(length(YA)*FRAC*fs/fsA);
NB = round(length(YB)*FRAC*fs/fsB);

YA = interpft(YA, NA);
YB = interpft(YB, NB);

YA = YA .* exp(-1j*2*pi*df/(fs*FRAC)*(0:(NA-1)))';

if (fsB > fsA)
    Z = abs(xcorr(YB,YA)/norm(YA)/norm(YB));
    [val,idx] = max(Z);
    tau = 1e9*(idx-NA)/fs/FRAC;
    tau_corr = tau - tau_countA + tau_countB;
else
    Z = abs(xcorr(YA,YB)/norm(YA)/norm(YB));
    [val,idx] = max(Z);
    tau = 1e9*(idx-NB)/fs/FRAC;
    tau_corr = -(tau - tau_countB + tau_countA);
end

end
