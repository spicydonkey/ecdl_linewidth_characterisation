% Script to perform statistical analysis on analysed linewidth data

%% path to code and data
lib_script = 'C:\Users\HE BEC\Dropbox\PhD\lab\ecdl\characterisation\linewidth\code';

% directory of directories with the analysis data '<exp_number>_analysis.mat'
lib_data = 'C:\Users\HE BEC\Dropbox\PhD\lab\ecdl\characterisation\linewidth\280616';

addpath(genpath(lib_script));
addpath(genpath(lib_data));

%% main
dir_list = genpath(lib_data);

% search lib_data sub/directory
while ~isequal(dir_list,';')
    [this_dir,dir_list]=strtok(dir_list,';');
    file_list = dir(this_dir);
    cd(this_dir);   % move into subdirectory
    for iFile=1:length(file_list)
        this_file = file_list(iFile).name;
        if length(this_file)>12
            if isequal(this_file(3:end),'analysis.mat')
                % do the statstics on the analysis file
                CalcAvgLW(this_file);
            end
        end
    end
    cd ..   % move back to parent directory
end