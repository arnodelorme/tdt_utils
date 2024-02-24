% bin_ascexport - load EEG binary file and export to ASCII.
%
% Usage:
% >> res = bin_ascexport(filein, fileout, channb, transp);
%
% Input:
%   filein  - [string] input file in binary format (16 bits).
%   fileout - [string] output ASCII file name.
%   channb  - [integer] number of channel number
%   rowformat - [0|1] read in row format instead of column. Default is 0 (no).
%
% Output:
%   res     - [-1|1] -1 is unsuccessful and 1 is successful
%
% 

function res = bin_ascexport(filein, fileout, channb, transp);

res = -1;
if nargin < 3
   help bin_ascexport;
   return;
end;	
if nargin < 4, transp = 0; end;
if isstr(channb), channb = str2num(channb); end;
if isstr(transp), transp = str2num(transp); end;

% read data
% ---------
fid = fopen(filein, 'r');
if fid == -1, disp(['Cannot open input file ' filein ]); res = -1; return; end;
tmpdata = fread(fid, [channb Inf], 'bit16');
if transp, tmpdata = reshape(tmpdata, size(tmpdata,2), size(tmpdata,1))'; end;
fclose(fid);
res = 1;

% write data to file
% ------------------
res = asc_write( fileout, tmpdata, {}, 0);
