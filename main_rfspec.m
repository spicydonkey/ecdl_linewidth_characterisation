% Script to read and plot data from spectrum analyser
% DK Shin
% 20/06/2016

clear all; close all;

lib_script = 'C:\Users\HE BEC\Dropbox\PhD\lab\ecdl\characterisation\linewidth\code';
lib_data = 'C:\Users\HE BEC\Dropbox\PhD\lab\ecdl\characterisation\linewidth\todo';

addpath(genpath(lib_script));
addpath(genpath(lib_data));

dir_list = genpath(lib_data);

while ~isequal(dir_list,';')
    [this_dir,dir_list]=strtok(dir_list,';');
    file_list = dir(this_dir);
    cd(this_dir);
    for iFile=1:length(file_list)
        this_file = file_list(iFile).name;
        [file_id,file_type] = strtok(this_file,'.');
        if isequal(file_type,'.csv')
            data = read_spec_data(this_file);
            % display and save plot
            figure();
            plot(data(:,1),data(:,2));
            grid on;
            saveas(gcf,[file_id,'.png']);   % original spectrum
            close(gcf);
            save([file_id,'.mat'],'data');  % original data
            
            % analyse the spectrum
            run_lw_calc
            
            saveas(gcf,[file_id,'_fit.png']);
            close(gcf);
            save([file_id,'_fit.mat'],'data','linewidth');
        
        elseif isequal(file_type,'.mat')
            % check if VISA DAQ run
            tmp_struct=load(this_file,'nShots');
            if isfield(tmp_struct,'nShots');
                % file is from DAQ run if nShots exist
                load(this_file);
                
                %%% pre-process data
                [data, params] = process_daq(this_file);
                
                %%% do the analysis on data
                dir_analysis = [file_id,'_analysis'];
                mkdir(dir_analysis);    % make separate directory to store individual shot figures
                cd(dir_analysis);
                linewidth=cell(nShots,1);
                for iShot=1:nShots
                    linewidth{iShot} = fit_linewidth(data{iShot});
                    % save figure and data
                    saveas(gcf,[file_id,'_',num2str(iShot),'_fit.png']);
                    close(gcf);
                end
                cd ..   % move back to parent directory
                
                % save data
                %TODO: return 'fit' results summary all fit params
                save([file_id,'_analysis.mat'],'data','params','linewidth');
            end
        end
    end
    cd ..
end