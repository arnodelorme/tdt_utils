% asc_coherplot() - Plot topographic maps for .tdt files
%
% Usage:
%   >> [coh elec] = asc_coherplot( filename, 'key', 'val' );
%
% Inputs:
%   filename   - [string] file name
%
% Options:
%
% Outputs:
%  coh     - coherence array (elec x elec)
%  elec    - channel location structure
%
% 

%function [coh, eloc] = asc_coherplot( filename, varargin )
function res = asc_coherplot( filename, varargin )
res = 1;
    
    % ask for file name
    % -----------------
    if nargin < 1
        [tmpf, tmpp] = uigetfile('*.txt;*.txt', 'Choose a coherence file'); 
        if tmpf(1) == 0, return; end
        filename = fullfile(tmpp,tmpf);
    end
    if isstr(filename)
        fileout = [ filename(1:end-4) '.jpg' ];
    
        % read coherence in file
        % ----------------------
        fid = fopen(filename, 'r');
        if fid == -1, error('Cannot open/find file'); end;

        % read other file format (switch 1 and 0 based on format)
        if 0
            % square format
            tmpline = fgetl(fid); linecount = 1;
            nfreq   = 1;
            while ~feof(fid)

                % read freq. band
                linecount = 1;
                while isempty(tmpline), tmpline = fgetl(fid); linecount = 1; end;
                coh(nfreq).freq = tmpline;

                % read electrode names
                tmpline = fgetl(fid); linecount = linecount+1;
                while isempty(tmpline), tmpline = fgetl(fid); linecount = 1; end;
                count   = 1; elec1 = {};
                while ~isempty(tmpline)
                    [ elec1{count} tmpline ] = strtok( tmpline );
                    count = count+1;
                end;
                if isempty(elec1{end}), elec1(end) = []; end;

                % read data
                array = zeros(length(elec1), length(elec1));
                elec2 = {};
                for index = 1:length(elec1)
                    tmpline = fgetl(fid); linecount = linecount+1;
                    [ elec2{index} tmpline ] = strtok( tmpline );
                    array(index,:) = sscanf(tmpline, '%f', [length(elec1)])';
                end;
                coh(nfreq).elec1 = elec1;
                coh(nfreq).elec2 = elec2;
                coh(nfreq).data  = array;
                coh(nfreq).datasel = zeros(size(array));
                nfreq = nfreq + 1;

                % go to next frequency
                tmpline = fgetl(fid); linecount = linecount+1;
                while isempty(tmpline), tmpline = fgetl(fid); linecount = 1; end;
            end
            fclose(fid);
        elseif 1 % second format (only read first entry)
             % -------------------------------------
            [freqbands, freqbands2, mytitle] = readtitlefreqbands(fid);

            % read all data channels and data
            linecount = 1;
            allelec2flag = 0;
            alldata = zeros(900, length(freqbands));
            tmpline = fgetl(fid);
            while ~isempty(tmpline)
                % get electrodes and electrode indices
                [ elec1{linecount}, tmpline ] = strtok( tmpline );
                [ elec2{linecount}, tmpline ] = strtok( tmpline );
                alldata(linecount,:) = str2num(tmpline);
                linecount = linecount + 1;
                tmpline = fgetl(fid);
            end

            nelec = length(unique(elec1));
            elec1 = {elec1{1} elec2{1:nelec-1} };

            % transform into 3-D matrix
            alldata3d = zeros(nelec, nelec, length(freqbands));
            linecount = 1;
            for ielec = 1:nelec
                alldata3d(ielec,ielec+1:end,:) = alldata(linecount:linecount+(nelec-ielec-1),:);
                linecount = linecount+(nelec-ielec+1);
            end
            alldata3d = alldata3d+permute(alldata3d, [2 1 3])+repmat(eye(nelec,nelec), [1 1 length(freqbands)]);

            % copy to output structure
            for freqind = 1:length(freqbands)
                coh(freqind).freq  = freqbands{freqind};
                coh(freqind).elec1 = elec1;
                coh(freqind).elec2 = elec1;
                coh(freqind).data    = alldata3d(:,:,freqind);
                coh(freqind).datasel = zeros(nelec,nelec);
            end
            fclose(fid);
        end
        
        % encoding by pair
        % ----------------
        endindex = NaN;
        if ~isempty(varargin)
            for index = 1:3:length(varargin)
                % encoding is 'pair', 'f7', 't5'
                if strcmpi('pair', varargin{index}) & isnan(endindex)
                    ind1 = strmatch(lower(varargin{index+1}), lower(elec1), 'exact');
                    ind2 = strmatch(lower(varargin{index+2}), lower(elec2), 'exact');
                    if isempty(ind1), error(['Electrode not found:' lower(varargin{index+1}) ]); end;
                    if isempty(ind2), error(['Electrode not found:' lower(varargin{index+2}) ]); end;
                    for tmpind = 1:length(coh)
                        coh(tmpind).datasel(ind1, ind2) = coh(tmpind).data(ind1, ind2);
                    end;
                elseif isnan(endindex), endindex = index;
                end;
            end;
        end;
        if isnan(endindex), endindex = max(length(varargin),1); end;
        if isempty(varargin) | endindex == 1
            for tmpind = 1:length(coh)
                coh(tmpind).datasel = coh(tmpind).data;
            end;
        end;

        % handle electrode names etc...
        % -----------------------------
        eloc = asc_readloc('chanlocs10-5.ced', elec1);
        options  = varargin(endindex:end);
    else
        data      = filename.data;
        titletext = filename.title;
        titlecols = filename.titlecols;
        eloc      = filename.chanlocs;
        if isfield(filename, 'fileout'), fileout   = filename.fileout; else fileout = 'temp.jpg'; end;
        options = varargin;
    end

    % plot scalp map using plotcoher
    % ------------------------------
    fig = figure('visible', 'off');
    %fig = figure;
    pos = get(gcf, 'position');
    nc = 5;
    if size(coh,2) == 1, nr = 4;
    else                 nr = ceil(size(coh,2)/nc);
    end;
    set(gcf, 'position', [ pos(1)+15 pos(2)+15 pos(3)*1.5 pos(4)/nc*nr*2.2 ]);
    tmpcaxis = [Inf -Inf];
    plotcbar = 0;
    % if size(coh,2) == 1 % allow plotting coherence of individual channels
    %     plotcoherelec( coh.datasel, eloc, 'title', coh.freq, options{:});
    %     fig = gcf;
    % else
        for index = 1:size(coh,2)
            tp_hdl(index) = mysubplot(nc,nr,index,plotcbar);
            plotcoher(coh(index).datasel, eloc, options{:});

            % title
            tmp = title( deblank(coh(index).freq) );
            set(tmp, 'unit', 'normalized', 'interpreter', 'none');
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
            end;
        end;
        colormap(pink);
    % end;

    % plot colorbar on top
    % --------------------
    g = struct(options{:});
    try, g.colormap;   catch, g.colormap = 'bluered'; end;
    try, g.maxcoh;     catch, g.maxcoh   = 3; end;
    try, g.title;      catch, g.title    = ''; end;
    try, g.visible;    catch, g.visible  = 'off'; end;
    try, g.fileout;    catch, g.fileout  = fileout; end;
    set(gcf, 'visible', g.visible);
    tmplim = caxis;
    pos = get(gca, 'position');
    if strcmpi(g.colormap, 'blueredonly'), f = 0.3; else f = 0.2; end;
    if strcmpi(g.colormap, 'blueredonly') | strcmpi(g.colormap, 'bluered'), col = 1; else col = 0; end;
    % if size(coh,2) > 1
        hdl = axes('position', [ (0.2+0)-pos(3)/10*3   0.875+nr/75 pos(3)/5*3 pos(4)/15 ]);  mycbar(hdl, 1.6449, 1, col);
        hdl = axes('position', [ (0.2+f)-pos(3)/10*3   0.875+nr/75 pos(3)/5*3 pos(4)/15 ]);  mycbar(hdl, 2.3263, 2, col);
        hdl = axes('position', [ (0.2+2*f)-pos(3)/10*3 0.875+nr/75 pos(3)/5*3 pos(4)/15 ]);  mycbar(hdl, 3.0902, 3, col);
        if ~strcmpi(g.colormap, 'blueredonly')
            if strcmpi(g.colormap, 'bluered'), cmap = redbluecmap; cmap = cmap(end:-1:1,:);
            else                               cmap = yellowredbluecmap;
            end;
            hdl = axes('position', [ (0.2+3*f)-pos(3)/10*3 0.875+nr/75 pos(3)/5*3 pos(4)/15 ]);  mycbar2(hdl, cmap, [-g.maxcoh g.maxcoh], 5);
        end;
        inds = find(g.title == 9); g.title(inds) = [];
        tmp = disptitle(g.title);
        set(tmp, 'fontsize', 16, 'interpreter', 'none');
    % end;
    set(gcf, 'color', 'w', 'paperpositionmode', 'auto');

    try,
        print('-djpeg', g.fileout); 
    catch, end;
    if strcmpi(g.visible, 'off')
        close(fig);
    end;
    
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

function mycbar(hdl, zscore, lnwidth, col);    

    if col
        line([-1 0]', [0 0]', 'color', 'b', 'linewidth', lnwidth);
        line([0  1]', [0 0]', 'color', 'r', 'linewidth', lnwidth);
    else
        line([-1 0]', [0 0]', 'color', [0.5 0.5 0.5], 'linewidth', lnwidth);
        line([0  1]', [0 0]', 'color', [0.5 0.5 0.5], 'linewidth', lnwidth);
    end;
    text(-1.2,0.05,'-');
    text(1.05,0.05,'+');
    xlim([-1.5 1.5]);
    ylim([-1 1]);
    text(-1.2,-2.5, sprintf('Zscore >= %1.2f', zscore));
    axis off;

function mycbar2(hdl, cmap, tmplim, ngrads);   
    cmap = reshape(cmap, 1, size(cmap,1), size(cmap,2)); cmap(2,:,:) = cmap;
    image(tmplim, linspace(tmplim(1),tmplim(2),length(size(cmap,2))), cmap);
    tick = linspace(tmplim(1),tmplim(2), ngrads);
    for ind =1:length(tick)
        if tick(ind) > 10 | tick(ind) < -10
             ticklab{ind} = num2str(round(tick(ind))); 
        else ticklab{ind} = num2str(round(tick(ind)*10)/10);
        end;
    end;
    xlim(tmplim);
    set(gca, 'xtickmode', 'manual', 'XAxisLocation', 'bottom', 'ytick', [], ...
        'xtick', tick, 'xticklabel', ticklab);
    xlabel('');

function mycbar4(hdl, zscore, lnwidth, cmap);   
    cols = [1:64]';
    cmap = reshape(cmap, 1, size(cmap,1), size(cmap,2)); cmap(2,:,:) = cmap;
    image([-1 1], linspace(-0.1,0.1,size(cmap,1))*lnwidth, cmap);
    text(-1.2,0.05,'-');
    text(1.05,0.05,'+');
    xlim([-1.5 1.5]);
    ylim([-1 1]);
    text(-1.2,-2.5, sprintf('Zscore >= %1.2f', zscore));
    axis off;

function mycbar3(hdl, notused, tmplim, ngrads);    

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
         
% read title and frequency bands in coherenc file
% -----------------------------------------------
function [freqband1, freqband2, mytitle] = readtitlefreqbands(fid, tmpline)
    freqband2 = [];

    % read title
    tmpline = fgetl(fid);
    while isempty(tmpline), tmpline = fgetl(fid); end;
    mytitle = tmpline;
    tmpline = fgetl(fid);

    % read freq. bands
    while isempty(tmpline), tmpline = fgetl(fid); end;
    count   = 1; freqband1 = {};
    while ~isempty(tmpline)
        [ freqband1{count}, tmpline ] = strtok( tmpline, 9);
        count = count+1;
    end;
    if isempty(freqband1{end}), freqband1(end) = []; end;
    return

    % read freq. bands again
    while isempty(tmpline), tmpline = fgetl(fid); end;
    count   = 1; freqband2 = {};
    while ~isempty(tmpline)
        [ freqband2{count}, tmpline ] = strtok( tmpline, 9);
        count = count+1;
    end;
    if isempty(freqband2{end}), freqband2(end) = []; end;
