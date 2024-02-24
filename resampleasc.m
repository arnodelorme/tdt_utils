% resampleasc - load ascii file and resample it. Ouput channels in
%               specific order as an option.
%
% Usage:
% >> resampleasc(filein, fileout, sratein, srateout, chanorderfile);
%
% Input:
%   filein  - [string] input file in ASCII format. Channels must be
%             organised in columns. The header may be 1-3 rows. The
%             last row before the ASCII data may contain channel 
%             labels
%   fileout - [string] output file name.
%   sratein - [real] sampling rate of the first file (input file).
%   srateout - [real] sampling rate of the output file (fileout).
%   lowedge  - [real] lower edge of the passband. Put 0 for none.
%   highedge - [real] higher edge of the passband. Put 0 for none.
%   chanorderfile - [string] file containing channel order. File
%                   should only contain channel labels.

function res = resampleasc(filein, fileout, sratein, srateout, highpass, lowpass, filechan);

res = -1;
if nargin < 1
   help resampleasc;
   return;
end;	
if isstr(sratein),  sratein  = str2num(sratein); end;
if isstr(srateout), srateout = str2num(srateout); end;
chanlist = { 'fp1' 'fp2' 'f7' 'f8' 'f3' 'f4' 't3' 't4' 'c3' 'c4' 't5' 't6' 'p3' 'p4' 'o1' 'o2' 'fz' 'cz' 'pz' 'eog' };

% find number of header lines
% ---------------------------
fid = fopen(filein, 'r');
if fid == -1, error(['Cannot open input file ' filein ]); end;
cont = 1;
count = 0;
warning off;
while cont
   tmpl = fgetl(fid);
   firstelem = strtok(tmpl);
   if ~isempty(str2num(firstelem))
      cont = 0;
   end;
   count = count+1;
end;
warning on;
firstdataline = tmpl;
fclose(fid);

% read new channel order
% ----------------------
chansout = {};
if nargin > 6
	fid = fopen(filechan, 'r');
   if fid == -1, error(['Cannot open input file ' filechan ]); end;
   index = 1;
	while ~feof(fid)
      chansout{index} = fscanf(fid, '%s', 1);
      index = index+1;
	end;
   fclose(fid);
   if isempty(chansout{end}), chansout(end) = []; end;
end;

% skip header, read channel labels
% --------------------------------
fid  = fopen(filein, 'r');
tmpl = [];
for index = 1:count-1
   tmpl = fgetl(fid);
end;
chans = {};
index = 1;
while ~isempty(tmpl)
   [chans{index} tmpl] = strtok(tmpl);
   index = index+1;
end;	

% remove quotes from channel labels
% ---------------------------------
for index = 1:length(chans)
   if ~isempty(chans{index})
      chans{index}(find(chans{index} == '"')) = [];
   end;
end;

% remove minus sign (reference Fz-A1A2)
% -------------------------------------
if ~isempty(chans)
    for index = 1:length(chans)
        minusind = find( chans{index} == '-' );
        if ~isempty(minusind),
            chans{index} = chans{index}(1:minusind-1);
        end;
    end;
end;

% are these channel labels?
% -------------------------
if ~isempty(chans)
   if isempty(strmatch(lower(chans{1}), chanlist))
      chans = {};
   elseif isempty(chans{end}), chans(end) = []; 
   end;
end;

% find numnber of columns in data
% -------------------------------
nc = length(sscanf(firstdataline, '%f'));
if ~isempty(chans)
   if nc ~= length(chans)
      error('Number of channel lalels different from number of data points');
   end;
end;

% read data
% ---------
tmpdata = fscanf(fid, '%f', [nc Inf]);

% resample data
% -------------
if lowpass == 0, lowpass = srateout/2;
else             lowpass = min(lowpass, srateout/2);
end;
tmpdata = antialias( tmpdata, sratein, highpass, lowpass);
tmpdata = myresample(tmpdata, sratein, srateout);

% reorder channels
% ----------------
if ~isempty(chansout)
    
    % remove 
    
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
end;

% write data to file
% ------------------
fid = fopen(fileout, 'w');
if fid == -1, error(['Cannot open output file ' fileout ]); end;
for index = 1:length(chans)
   fprintf(fid, '%s\t', chans{index});
end;	
if ~isempty(chans) fprintf(fid, '\n'); end;
for index = 1:size(tmpdata,2)
   fprintf(fid, '%f\t', tmpdata(:,index)');
   fprintf(fid, '\n');
end;	
fclose(fid);
res = 1;

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
   
