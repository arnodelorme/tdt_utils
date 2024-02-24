% asc_write - write EEG data to ascii file.
%
% Usage:
% >> res = asc_write(fileout, data, chans, precision);
%
% Input:
%   fileout - [string] output file in ASCII format. Channels must be
%             organised in columns. The header may be 1-3 rows. The
%             last row before the ASCII data may contain channel 
%             labels
%   data    - [real] nb_chans x nb_point data file
%   chans   - [cell] cell array of channel labels. Default is none.
%   precision - [integer] number of decimals. Default is 0.
%
% Output:
%   res     - [-1|1] -1 is unsuccessful and 1 is successful
%
% 

function [res]= asc_write(fileout, tmpdata, chans, precision);

if nargin < 2
    help asc_write;
    return;
end;
if nargin < 3
    chans = {};
end;
if nargin < 4
    precision = 4;
end;

res = -1;
fid = fopen(fileout, 'w');
if fid == -1, disp(['Cannot open output file ' fileout ]); return; end;
for index = 1:length(chans)
   fprintf(fid, '%s\t', chans{index});
end;	
if ~isempty(chans) fprintf(fid, '\n'); end;
for index = 1:size(tmpdata,2)
   fprintf(fid, [ '%.' int2str(precision) 'f\t' ], tmpdata(:,index)');
   fprintf(fid, '\n');
end;	
fclose(fid);
res = 1;
