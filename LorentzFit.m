x=freq_2;
y=pwr_2;

% figure();
% semilogy(x,y,'ro'); hold on;
% grid on;

gamma=100;
amp=1e13;
x0=3.038*10^5;

fo = statset('TolFun',10^-60,...
    'TolX',10^-60,...
    'MaxIter',10^10,...
    'UseParallel',1);
fitobject=fitnlm(x,y,...
    'y~amp*(1/(3.141592653*gamma))*((gamma^2)/((x1-x0)^2+gamma^2))',...
    [amp,gamma,x0],...
    'CoefficientNames',{'amp','gamma','x0'},'Options',fo);
xvalues=linspace(min(x),max(x),300);

hold on;
semilogy(xvalues,feval(fitobject,xvalues),'k-')
%legend('data','fit')
hold off;
fitobject.Coefficients.Estimate
fit_params=[fitobject.Coefficients.Estimate,fitobject.Coefficients.SE];
