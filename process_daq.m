% Process trace data from DAQ
% Builds 2D array of freq-power trace data from data collected by
% 'run_daq_dsa815.m'
% 27/06/2016
% DK Shin

function [DATA, PARAMS] = process_daq(DAQ_FILE_NAME)
% DAQ_FILE includes vars: 'params','trace_data','CF','nShots'
load(DAQ_FILE_NAME);

% load spectrum analyser parameters: params=[RBW, VBW, SWT, SPAN]
PARAMS=params;
RBW = params(1);
VBW = params(2);
SWT = params(3);
SPAN = params(4);

DATA = cell(nShots,1);
for iShot=1:nShots
    % build freq array (x data)
    DATA{iShot}(:,1) = linspace(CF(iShot)-SPAN/2,CF(iShot)+SPAN/2,601);
    
    % get trace (y data)
    tmp_trace = trace_data{iShot};
    tmp_trace = strsplit(tmp_trace,',');
    for iTracePoint = 1:length(tmp_trace)
        DATA{iShot}(iTracePoint,2) = str2double(tmp_trace{iTracePoint});
    end
    
%     % monitor collected data
%     if mod(iShot,5)==0
%         figure();
%         plot(DATA{iShot}(:,1),DATA{iShot}(:,2),'b.');
%         grid on;
%     end
end