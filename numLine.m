% Get number of lines in file
% 18/06/2016
% DK Shin

function nlines = numLine(filename)
fid = fopen(filename);

nlines = 0;
while ischar(fgetl(fid))
    nlines = nlines + 1;
end

fclose(fid);