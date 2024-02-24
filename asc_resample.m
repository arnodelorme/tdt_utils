% asc_resample - load ascii file and resample it. 
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

function res = asc_resample(filein, fileout, sratein, srateout);

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
tmpdata = antialias( tmpdata, sratein, 0, srateout/2);
tmpdata = myresample(tmpdata, sratein, srateout);

% write data to file
% ------------------
res = asc_write( fileout, tmpdata, chans);
return;

% resample if resample is not present
% -----------------------------------
function tmpeeglab = myresample(data, sratein, srateout);
   [pnts,new_pnts] = rat(sratein/srateout, 0.0001);
   X  = [1:size(data,2)];
   XX = linspace(1, size(data,2), ceil(size(data,2)*new_pnts/pnts));
   tmpeeglab = zeros(size(data,1), length(XX));
   for index1 = 1:size(data,1)
      cs = spline( X, squeeze(data(index1, :))');
      tmpeeglab(index1,:) = ppval(cs, XX);
		%fprintf('.');
   end;
   
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
   