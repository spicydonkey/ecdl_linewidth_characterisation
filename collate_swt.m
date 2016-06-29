% Sweep time (SWT) vs linewidth
% Collate average linewidth and corresponding sweep time

lib_data = 'C:\Users\HE BEC\Dropbox\PhD\lab\ecdl\characterisation\linewidth\280616';


%% main
dir_list = genpath(lib_data);

% initialise sweeptime and linewidth array
swt_list = [];
lw_list = [];
sd_list = [];

% search lib_data sub/directory
while ~isequal(dir_list,';')
    [this_dir,dir_list]=strtok(dir_list,';');
    file_list = dir(this_dir);
    cd(this_dir);   % move into subdirectory
    for iFile=1:length(file_list)
        this_file = file_list(iFile).name;
        if length(this_file)>12
            if isequal(this_file(3:end),'analysis.mat')
                load(this_file,'params','LW_AVG','LW_SD');
                % update list
                swt_list = [swt_list, params(3)];
                lw_list = [lw_list, LW_AVG];
                sd_list = [sd_list, LW_SD];
            end
        end
    end
    cd ..   % move back to parent directory
end

cd(lib_data);

% plot and save result
figure();
errorbar(swt_list,lw_list(1,:),sd_list(1,:),'b^');
hold on;
errorbar(swt_list,lw_list(2,:),sd_list(2,:),'r^');
set(gca,'XScale','log');
grid on;
xlim([5e-3,2e1]);
ylim([0,350e3]);
title('Sweep time of spectrum analyser vs. laser linewidth');
xlabel('sweep time (s)');
ylabel('linewidth (Hz)');
legend('Gaussian','Lorentzian');
saveas(gcf,'swt_linewidth.png');