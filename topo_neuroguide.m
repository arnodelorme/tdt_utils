% topo_neuroguide() - Plot topographic maps for .dtd files
%
% Usage:
%   >> OUTEEG = topo_neuroguide( filename, stringtype, plotflag,'key', 'val', ....);
%
% Inputs:
%   filename   - [string] file name.
%   stringtype - [string] string containing the type of data to plot.
%                if no string is entered, the function will display
%                all possible choices.
%   plotflag   - ['hz'|'band'] plot single hertz or freq. bands.
%   'compmode' - ['percent'|'difference'] comparison mode. Either use
%                percent difference or difference. Default is 'percent'.
%   'key','val' - additional commands for topo_tdt
%
% Outputs:
%  topo    - topographic array
%  elec    - channel location structure
%
% 

function topo_neuroguide( filename, stringtype, varargin )

    if nargin > 1 & nargin < 2,
        help topo_neuroguide;
        return;
    end;
    
    % deal with DOS input, 2 files
    % ----------------------------
    if nargin > 1
        if exist(stringtype) == 2
            filename = { filename stringtype };
            if nargin < 3,
                help topo_neuroguide;
                return;
            else
               stringtype = varargin{1};
               varargin = varargin(2:end);
            end;
        end;
    end;
    
    plotflag = 'band';
    if length(varargin) > 0
        if isstr(varargin{1})
            if strcmpi(varargin{1}, 'hz') | strcmpi(varargin{1}, 'band')
                plotflag = varargin{1};
                varargin = varargin(2:end);
            end;
        end;
    end;

    % search for options
    % ------------------
    compmode = 'difference';
    for i=length(varargin)-1:-2:1
        if strcmpi(varargin{i}, 'compmode')
            compmode = varargin{i+1};
            varargin(i:i+1) = [];
        end;
    end;
    
    % ask for file name
    % -----------------
    graphicmode = 0;
    if nargin < 1
        [tmpf tmpp] = uigetfile('*.tdt;*.TDT', 'Choose one or two TDT files', 'MultiSelect', 'on'); 
        if ~iscell(tmpf)
            if tmpf(1) == 0, return; end;
        end;
        if iscell(tmpf)
            filename{1} = fullfile(tmpp, tmpf{1});
            filename{2} = fullfile(tmpp, tmpf{2});        
        else
            filename = fullfile(tmpp, tmpf);
        end;
        graphicmode = 1;
    end;
    
    % one or two inputs
    % -----------------
    if iscell(filename)
        if length(filename) > 2, error('Only two files may be given as input'); end;
        [tmpp  tmpf1] = fileparts(filename{1}(1:end-4));
        [tmpp2 tmpf2] = fileparts(filename{1}(1:end-4));
        fileout  = fullfile(tmpp, [ tmpf1 '-' tmpf2 '_neuroguide.jpg' ]);
    else
        filename = { filename };
        fileout  = [ filename{1}(1:end-4) '_neuroguide.jpg' ];
    end;
        
    % find title
    % ----------
    if ~graphicmode
        fprintf('You must enter a type string (or the beginning of a type string).\nPossible choices are indicated below\n');
    end;
    [ fileinfo choices subchoices fullchoices ] = gettdtcontent(filename{1});
    %for index = 1:length(choices)
    %    choices{index} = [ choices{index} ' by freq. bands' ];
    %end;
    
    if ~graphicmode & nargin < 2
        return;
    elseif nargin < 2
        fullchoices = sort(fullchoices);
        [s,v] = listdlg('PromptString','Select a property to plot:',...
                      'SelectionMode','single',...
                      'ListString', fullchoices, 'ListSize', [300 300], 'selectionmode', 'multiple');
        if v == 0, return; end;
        stringtype = fullchoices{s};
    end;
    
    % decode Hz or band
    % -----------------
    indhz   = findstr('by hz', lower(stringtype));
    indfreq = findstr('by freq', lower(stringtype));
    if ~isempty(indhz), stringtype = stringtype(1:indhz-2); plotflag = 'hz';
    elseif ~isempty(indfreq), stringtype = stringtype(1:indfreq-2); plotflag = 'band';
    else error('String not found');
    end;
    
    % search for the input string
    % ---------------------------
    fid = fopen(filename{1}, 'r');
    fseek(fid, 0, -1);
    [found tmpline] = search_title_line(fid, stringtype, plotflag);
    if ~found, error(['Cannot find section title ''' stringtype ''' in file ' filename{1}]); end;
    if length(filename) > 1
        % two files, copy percent difference to a new file
        % ------------------------------------------------
        fid2 = fopen(filename{2}, 'r');
        if fid2 == -1, error(['Cannot open file ' filename{2}]); end;
        [found tmpline2] = search_title_line(fid2, stringtype, plotflag);
        if ~found, error(['Cannot find section title ''' stringtype ''' in file ' filename{2}]); end;
        if ~strcmpi(tmpline, tmpline2), error('The header line containing Hz/Band names is different in the two files'); end;
           
        % open output file
        % ----------------
        fod = fopen('temp.tdt', 'w');
        if fod == -1, error('Cannot write temporary file in current folder'); end;
        [tmp name1] = fileparts(filename{1});
        [tmp name2] = fileparts(filename{2});
        if strcmpi(compmode, 'percent') fprintf(fod, '\n%s\n\n', [ stringtype ' 1-' name1 '/' name2 ' %' ]);
        else                            fprintf(fod, '\n%s\n\n', [ stringtype ' ' name1 '-' name2 ]);
        end;
        fprintf(fod, '%s\n', tmpline); % line of text
        
        % write percent
        % -------------
        alldat1 = myloadtxt(fid , 9); fclose(fid);  
        alldat2 = myloadtxt(fid2, 9); fclose(fid2);
        if ~all(size(alldat1) == size(alldat2)), error('The same section was found in both files but the amount of data differs'); end;
        if length(intersect(alldat1(:,1), alldat2(:,1))) < length(alldat1(:,1)), error('The tow files do not have the same channel labels'); end;
        if isstr(alldat1{1})
            for r = 1:size(alldat1,2)        
                fprintf(fod, '\t%s', alldat1{1,r});
            end;
            fprintf(fod, '\n');
            alldat1(1,:) = [];
        end;
        if isstr(alldat2{1})
            alldat2(1,:) = [];
        end;
        for r = 1:size(alldat1,1)        
            fprintf(fod, '%s', alldat1{r,1});
            for c = 2:size(alldat1,2)
                if strcmpi(compmode, 'percent');
                     fprintf(fod, '\t%f', 100-100*alldat1{r,c}/alldat2{r,c});
                else fprintf(fod, '\t%f', alldat1{r,c}-alldat2{r,c});
                end;
            end;
            fprintf(fod, '\n');
        end
        fclose(fod);
        count = size(alldat1,1);
    else
        % only one file, copy lines to a new file
        % ---------------------------------------
        count = 1;
        fod = fopen('temp.tdt', 'w');
        if fod == -1, error('Cannot write temporary file in current folder'); end;
        fprintf(fod, '\n%s\n\n', stringtype);
        fprintf(fod, '%s\n', tmpline); % line of text
        tmpline = fgetl(fid); fprintf(fod, '%s\n', tmpline); % line of text or data channel
        while ~isempty( tmpline ) && ~feof(fid)
            tmpline = fgetl(fid); 
            fprintf(fod, '%s\n', tmpline);
            count = count +1;
        end
        fclose(fid);
        fclose(fod);
    end;
    
    % plot data
    % ---------
    visible = 'on';
    if nargin > 1
        visible = 'off';
    end;
    if count < 32
        topo_tdt('temp.tdt', varargin{:}, 'fileout', fileout, 'visible', visible);
        %delete('temp.tdt');
    else
        asc_convertcohfile('temp.tdt', 'temp2.tdt');
        asc_coherplot('temp2.tdt', varargin{:}, 'fileout', fileout, 'title', stringtype, 'visible', visible);
        delete('temp.tdt');
        delete('temp2.tdt');        
    end;


% search for title line in file
% the file is then positioned 
% -----------------------------
function [found tmpline] = search_title_line(fid, stringtype, plotflag);

    lineindex_begin = 0;
    found = 0;
    while ~feof(fid) && (found == 0)
        
        lineindex_begin = lineindex_begin + 1;
        tmpline = fgetl(fid); % read one line
        if length(tmpline) >= length(stringtype)
            if strcmpi(tmpline(1:length(stringtype)), stringtype) % compare with input string
                found = 1;
                tmpline = fgetl(fid); % read one line
                if isempty(tmpline), tmpline = fgetl(fid); end;
                if ~isempty(findstr('hz', lower(tmpline))) & strcmpi(plotflag, 'band')
                    found = 0;
                elseif strcmpi(plotflag, 'hz') & isempty(findstr('hz', lower(tmpline)))
                    found = 0;
                end;
            end;
        end;
    end

  
    