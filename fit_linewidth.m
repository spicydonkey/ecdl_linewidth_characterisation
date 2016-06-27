% analyse beatnote spectrum for linewidth calculation
% modified from run_lw_calc.m
% 27/06/16
% DK Shin

function [LINEWIDTH] = fit_linewidth(data)
% <data> is a 2D array of frequency and power trace of a beatnote spectrum

freq = data(:,1);           % frequency in Hz
pwr_dBm = data(:,2);        % power in dBm
nSamp = length(freq);

[p_peak, ind_peak] = max(pwr_dBm);      % peak power
f_cent = freq(ind_peak);                % central frequency of peak power

% rescale frequency and power data
freq_shifted = freq - f_cent;   % peak centered frequency
pwr_lin = 10.^(pwr_dBm/10);     % power in mW

Df_cent = 0.5e6;      % width of central peak - Gaussian fitting region

% cull tails
Df_analyse = 2*Df_cent;     % width of tail - Lorentzian
ind_cull_start=1;
ind_cull_end=nSamp;

if Df_analyse < (freq(end)-freq(1))
    for iFreq = 1:length(freq)
        if freq_shifted(iFreq)>-Df_analyse/2
            ind_cull_start = iFreq;
            break
        end
    end
    for iFreq = 1:length(freq)
        if freq_shifted(length(freq)-iFreq+1)<Df_analyse/2
            ind_cull_end = length(freq)-iFreq+1;
            break
        end
    end
else
    Df_analyse = -1;
end

% get fitting regions: 1-central peak; 2-tail
ind_start=-1;
ind_end=-1;
for iFreq = 1:ind_peak
    if freq_shifted(iFreq)>(-Df_cent/2)
        ind_start = iFreq;
        break
    end
end
for iFreq = 1:(length(freq)-ind_peak+1)
    if freq_shifted(length(freq)-iFreq+1)<Df_cent/2
        ind_end = length(freq)-iFreq+1;
        break
    end
end

freq_1 = freq(ind_start:ind_end);
pwr_1 = pwr_lin(ind_start:ind_end);
freq_2 = [freq(ind_cull_start:ind_start-1); freq(ind_end+1:ind_cull_end)];
pwr_2 = [pwr_lin(ind_cull_start:ind_start-1); pwr_lin(ind_end+1:ind_cull_end)];


%% curve fitting
% Gaussian peak
fit_1 = fit(freq_1,pwr_1,'gauss1');

freq_fit_1 = linspace(min(freq_1),max(freq_1),1000);
pwr_fit_1 = feval(fit_1,freq_fit_1);        % Gaussian fitted values

% Lorentzian tail (no bound on parameters)
lorentz_f = 'y~amp/(1+((x1-x0)/gamma)^2)';  % Lorentzian
%'y~amp/(1+((x1-x0)/gamma)^2)'
%'y~amp*(gamma/3.14159265359)/((x1-x0)^2+gamma^2)'
%'y~amp*(1/(3.141592653*gamma))*((gamma^2)/((x1-x0)^2+gamma^2))'

% use parameters from gaussian fit as initial conditions
amp_0 = fit_1.a1;
gamma_0 = fit_1.c1;
x0_0 = fit_1.b1;
param0_2 = [amp_0,gamma_0,x0_0];

fopts_2 = statset('TolFun',1e-60,...
    'TolX',1e-60,...
    'MaxIter',1e6,...
    'UseParallel',1,...
    'Display','off');
fit_2 = fitnlm(freq_2,pwr_2,...
    lorentz_f,param0_2,...
    'CoefficientNames',{'amp','gamma','x0'},'Options',fopts_2);

freq_fit_2 = linspace(min(freq_2),max(freq_2),1000);
pwr_fit_2 = feval(fit_2,freq_fit_2);        % Lorentzian fitted values

% Lorentzian tail fit (bounded parameters)
param0_3=param0_2;      % same initial parameter set
bound=1+[1e-2,1e2,1e-6];    % bound parameter around initial estimate
LB=param0_3./bound;
UB=param0_3.*bound;
options = optimset('Display','off',...
    'MaxIter',1e6,...
    'TolFun',1e-60,...
    'TolX',1e-60,...
    'MaxFunEval',1e4,...
    'UseParallel',1);
[p_fit_3,resnorm,resid,exitflag,output,lambda,J] = lsqcurvefit(@lorentz,param0_3,freq_2,pwr_2,LB,UB,options);
freq_fit_3 = freq_fit_2;
pwr_fit_3 = lorentz(p_fit_3,freq_fit_3);    % bound Lorentzian fit val
p_fit_ci_3 = nlparci(p_fit_3,resid,'jacobian',J);


%% Lindwidth summary
% linewidth of beatnote in FWHM
lw1 = 1.6651*fit_1.c1;      % FWHM from the gaussian parameter 'c1'
lw1_sd = confint(fit_1);
lw1_sd = 1.6651*diff(lw1_sd(:,3))/(2*1.96);

lw2 = 2*fit_2.Coefficients.Estimate(2); % FWHM from lorentzian 'gamma'
lw2_sd = 2*fit_2.Coefficients.SE(2);

lw3 = 2*p_fit_3(2);     % FWHM from lorentzian 'gamma'
lw3_sd = 2*diff(p_fit_ci_3(2,:))/(2*1.96);

LINEWIDTH = [lw1 lw1_sd; lw2 lw2_sd; lw3 lw3_sd];


%% plot
% dBm plot
figure();

% Original data
plot(freq_1,10*log10(pwr_1),'bo');
hold on;
plot(freq_2,10*log10(pwr_2),'ro');

% Fit
plot(freq_fit_1,10*log10(pwr_fit_1),'k-');
plot(freq_fit_2,10*log10(pwr_fit_2),'k--');
plot(freq_fit_3,10*log10(pwr_fit_3),'k-.');

% Plot style
xlim auto;
ylim(10*log10([min(pwr_2)*1e-1 max(pwr_lin)*1e1]));
grid on;
title('Heterodyne beatnote spectrum');
xlabel('freq (Hz)');
ylabel('power (dBm)');

legend('data (peak)','data (tail)','Gaussian fit','Lorentzian fit (unbounded params)','Lorentzian fit (peak and centre bound)');
set(gcf, 'Position', get(0,'Screensize'));
pause(0.1);     %TODO: figure position doesn't update before saving to disk