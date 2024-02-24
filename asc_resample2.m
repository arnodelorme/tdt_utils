% asc_resample2 - load ascii file and resample it. 
%
% Usage:
% >> asc_resample(filein, fileout, sratein, srateout);
%
% Input:
%   filein  - [string] input file in ASCII format. Channels must be
%             organised in columns. The header may be 1-3 rows. The
%             last row before the ASCII data may contain channel 
%             labels
%   fileout - [string] output file name.
%   sratein - [real] sampling rate of the first file (input file).
%   srateout - [real] sampling rate of the output file (fileout).
%
% Output:
%   res     - [-1|1] -1 is unsuccessful and 1 is successful
%
% 

function res = asc_resample2(filein, fileout, sratein, srateout);

res = -1;
if nargin < 1
   help asc_resample;
   return;
end;	
if isstr(sratein),  sratein  = str2num(sratein); end;
if isstr(srateout), srateout = str2num(srateout); end;

% find number of header lines
% ---------------------------
[chans headerlines nc, res] = asc_readheader(filein);
if res == -1, return; end;

% read data
% ---------
[tmpdata res] = asc_readdata(filein,headerlines,nc);
if res == -1, return; end;

% resample data
% -------------
tmpdata = resample(tmpdata, sratein, srateout);

% write data to file
% ------------------
res = asc_write( fileout, tmpdata, chans);
return;
   