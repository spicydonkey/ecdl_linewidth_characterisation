% read data from Rigol DSA815 spectrum analyser
% DK Shin
% 21/06/2016

function data = read_spec_data(filename)

nlines = numLine(filename);
nSamp = nlines-2;

DATA_CELL = cell(nlines,1);
fid = fopen(filename);
for iLine = 1:nlines
    DATA_CELL{iLine} = regexp(fgetl(fid),',','split');
end
fclose(fid);

data=zeros(nSamp,2);

for iSamp=1:nSamp
    data(iSamp,1)=str2double(DATA_CELL{iSamp+2}{1});
    data(iSamp,2)=str2double(DATA_CELL{iSamp+2}{3});
end