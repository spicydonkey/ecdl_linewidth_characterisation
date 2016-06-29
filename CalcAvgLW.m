% statistical analysis on fitted linewidths
% data file should contain cell of individually fitted linewidths {[FWHM, SD]}
function [LW_AVG, LW_SD] = CalcAvgLW(DATANAME)
load(DATANAME);

n_data = size(linewidth,1);

% get FWHM of Gaussian and constrained Lorentzian
lw_array = zeros(n_data,2);
for i=1:n_data
    lw_array(i,:) = [linewidth{i}(1,1), linewidth{i}(3,1)];
end

% summary of linewidth statistics
LW_AVG = mean(lw_array,1)';
LW_SD = std(lw_array,1)';

% save results to original analysis data file
save(DATANAME,'LW_AVG','LW_SD','lw_array','-append');

% display individual linewidth
figure(); 
plot(lw_array(:,1),'b*');
hold on; 
plot(lw_array(:,2),'r*');
title(['Linewidth measurement: ','SWT=',num2str(params(3),3)]);
xlabel('Observation number');
ylabel('FWHM linewidth (Hz)');
legend(['Gaussian: ',num2str(LW_AVG(1),3),'(',num2str(LW_SD(1),3),')'],['Lorentzian: ',num2str(LW_AVG(2),3),'(',num2str(LW_SD(2),3),')']);
saveas(gcf,[strtok(DATANAME,'.'),'.png']);
close(gcf);