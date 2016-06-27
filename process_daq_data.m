% Process trace data from DAQ

data_file = '1.mat';

load(data_file);

% load spectrum analyser parameters: params=[RBW, VBW, SWT, SPAN]
RBW = params(1);
VBW = params(2);
SWT = params(3);
SPAN = params(4);

data = cell(nShots,1);
for iShot=1:nShots
    % build freq array (x data)
    data{iShot}(:,1) = linspace(CF(iShot)-SPAN/2,CF(iShot)+SPAN/2,601);
    
    % get trace (y data)
    tmp_trace = trace_data{iShot};
    tmp_trace = strsplit(tmp_trace,',');
    for iTracePoint = 1:length(tmp_trace)
        data{iShot}(iTracePoint,2) = str2double(tmp_trace{iTracePoint});
    end
    
    % monitor collected data
    if mod(iShot,5)==0
        figure();
        plot(data{iShot}(:,1),data{iShot}(:,2),'b.');
        grid on;
    end
end