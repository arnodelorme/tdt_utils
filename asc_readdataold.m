% asc_readdata - load ascii file.
%
% Usage:
% >> [data res] = asc_readdata(filein, headerlines, nc);
%
% Input:
%   filein  - [string] input file in ASCII format. Channels must be
%             organised in columns. The last row before the ASCII 
%             data may contain channel labels
%   headerlines - [integer] number of lines in header
%   colnumber   - [integer] number of columns in file
%   rownumber   - [integer] number of rows to read (optional)
%
% Output:
%   data    - [real] chans x points data array
%   res     - [-1|1] -1 is unsuccessful and 1 is successful
%
% 

function [tmpdata, res] = asc_readdata(filein, headerlines, nc, nl);

res = -1;
if nargin < 1
   help asc_readdata;
   return;
end;	
if nargin < 4
    nl = Inf;
end;

% read data
% ---------
fid = fopen(filein, 'r');
if fid == -1, disp(['Cannot open input file ' filein ]); res = -1; end;
for index = 1:headerlines
    tmpl = fgetl(fid);
end;
tmpdata = fscanf(fid, '%f', [nc nl]);
fclose(fid);
res = 1;
