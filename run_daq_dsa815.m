% DAQ environment for Rigol DSA815
% DK Shin
% 24/06/2016

%% Preset
PARAM_LIST = [100e3 100e3 4.64 10e6;
    100e3 100e3 10 15e6;
    300e3 300e3 21.5 20e6;
    300e3 300e3 46.4 20e6;
];


%% File management
clc;
dir_name = input('Enter a new directory name: ','s');
mkdir(dir_name);
cd(dir_name);

%% DAQ
clc

% DAQ parameters
nShots = 100;     % number of traces to save
waittime = 0.1;

% Connect to instrument
vhwinfo = instrhwinfo('visa','ni');
disp('Available VISA resources:\n');
disp(vhwinfo.ObjectConstructorName);    % display available objects
rsrcname = input('Enter full instrument resource name\n(Example: USB0::0x1AB1::0x0960::DSA8A151700974::INSTR )\n','s');
%resrcname='USB0::0x1AB1::0x0960::DSA8A151700974::INSTR';
vObj = visa('ni',rsrcname);     % create visa object
vObj.InputBufferSize = 20000;   % increase input buff size from default

fopen(vObj);    % open communication with instrument

fprintf(vObj,':CALibration:AUTO OFF');  % turn auto-calib off

loop_count=1;
while 1    
    %TODO: read spec analyser param setting from file
    
    params = input('\n[RBW(Hz) VBW(Hz) SWT(S) SPAN(Hz)]? (-1 to quit)\n');
    if params==-1
        if 'Y'==input('Sure? (Y/N): ','s')
            break
        end
    end
    
    % input error check
    if length(params)~=4
        disp('ERROR: check input\n');
        
        continue
    end
    
    % Get spectrum analyser settings: params=[RBW, VBW, SWT, SPAN]
    RBW = params(1);
    VBW = params(2);
    SWT = params(3);
    SPAN = params(4);
    
    % autosearch peak first
    fprintf(vObj,':SENSe:POWer:ATUNe');
    pause(5);   % wait until autosearch completes
    
    % Set spectrum analyser params to user input
    fprintf(vObj,[':SENSe:BANDwidth:RESolution ', num2str(RBW)]);
    fprintf(vObj,[':SENSe:BANDwidth:video ', num2str(VBW)]);
    fprintf(vObj,[':SENSe:SWEep:TIME ', num2str(SWT)]);
    fprintf(vObj,[':SENSe:FREQuency:SPAN ', num2str(SPAN)]);
    
    % Get spectrum analyser param settings (may be different to user input)
    fprintf(vObj,':SENSe:BANDwidth:RESolution?');
    params(1)=fscanf(vObj,'%d');
    fprintf(vObj,':SENSe:BANDwidth:Video?');
    params(2)=fscanf(vObj,'%d');
    fprintf(vObj,':SENSe:SWEep:TIME?');
    params(3)=fscanf(vObj,'%f');
    fprintf(vObj,':SENSe:FREQuency:SPAN?');
    params(4)=fscanf(vObj,'%d');
    
    pause(SWT+waittime);
    fprintf(vObj,':CALCulate:MARKer1:PEAK:SET:CF');     % re-center spectrum
    
    % Take spectrum data
    trace_data = cell(nShots,1);
    CF = zeros(nShots,1);
    fprintf(vObj,':INITiate:CONTinuous OFF');
    for iShot=1:nShots
        % run a single shot
        fprintf(vObj,':INITiate:IMMediate');
        pause(SWT+waittime);   % wait until sweep ends
        
        % get trace amplitude
        fprintf(vObj,':TRACe:DATA? TRACE1');
        fscanf(vObj,'%c',1);
        nheader=fscanf(vObj,'%c',1);
        fscanf(vObj,'%c',str2num(nheader));
        trace_data{iShot} = fscanf(vObj);
        
        % get freq data: CF
        fprintf(vObj,':SENSe:FREQuency:CENTer?');
        CF(iShot) = fscanf(vObj,'%d');
        
        % get current spectrum and shift peak to CF
%         fprintf(vObj,':INITiate:IMMediate');
%         pause(SWT+waittime);
        fprintf(vObj,':CALCulate:MARKer1:PEAK:SET:CF');
    end
    
    % Save data
    save(num2str(loop_count),'params','trace_data','CF','nShots');
    loop_count = loop_count + 1;
end

fclose(vObj);   % close communication
cd ..