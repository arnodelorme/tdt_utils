% topo_dtd() - Plot topographic maps for .dtd files
%
% Usage:
%   >> OUTEEG = topo_dtd( filename, stringtype );
%
% Inputs:
%   filename   - [string] file name.
%   stringtype - [string] string containing the type of data to plot.
%                if no string is entered, the function will display
%                all possible choices.
%   column     - [string] or [integer] indicating the column name
%                or the column index. If no input is entered, the 
%                function will display all the possible choices.
%
% Outputs:
%  topo    - topographic array
%  elec    - channel location structure
%
% Note: the EEGLAB toolbox must be instaled for this function
%       to run properly.
%
% 

% to do? :

function [topoarray, eloc] = topodtd( filename, varargin )

    % ask for file name
    % -----------------
    if nargin < 1
        [tmpf tmpp] = uigetfile('*.tdt;*.TDT', 'Choose a TDT file'); 
        filename = [tmpp tmpf];
    end;
    fileout = [ filename(1:end-4) '.jpg' ];

    % decode topoplot parameters
    % --------------------------
    options = varargin;
    fid = fopen(filename, 'r');
    skip = 0;
    cont = 1;
    tmpline = fgetl(fid);
    if length(tmpline) > 1 && tmpline(1) == '%'
        skip = skip+1; % read one line (topoplot header)
        options = {};
        figure('visible', 'off');
        while(cont)
            tmpline = fgetl(fid); skip = skip+1; % read one line
            if length(tmpline) > 0
                if tmpline(1) == '%'
                    cont = 0;
                end;
            end;
            if cont
                [tmp args] = strtok(tmpline);
                try, 
                    args = eval(args);
                catch 
                    args = strtok(args);
                end;
                options = { options{:} tmp args };
            end;
        end;
    else
        fseek(fid, 0, -1); % return to beginning of file
    end;
    
    % find title
    % ----------
    tmpline = []; % blank line
    while isempty(tmpline)
        tmpline = fgetl(fid); skip = skip+1; % blank line
    end;
    skip = skip-1;
    
    % read all data lines
    % -------------------
    tmpa = loadtxt(filename, 'skipline', skip, 'delim', 9, 'verbose', 'off');
    
    % Title of plot
    % -------------
    titletext = tmpa{1,1};
    tmpa(1,:) = [];
    
    % handle 2 lines of title
    % -----------------------
    if isstr(tmpa{2,2}), 
        for index = 1:size(tmpa,2)
            tmpa{1,index} = [ tmpa{1,index} ' (' tmpa{2,index} ')' ];
        end;
        tmpa(2,:) = [];
    end;

    % handle electrode names etc...
    % -----------------------------
    tmpa(1, 2:end) = tmpa(1, 1:end-1);
    tmpa{1, 1} = [];
    data = tmpa(:,2:end);
    elec_names = tmpa(2:end,1);
    
    % find electrode positions
    % ------------------------
    disp('Looking up channel locations...')
    eloc = pop_chanedit( struct('labels', elec_names), 'lookup', 'standard-10-5-cap385.elp');
    
    % make all electrode inside
    % -------------------------
    maxrad = max([ eloc.radius ]);
    for ind = 1:length(eloc)
        eloc(ind).radius = eloc(ind).radius/maxrad*0.5;
    end;
    
    % do we have to plot colorbar with each plot?
    % -------------------------------------------
    plotcbar = 1;
    for index = 1:2:length(options)
        if strcmpi(options{index}, 'maplimits');
            if ~isstr(options{index+1}), plotcbar = 0; fixedcaxis = options{index+1}; end;
        end;
    end;
    
    % plot scalp map using topoplot
    % -----------------------------
    fig = figure('visible', 'off');
    %fig = figure;
    pos = get(gcf, 'position');
    nc = 5;
    nr = ceil(size(data,2)/nc);
    set(gcf, 'position', [ pos(1)+15 pos(2)+15 pos(3)*1.5 pos(4)/nc*nr*2.2 ]);
    for index = 1:size(data,2)
        mysubplot(nc,nr,index,plotcbar);
        topoarray = [ data{2:end,index} ];
        topoplot(topoarray, eloc, 'whitebk', 'on', options{:});

        % title
        tmp = title( data{1,index} );
        set(tmp, 'unit', 'normalized', 'interpreter', 'none');
        pos = get(tmp, 'position');
        set(tmp, 'position', [ pos(1) pos(2)-0.06 pos(3) ]);
        
        %colorbar
        if plotcbar
            tmplim = caxis;
            pos = get(gca, 'position');
            hdl = axes('position', [ pos(1)+pos(3)/5 pos(2) pos(3)/5*3 pos(4)/15 ]);  
            cbar(hdl, 0, tmplim, 5);
            setfont(hdl, 'fontsize', 7)
        end;
    end;
    
    % plot colorbar on top
    % --------------------
    if ~plotcbar
        tmplim = caxis;
        pos = get(gca, 'position');
        hdl = axes('position', [ 0.5-pos(3)/10*3 0.875+nr/75 pos(3)/5*3 pos(4)/15 ]);  
        cbar(hdl, 0, tmplim, 5);
    end;
        
    set(gcf, 'color', 'w', 'paperpositionmode', 'auto');
    inds = find(titletext == 9); titletext(inds) = [];
    tmp = textsc(titletext, 'title');
    %topoarray = titletext; eloc = tmp;
    set(tmp, 'fontsize', 16, 'interpreter', 'none');
    print('-djpeg', fileout); 
    
    %set(fig, 'visible', 'on'); return;

    close(fig);
    
function h = mysubplot(geom1, geom2, coord, plotcbar);
    
    coord = coord-1;
    horiz_border = 0;
    vert_border  = 0.25;

    left_border  = 0;
    right_border = 0;
    bottom_border = 0.2/geom2;
    top_border    = 0.25/geom2;
    
    coordy = floor(coord/geom1);   % coord in array
    coordx = coord - coordy*geom1; % coord in array
    
    posx   = coordx/geom1+horiz_border*1/geom1/2;
    posy   = 1.02-(coordy/geom2+vert_border*1/geom2/2)-1/geom2;
    width  = 1/geom1*(1-horiz_border);
    height = 1/geom2*(1- vert_border);
    if plotcbar == 0, posy = posy - height*0.25; height = height*1.25; end;
    
    % add border
    % ----------
    posx   = posx/(1+left_border+right_border)+left_border;
    posy   = posy/(1+top_border+bottom_border)+bottom_border;
    width  = width/(1+left_border+right_border);
    height = height/(1+top_border+bottom_border);
    h = axes('unit', 'normalized', 'position', [ posx posy width height ]);
    
function cmap = hsvinvert;    
    cmap = hsv;
    cmap = cmap(end:-1:1, :);
    