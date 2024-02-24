% asc_rmheader - load EEG ascii file and remove header.
%
% Usage:
% >> res = asc_rmheader(filein, fileout);
%
% Input:
%   filein  - [string] input file in ASCII format. Channels must be
%             organised in columns. The header may be 1-3 rows. The
%             last row before the ASCII data may contain channel 
%             labels
%   fileout - [string] output file name.
%
% Output:
%   res     - [-1|1] -1 is unsuccessful and 1 is successful
%
% 

function res = asc_rmheader(filein, fileout);

res = -1;
if nargin < 1
   help asc_rmheader;
   return;
end;	

[chans headerlines nc res] = asc_readheader(filein);
if res == -1, return; end;

% read data
% ---------
[tmpdata res] = asc_readdata(filein,headerlines,nc);
if res == -1, return; end;

% write data to file
% ------------------
res = asc_write( fileout, tmpdata, {});
