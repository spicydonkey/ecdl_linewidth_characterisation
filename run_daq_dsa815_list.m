% DAQ environment for Rigol DSA815
% DK Shin
% 24/06/2016

%% Preset
PARAM_LIST = [100e3 100e3 4.64 10e6;
    100e3 100e3 10 15e6;
    300e3 300e3 21.5 20e6;
    300e3 300e3 46.4 20e6];


%% File management
clc;
dir_name = input('Enter a new directory name: ','s');
mkdir(dir_name);
cd(dir_name);

%% DAQ
clc;

% DAQ parameters
nShots = 100;     	% number of traces to save
waittime = 0.3;
k_pass = 0.15;		% max amount of shift in peak from center to pass

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

for iParam=1:length(PARAM_LIST)
    params = PARAM_LIST(iParam,:);
    
    % autosearch peak
    fprintf(vObj,':SENSe:POWer:ATUNe');
    pause(5);   % wait until autosearch completes
    
    % Set spectrum analyser params to user input: params=[RBW, VBW, SWT, SPAN]
    fprintf(vObj,[':SENSe:BANDwidth:RESolution ', num2str(params(1))]);
    fprintf(vObj,[':SENSe:BANDwidth:video ', num2str(params(2))]);
    fprintf(vObj,[':SENSe:SWEep:TIME ', num2str(params(3))]);
    fprintf(vObj,[':SENSe:FREQuency:SPAN ', num2str(params(4))]);
    
    % Get spectrum analyser param settings (may be different to user input)
    fprintf(vObj,':SENSe:BANDwidth:RESolution?');
    params(1)=fscanf(vObj,'%d');
    fprintf(vObj,':SENSe:BANDwidth:Video?');
    params(2)=fscanf(vObj,'%d');
    fprintf(vObj,':SENSe:SWEep:TIME?');
    params(3)=fscanf(vObj,'%f');
    fprintf(vObj,':SENSe:FREQuency:SPAN?');
    params(4)=fscanf(vObj,'%d');
    
	fprintf(vObj,':CALCulate:MARKer1:CPEak:STATe ON');	% enable cont peak search on Mkr1
    fprintf(vObj,':CALCulate:MARKer1:PEAK:SET:CF');     % re-center spectrum
    
    % Take spectrum data
    trace_data = cell(nShots,1);
    CF = zeros(nShots,1);
    fprintf(vObj,':INITiate:CONTinuous OFF');
	
	% take spectrum measurement until 'nShots' centered shots are acquired
	iShot = 1;
    while iShot<n+1
        % run a single shot
        fprintf(vObj,':INITiate:IMMediate');
        pause(params(3)+waittime);   % wait until sweep ends
		
		% check if peak is well captured
		fprintf(vObj,':SENSe:FREQuency:CENTer?');	% center frequency
		CF_temp = fscanf(vObj,'%d');
		fprintf(vObj,':CALCulate:MARKer1:X?');		% peak frequency
		PF_temp=fscanf(vObj,'%d');
		
		if abs(PF_temp-CF_temp)<k_pass*params(4)
			% get trace amplitude
			fprintf(vObj,':TRACe:DATA? TRACE1');
			fscanf(vObj,'%c',1);
			nheader=fscanf(vObj,'%c',1);
			fscanf(vObj,'%c',str2num(nheader));
			trace_data{iShot} = fscanf(vObj);
			
			% get freq data: CF
			CF(iShot) = CF_temp;
			
			iShot=iShot+1;
        end
		
		% update CF of scan to this shot's peak frequency (accounts for beatnote drifting out of scan range)
        fprintf(vObj,':CALCulate:MARKer1:PEAK:SET:CF');
    end
    
    % Save data
    save(num2str(iParam),'params','trace_data','CF','nShots');
end

fclose(vObj);   % close communication with instrument
cd ..