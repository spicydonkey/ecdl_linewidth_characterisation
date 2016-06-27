x = freq_2;
y = pwr_2;

x0=3.038e5;
FWHM =10e3;
gamma=FWHM/2;
I=1e10;

P0=[x0 gamma I];

options = optimset('Display','iter','TolFun',1e-50,'MaxIter',1e6,'TolX',1e-10);
P = lsqcurvefit(@lorentz,P0,x,y,[],[],options);
% figure(); semilogy(x,y,'ro'); hold on; plot(x,Y,'bo')
% figure(); plot(x,y,'ro'); hold on; plot(x,Y,'bo');