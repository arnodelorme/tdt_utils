% asc_filter - load ascii file and filter it.
%
% Usage:
% >> res = asc_filter(filein, fileout, sratein, lowedge, highedge);
%
% Input:
%   filein  - [string] input file in ASCII format. Channels must be
%             organised in columns. The header may be 1-3 rows. The
%             last row before the ASCII data may contain channel 
%             labels
%   fileout - [string] output file name.
%   sratein - [real] sampling rate of the first file (input file).
%   lowedge  - [real] lower edge of the passband. Put 0 for none.
%   highedge - [real] higher edge of the passband. Put 0 for none.
%
% Output:
%   res     - [-1|1] -1 is unsuccessful and 1 is successful
%
% 

function res = asc_filter(filein, fileout, sratein, highpass, lowpass);

res = -1;
if nargin < 1
   help asc_filter;
   return;
end;	
if isstr(sratein),  sratein  = str2num(sratein); end;
if isstr(highpass), highpass = str2num(highpass); end;
if isstr(lowpass),  lowpass  = str2num(lowpass); end;

% find number of header lines
% ---------------------------
[chans headerlines nc, res] = asc_readheader(filein);
if res == -1, return; end;

% read data
% ---------
[tmpdata res] = asc_readdata(filein,headerlines,nc);
if res == -1, return; end;

% filter data
% -------------
tmpdata = antialias( tmpdata, sratein, highpass, lowpass);

% write data to file
% ------------------
res = asc_write( fileout, tmpdata, chans);
return;

% anti-aliasing function
% ----------------------
function data = antialias(data, srate, lowcut, highcut);
    [nc epochframes] = size(data);
    fv=reshape([0:epochframes-1]*srate/epochframes,epochframes,1); % Frequency vector for plotting    
    if lowcut ~= 0
        [tmp idxl]=min(abs(fv-lowcut));  % Find the entry in fv closest to 5 kHz
    else
        idxl = 0;
    end;
    if highcut ~= 0        
        [tmp idxh]=min(abs(fv-highcut));  % Find the entry in fv closest to 5 kHz    
    else 
        idxh = length(fv)/2;
    end;
    for c=1:nc
        X=fft(data(c,:));
        X(1:idxl)=0;
        X(end-idxl:end)=0;
        X(idxh:end)=0;
        data(c,:) = 2*real(ifft(X));
    end
   