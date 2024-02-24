% asc_rescale - load ascii file and rescale it. 
%
% Usage:
% >> res = asc_rescale(filein, fileout, scalefact);
%
% Input:
%   filein  - [string] input file in ASCII format. Channels must be
%             organised in columns. The header may be 1-3 rows. The
%             last row before the ASCII data may contain channel 
%             labels
%   fileout - [string] output file name.
%   scalefact  - [real] multiplicative factor
%
% Output:
%   res     - [-1|1] -1 is unsuccessful and 1 is successful
%
% 

function res = asc_rescale(filein, fileout, scalefact);

res = -1;
if nargin < 1
    
   [filein filepathin] = uigetfile('*.asc');
   if filein(1) == 0, return; end;
   filein = fullfile(filepathin, filein);
   
   [fileout filepathout] = uiputfile('*.asc');
   if fileout(1) == 0, return; end;
   fileout = fullfile(filepathout, fileout);
       
   scalefact = inputdlg('Enter scaling factor to multiply data with', 'Data rescaling function',1);
   scalefact = str2num(scalefact{1});
   if isempty(scalefact),
       f = warndlg('Operation canceled');
       return;
   end;
   drawnow;
end;	
if isstr(scalefact), scalefact = str2num(scalefact); end;

% find number of header lines
% ---------------------------
[chans headerlines nc, res] = asc_readheader(filein);
if res == -1, return; end;

% read data
% ---------
[tmpdata res] = asc_readdata(filein,headerlines,nc);
if res == -1, return; end;

% rescale data
% -------------
tmpdata = tmpdata*scalefact;

% write data to file
% ------------------
res = asc_write( fileout, tmpdata, chans);
if nargin < 1
    f = warndlg('Rescaling done', 'Data rescaling function');
end;
return;
   
