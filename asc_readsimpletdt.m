% asc_readsimpletdt() - Read simple TDT file
%
% Usage:
%   >> [dataarray descrip eloc options] = asc_readsimpletdt( filename, 'key', 'val' );
%
% Inputs:
%   filename   - [string] file name.
%
% Outputs:
%  dataarray - dataarray
%  descrip   - one line of description
%  eloc      - channel location structure
%  options   - additional options contained in the header
%
% 

function [data, titletext, eloc, options] = asc_readsimpletdt(filename);

options = {};
fid = fopen(filename, 'r');
if fid == -1
    error('Cannot open file');
end
skip = 0;
cont = 1;
tmpline = fgetl(fid);
if length(tmpline) > 1 && tmpline(1) == '%'
    skip = skip+1; % read one line (topoplot header)
    while(cont)
        tmpline = fgetl(fid); skip = skip+1; % read one line
        if length(tmpline) > 0
            if tmpline(1) == '%'
                cont = 0;
            end
        end
        if cont
            [tmp, args] = strtok(tmpline);
            try
                args = eval(args);
            catch 
                args = strtok(args);
            end
            options = { tmp args options{:} };
        end
    end
else
    fseek(fid, 0, -1); % return to beginning of file
end

% find title
% ----------
tmpline = []; % blank line
while isempty(tmpline)
    tmpline = fgetl(fid); skip = skip+1; % blank line
end
skip = skip-1;
fclose(fid);

% read all data lines
% -------------------
tmpa = loadtextfile(filename, skip, 9);
%tmpa = loadtxt(filename, 'skipline', skip, 'delim', 9);

% Title of plot
% -------------
titletext = tmpa{1,1};
tmpa(1,:) = [];

% handle 2 lines of title
% -----------------------
if isstr(tmpa{2,2})
    for index = 1:size(tmpa,2)
        tmpa{1,index} = [ tmpa{1,index} ' (' tmpa{2,index} ')' ];
    end
    tmpa(2,:) = [];
end

% handle electrode names etc...
% -----------------------------
tmpa(1, 2:end) = tmpa(1, 1:end-1);
tmpa{1, 1} = [];
if isempty(tmpa{end,1}), tmpa(end,:) = []; 
elseif tmpa{end,1}(1) == -1, tmpa(end,:) = []; 
end
data = tmpa(:,2:end);
elec_names = tmpa(2:end,1);

eloc = asc_readloc('chanlocs10-5.ced', elec_names);
