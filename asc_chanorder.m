% asc_chanorder - load ascii file and change channel order.
%
% Usage:
% >> res = asc_chanorder(filein, fileout, chanorderoutfile, chanorderinfile);
%
% Input:
%   filein  - [string] input file in ASCII format. Channels must be
%             organised in columns. The header may be 1-3 rows. The
%             last row before the ASCII data may contain channel 
%             labels
%   fileout - [string] output file name.
%   chanorderoutfile - [string] file containing channel order for output
%                      file.
%   chanorderinfile - [string] file containing channel order for input file. 
%                     This file is optional if channel labels are defined
%                     in the input file.
% Output:
%   res     - [-1|1] -1 is unsuccessful and 1 is successful
%
% 

function res = asc_chanorder(filein, fileout, chanorderout, chanorderin);

res = -1;
if nargin < 1
   help asc_chanorder;
   return;
end;	

% find number of header lines
% ---------------------------
[chans headerlines nc, res] = asc_readheader(filein);
if res == -1, return; end;

% read data
% ---------
[tmpdata res] = asc_readdata(filein,headerlines,nc);
if res == -1, return; end;

% read channel order for both files
% ---------------------------------
if nargin > 3
    [chans] = asc_readheader(chanorderin);
    if length(chans) ~= nc
        disp('Not the same number of channel labels as number of column in data file');
        res = -1; 
        return;
    end;
end;
chansout = asc_readheader(chanorderout);

% reorder channels
% ----------------
[a b c]  = intersect(lower(chans), lower(chansout));
[tmp cc] = sort(c);
neworder = b(cc);
if length(neworder) < length(chans)
  %disp('Warning: some channels of the input file were not found in the file');
  %disp('         used for channel ordering. They have been placed at the end.');
end;
lastchans = setdiff(1:length(chans), neworder);
chans    = chans([ neworder lastchans ]);
tmpdata  = tmpdata([ neworder lastchans ],:);

% write data to file
% ------------------
res = asc_write( fileout, tmpdata, chans);
