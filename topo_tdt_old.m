% topo_tdt() - Plot topographic maps for .tdt files
%
% Usage:
%   >> [topo elec] = topo_tdt( filename, 'key', 'val' );
%
% Inputs:
%   filename   - [string] file name.
%
% Options:
%   'maplimits' - 'common' all plot have common limits (take min and max of all
%                 'commonsym' same but the plot must be symetrical
%                 'absmax' axis are independent for each plot
%   All plotscalp() options ('electrodes', 'sphspline', 'colormap') may
%   also be used (see plotscalp header for more information).
%
% Outputs:
%  topo    - topographic array
%  elec    - channel location structure
%
% 

function [topoarray, eloc] = topo_tdt( filename, varargin )
    
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
        
    % do we have to plot colorbar with each plot?
    % -------------------------------------------
    plotcbar = 1;
    fixedcaxis = [];
    visible = 'off';
    maxhz   = 30;
    for index = length(options)-1:-2:1
        key = options{index};
        val = options{index+1};
        if strcmpi(key, 'maxhz')
            maxhz = val;
            options(index:index+1) = [];
        elseif strcmpi(key, 'visible')
            visible = val;
            options(index:index+1) = [];
        elseif strcmpi(key, 'fileout')
            fileout = val;
            options(index:index+1) = [];
        elseif strcmpi(key, 'maplimits');
            if ~isstr(val), plotcbar = 0; fixedcaxis = options{index+1};
            else
                val(find(val == '_')) = ' ';
                if ~isempty(str2num(val)), 
                    plotcbar = 0; fixedcaxis = str2num(val);
                    if length(fixedcaxis) == 1, options{index+1} = [-fixedcaxis fixedcaxis];
                    else                        options{index+1} = fixedcaxis;
                    end;
                elseif strcmpi(options{index+1}, 'common'), plotcbar = 0; fixedcaxis = 'common';
                elseif strcmpi(options{index+1}, 'commonsym'), plotcbar = 0; fixedcaxis = 'commonsym';
                end;
            end;
            if isstr(fixedcaxis), options{index+1} = []; end;
        end;
    end;
    
    % select up to 30 Hz if first row is Hz
    % -------------------------------------
    try
        if ~isempty(findstr('hz', lower(data{1,1})))
            hzind = zeros(1, size(data,2));
            for index = 1:size(data,2)
                tmp = findstr('hz', lower(data{1,index}));
                if ~isempty(tmp)
                    hzind(index) = str2num(data{1,index}(1:tmp(1)-2));
                end;
            end;
            ind = find(hzind <= maxhz);
            data = data(:,ind);
        end;
    catch
        disp('Failed to read freq. limits');
    end;
    
    % plot scalp map using topoplot
    % -----------------------------
    fig = figure('visible', 'off');
    %fig = figure;
    pos = get(gcf, 'position');
    nc = 5;
    nr = ceil(size(data,2)/nc);
    set(gcf, 'position', [ pos(1)+15 pos(2)+15 pos(3)*1.5 pos(4)/nc*nr*2.2 ]);
    tmpcaxis = [Inf -Inf];
    for index = 1:size(data,2)
        tp_hdl(index) = mysubplot(nc,nr,index,plotcbar);
        topoarray = [ data{2:end,index} ];
        %topoplot(topoarray, eloc, 'whitebk', 'on', options{:});
        
        plotscalp(topoarray, eloc, options{:});
        
        % title
        tmp = title( data{1,index} );
        set(tmp, 'unit', 'normalized', 'interpreter', 'none');
        try, set(tmp, 'fontname', 'arial'); catch, end;
        pos = get(tmp, 'position');
        set(tmp, 'position', [ pos(1) pos(2)-0.06 pos(3) ]);
        
        %colorbar
        if plotcbar
            tmplim = caxis;
            pos = get(gca, 'position');
            hdl = axes('position', [ pos(1)+pos(3)/5 pos(2) pos(3)/5*3 pos(4)/15 ]);              
            mycbar(hdl, 0, tmplim, 5);
            hdls = get(hdl, 'children');
            for ind=1:length(hdls)
                try, set(hdls(ind), 'fontsize', 7); catch, end;
            end;
        elseif isstr(fixedcaxis)
            tmp = caxis;
            tmpcaxis = [ min(tmpcaxis(1), tmp(1)) max(tmpcaxis(2), tmp(2)) ];
        end;
    end;
    
    % common color axis
    % -----------------
    if isstr(fixedcaxis)
        if strcmpi(fixedcaxis, 'commonsym')
            tmpcaxis = [-max(abs(tmpcaxis)) max(abs(tmpcaxis))];
        end;
        for index = 1:size(data,2)
            axes(tp_hdl(index));
            caxis(tmpcaxis);
            set(gcf, 'visible', 'off');
        end;
    end;
    
    % plot colorbar on top
    % --------------------
    if ~plotcbar
        tmplim = caxis;
        ax = axes('Units','Normal','Position',[0 0 1 1], 'Visible', 'off');
        switch nr, 
            case 1, pos = 0.82;
            case 2, pos = 0.88;
            case 3, pos = 0.92;
            case 4, pos = 0.94;
            case 5, pos = 0.95;
            case 6, pos = 0.96;            
            otherwise pos = 0.97;
        end;
        hdl = axes('position', [ 0.5-1/14 pos 1/7 1/25/nr ]);          
        map = colormap;
        mycbar(hdl, 0, tmplim, 5);
    end;
        
    set(gcf, 'color', 'w', 'paperpositionmode', 'auto');
    inds = find(titletext == 9); titletext(inds) = [];
    tmp = disptitle(titletext);
    %topoarray = titletext; eloc = tmp;
    set(tmp, 'fontsize', 16, 'interpreter', 'none');
    
    if strcmpi(visible, 'off')
        print('-djpeg', fileout); 
        close(fig);
    else
        set(gcf, 'name', fileout(1:end-4), 'numbertitle', 'off', 'menubar', 'none', 'visible', 'on');
        print('-djpeg', fileout); 
    end;
        
    %set(fig, 'visible', 'on'); return;
    
% subplot in figure
% -----------------
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

function mycbar(hdl, notused, tmplim, ngrads);    

    cols = [1:64]';
    image(linspace(tmplim(1),tmplim(2),length(cols)), [0 1],[cols'; cols']);
    tick = linspace(tmplim(1),tmplim(2), ngrads);
    for ind =1:length(tick)
        if tick(ind) > 10 | tick(ind) < -10
             ticklab{ind} = num2str(round(tick(ind))); 
        else ticklab{ind} = num2str(round(tick(ind)*10)/10);
        end;
    end;
    set(gca, 'xtickmode', 'manual', 'XAxisLocation', 'bottom', 'ytick', [], ...
        'xtick', tick, 'xticklabel', ticklab);
    xlabel('');
    
% put text title
% --------------
function h = disptitle(txt)

    ax = axes('Units','Normal','Position',[0 0 1 1], 'Visible','Off');

    tmp = text('Units','normal','String','tmp','Position',[0 0 0]);
    ext = get(tmp,'Extent'); delete(tmp)
    textheight = ext(4);

    x = .5;
    y = 1 - .60*textheight;
    h = text(x,y,txt,'VerticalAlignment','Middle', ...
         'HorizontalAlignment','Center');

