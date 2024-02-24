% asc_readheader - load EEG ascii file header.
%
% Usage:
% >> [chans, headerlines, colnumber] = asc_readheader(filein);
%
% Input:
%   filein  - [string] input file in ASCII format. Channels must be
%             organised in columns. The header may be 1-3 rows. The
%             last row before the ASCII data may contain channel 
%             labels
%
% Output:
%   chans       - [cell] cell array of channel labels
%   headerlines - [integer] number of lines in header
%   colnumber   - [integer] number of columns in file (if any)
%
% 

function [chans, count, nc, res]= asc_readheader(filein);

chans = {};
count = 0;
nc = 0;
res = -1;
if nargin < 1
   help asc_readheader;
   return;
end;	

chanlist = { 'f1' 'f2' 'fp1' 'fp2' 'f7' 'f8' 'f3' 'f4' 't3' 't4' 'c3' 'c4' 't5' 't6' 'p3' 'p4' 'o1' 'o2' 'fz' 'cz' 'pz' 'eog' };

% find number of header lines
% ---------------------------
fid = fopen(filein, 'r');
if fid == -1, disp(['Cannot open input file ' filein ]); res = -1; return; end;
cont = 1;
count = 0;
warning off;
tmpl = ' ';
while cont
   firstdataline = tmpl;
   tmpl = fgetl(fid);
   firstelem = strtok(tmpl);
   if isempty(firstelem), cont = 0;
   elseif firstelem(1) == -1, cont = 0;
   elseif ~isempty(str2num(firstelem)), cont = 0;
   end;
   count = count+1;
end;
warning on;
if ~isempty(tmpl) & ~isequal(tmpl, -1), firstdataline = tmpl; end;
if firstdataline(1) == -1
     nc = 0; 
else nc = length(sscanf(firstdataline, '%f'));
end;
fclose(fid);
count = count-1;
if count == 0, chans = {}; res = 1; return; end;

% skip header, read channel labels
% --------------------------------
fid  = fopen(filein, 'r');
tmpl = [];
for index = 1:count
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
if ~isempty(chans) & nc ~= 0
   if nc ~= length(chans)
      error('Number of channel lalels different from number of data points');
   end;
end;

res = 1;