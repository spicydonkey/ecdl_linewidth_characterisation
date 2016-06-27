subdata=[data(1:300,:);data(350:600,:)];
xdata=subdata(:,1);
liny=10.^(subdata(:,2)/10);
semilogy(xdata,liny);


gamma=100*10^-3;
amp=1*10^13;
x0=3.038*10^8;

fo = statset('TolFun',10^-30,...
    'TolX',10^-30,...
    'MaxIter',10^7,...
    'UseParallel',1);
fitobject=fitnlm(xdata,liny,...
    'y~amp*(1/(3.141592653*gamma))*((gamma^2)/((x1-x0)^2+gamma^2))',...
    [amp,gamma,x0],...
    'CoefficientNames',{'amp','gamma','x0'},'Options',fo);
xvalues=linspace(min(xdata),max(xdata),300);
hold on
semilogy(xvalues,feval(fitobject,xvalues),'r')
%legend('data','fit')
hold off
fitobject.Coefficients.Estimate
fit_params=[fitobject.Coefficients.Estimate,fitobject.Coefficients.SE];
