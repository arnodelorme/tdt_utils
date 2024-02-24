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
%   'jewel'     - 'on'|'off' show max amplitude for each site
%   All plotscalp() options ('electrodes', 'sphspline', 'colormap') may
%   also be used (see plotscalp header for more information).
%
% Outputs:
%  topo    - topographic array
%  elec    - channel location structure
%
% 

%function [topoarray, eloc] = topo_tdt( filename, varargin )
function topo_tdt( filename, varargin )
    
    % ask for file name
    % -----------------
    if nargin < 1
        [tmpf, tmpp] = uigetfile('*.tdt;*.TDT;*.txt', 'Choose a TDT file'); 
        filename = [tmpp tmpf];
        if isequal(tmpf, 0)
            return
        end
    end
    if isstr(filename)
        fileout = [ filename(1:end-4) '.jpg' ];

        % decode topoplot parameters
        % --------------------------
        [data, titletext, eloc, options] = asc_readsimpletdt(filename);
        titlecols = data(1,:);
        data(1,:) = [];
        data = reshape([ data{1:end,:} ], size(data,1), size(data,2));
        options = { varargin{:} options{:} };
    else
        data      = filename.data;
        titletext = filename.title;
        titlecols = filename.titlecols;
        eloc      = filename.chanlocs;
        if isfield(filename, 'fileout'), fileout   = filename.fileout; else fileout = 'temp.jpg'; end
        options = varargin;
    end
    
    % do we have to plot colorbar with each plot?
    % -------------------------------------------
    plotcbar  = 1;
    maplimits = [];
    visible   = 'off';
    markmax   = 'off';
    markmin   = 'off';
    minhz     = 0;    
    maxhz     = 30;
    elecred   = {};
    elecblue  = {};
    for index = length(options)-1:-2:1
        key = options{index};
        val = options{index+1};
        if strcmpi(key, 'maxhz')
            maxhz = val;
            options(index:index+1) = [];
        elseif strcmpi(key, 'minhz')
            minhz = val;
            options(index:index+1) = [];
        elseif strcmpi(key, 'hzlim')
            if isstr(val)
                val(val == '_') = ' ';
                val = str2num(val);
            end
            minhz = val(1);
            maxhz = val(2);            
            options(index:index+1) = [];
        elseif strcmpi(key, 'visible')
            visible = val;
            options(index:index+1) = [];
        elseif strcmpi(key, 'markmax')
            markmax = val;
            options(index:index+1) = [];
        elseif strcmpi(key, 'markmin')
            markmin = val;
            options(index:index+1) = [];
        elseif strcmpi(key, 'elecred')
            elecred = val;
            options(index:index+1) = [];
        elseif strcmpi(key, 'elecblue')
            elecblue = val;
            options(index:index+1) = [];
        elseif strcmpi(key, 'fileout')
            fileout = val;
            options(index:index+1) = [];
        elseif strcmpi(key, 'maplimits')
            maplimits = options{index+1};
            options(index:index+1) = [];
            if ~isstr(maplimits) && ~iscell(maplimits)
                plotcbar = 0;
            elseif ~iscell(maplimits)
                maplimits(find(maplimits == '_')) = ' ';
                if ~isempty(str2num(maplimits))
                    plotcbar = 0; 
                    maplimits = str2num(maplimits);
                    if length(maplimits) == 1, maplimits = [-maplimits maplimits];
                    end
                elseif strcmpi(maplimits, 'common') || strcmpi(maplimits, 'commonsym') || strcmpi(maplimits, 'common0'), plotcbar = 0;
                end
            elseif length(maplimits) == 1 && isnan(maplimits{1}(1))
                maplimits = [];
            end
        end
    end
    
    % select up to 30 Hz if first row is Hz
    % -------------------------------------
    try
        if ~isempty(findstr('hz', lower(titlecols{1,1})))
            hzind = zeros(1, length(titlecols));
            for index = 1:length(titlecols)
                tmp = findstr('hz', lower(titlecols{index}));
                if ~isempty(tmp)
                    hzind(index) = str2num(titlecols{index}(1:tmp(1)-2));
                end
            end
            ind = find(hzind <= maxhz & hzind >= minhz);
            data      = data(:,ind);
            titlecols = titlecols(:,ind);
        end
    catch
        disp('Frequency bands detected (cannot set max freq. limit)');
    end
    
    % plot scalp map using topoplot
    % -----------------------------
    fig = figure; gca; axis off; drawnow
    pos = get(fig, 'position');
    nc = 5;
    nr = ceil(size(data,2)/nc);
    newpos = [ pos(1)+15 pos(2)+15 pos(3)*1.5 pos(4)/nc*nr*2.2 ];
    newpos = [ max(1,newpos(1)-newpos(3)+pos(3)) max(0, newpos(2)-newpos(4)+pos(4)) newpos(3) newpos(4)]; 
    set(fig, 'position', newpos);
    drawnow;
    tmpcaxis = [Inf -Inf];
    
    % find the max value for each channel
    % -----------------------------------
    if strcmpi(markmax, 'on')
        badchans = cellfun(@isempty, { eloc.theta });
        goodchans = find(~badchans);
        [tmp, indmax] = max(data(goodchans,:),[], 2);
        indmax = indmax(:)';
    else
        indmax = [];
    end
    if strcmpi(markmin, 'on')
        badchans = cellfun(@isempty, { eloc.theta });
        goodchans = find(~badchans);
        [tmp, indmin] = min(data(goodchans,:),[], 2);
        indmin = indmin(:)';
    else
        indmin = [];
    end
    
    for index = 1:size(data,2)
        tp_hdl(index) = mysubplot(nc,nr,index,plotcbar);
        %topoplot(topoarray, eloc, 'whitebk', 'on', options{:});
        
        tmpindmax = find(indmax == index); if isempty(tmpindmax), tmpindmax = []; end
        tmpindmin = find(indmin == index); if isempty(tmpindmin), tmpindmin = []; end
        if iscell(maplimits), tmplim = maplimits{index}; else tmplim = maplimits; end
        if ~isempty(elecred) , tmpindmax = elecred{ index}; end
        if ~isempty(elecblue), tmpindmin = elecblue{index}; end
        plotscalp(data(:,index), eloc, 'maplimits', tmplim, 'elecred', tmpindmax, 'elecblue', tmpindmin, options{:});
        
        % title
        %if ~isempty(findstr('Beta', data{1,index})), adfdas; end
        tmp = title( titlecols{index} );
        set(tmp, 'unit', 'normalized', 'interpreter', 'none');
        try, set(tmp, 'fontname', 'arial'); catch, end
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
                try, set(hdls(ind), 'fontsize', 7); catch, end
            end
        elseif isstr(maplimits)
            tmp = caxis;
            tmpcaxis = [ min(tmpcaxis(1), tmp(1)) max(tmpcaxis(2), tmp(2)) ];
        end
    end
    
    % common color axis
    % -----------------
    if isstr(maplimits)
        % only select good channels
        [tmp inds] = intersect( lower({ eloc.labels }), { 'fp1' 'fp2' 'f8' 't4' 't6' 'o1' 'o2' 't5' 't3' 'f7' }); 
        inds       = setdiff([1:length(eloc)], inds);
        if isempty(inds), inds = [1:length(eloc)]; end
        
        if strcmpi(maplimits, 'commonsym')
            tmpcaxis = abs(max(max(data(inds,:))));
            tmpcaxis = [-tmpcaxis tmpcaxis];
            %tmpcaxis = [-max(abs(tmpcaxis)) max(abs(tmpcaxis))];
        elseif strcmpi(maplimits, 'common0')
            tmpcaxis = max(max(data(inds,:)));
            tmpcaxis = [0 max(abs(tmpcaxis))];
        else
            tmpcaxis = [min(min(data(inds,:))) max(max(data(inds,:)))];
        end
        for index = 1:size(data,2)
            axes(tp_hdl(index));
            caxis(tmpcaxis);
            set(fig, 'visible', 'off');
        end
    end
    
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
        end
        hdl = axes('position', [ 0.5-1/14 pos 1/7 1/25/nr ]);          
        map = colormap;
        mycbar(hdl, 0, tmplim, 5);
    end
        
    set(fig, 'color', 'w', 'paperpositionmode', 'auto');
    inds = find(titletext == 9); titletext(inds) = [];
    tmp = disptitle(titletext);
    %topoarray = titletext; eloc = tmp;
    set(tmp, 'fontsize', 16, 'interpreter', 'tex');
    
    if strcmpi(visible, 'off')
        set(fig, 'paperpositionmode', 'auto');
        print(fig, '-djpeg', fileout, '-r300'); 
        close(fig);
    else
        set(fig, 'name', fileout(1:end-4), 'visible', 'on', 'paperpositionmode', 'auto');
        print(fig,'-djpeg', fileout); 
    end
        
    %set(fig, 'visible', 'on'); return;
    
% subplot in figure
% -----------------
function h = mysubplot(geom1, geom2, coord, plotcbar)
    
    coord = coord-1;
    horiz_border = 0;
    vert_border  = 0.25;

    left_border  = 0;
    right_border = 0;
    bottom_border = 0.2/geom2+0.01;
    top_border    = 0.25/geom2+0.01;
    
    coordy = floor(coord/geom1);   % coord in array
    coordx = coord - coordy*geom1; % coord in array
    
    posx   = coordx/geom1+horiz_border*1/geom1/2;
    posy   = 1.02-(coordy/geom2+vert_border*1/geom2/2)-1/geom2;
    width  = 1/geom1*(1-horiz_border);
    height = 1/geom2*(1- vert_border);
    if plotcbar == 0, posy = posy - height*0.25; height = height*1.25; end
    
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
        end
    end
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

