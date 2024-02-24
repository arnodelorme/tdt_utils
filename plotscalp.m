% plotscalp() - plot scalp map
%
% plotscalp( vals, chanlocs, 'key', 'val');
%
% Input:
%   vals     - values, one per channel
%   chanlocs - channel structure, same size as vals
%
% Optional inputs:
%   colormap   - colormap. Possible colormaps are 'blueredyellow', ...
%                'yellowredblue', 'bluered' or any Matlab colormap ('cool',
%                'jet', 'hsv', ...). It can also be a text file 'xxx.txt'. 
%                The text file must contain 3 columns and idealy 64 rows 
%                defining the colors in RGB format.
%   maplimits  - can be [min max]. This help defines the color scale for
%                maps.
%   electrodes - can be 'on' to show electrode dots, 'off', 'labels' 
%                to show electrode labels, or 'values' to show electrode 
%                values. Default is 'on'.
%   elecmode   - normal or indot. Indot plots the text inside the dots
%   dotsize    - size of electrode dots. Default is 5.
%   elecred    - labels or indices of electrodes to be plotted in red. From 
%                the compiled files, these must be entered using underscores
%                for separators (e.g., "cz_pz"). 'max' or 'min' may also be
%                used to highlight the minimum or maximum at each frequency.
%   elecblue   - labels or indices of electrodes to be plotted in blue
%   elecgreen  - labels or indices of electrodes to be plotted in green
%   exclude    - labels or indices of electrodes not to be plotted. From the
%                compiled files, these must be entered using underscores
%                for separators (e.g., "cz_pz").
%   sphspline  - can be 'on' or 'off'. If 'on' spherical splines are used
%                for interpolation of the scalp map. If 'off' standard 
%                planar inverse distance interpolation is used.
%   shrink     - shrink electrode positions (default is 0.75 to be able to
%                plot electrode at the head limit if spherical interpolation
%                is set and 0.95 for planar 2-D interpolation).
%
% References for spline interpolation:
%   [1] Perrin, F., Pernier, J., Bertrand, O., & Echallier, J. F.
%       (1989). Spherical splines for scalp potential and current
%       density mapping. Electroencephalography and Clinical
%       Neurophysiology, 72, 184-187
%   [2] Ferree, T. C. (2000). Spline Interpolation of the Scalp EEG.
%       Retrieved March 26, 2006, from
%       www.egi.com/Technotes/SplineInterpolation.pdf
%
% limitation: does not plot anything below the upper part of the head

function plotscalp(values, chanlocs, varargin);

g = [];
for index = 1:2:length(varargin)
    g = setfield(g, varargin{index}, varargin{index+1});
end;
if ~isfield(g, 'electrodes'), g.electrodes = 'on'; end;
if ~isfield(g, 'colormap'),   g.colormap   = jet;  end;
if ~isfield(g, 'maplimits'),  g.maplimits  = [];   end;
if ~isfield(g, 'sphspline'),  g.sphspline  = 'off'; end;
if ~isfield(g, 'contour'),    g.contour    = 'on'; end;
if ~isfield(g, 'blank'),      g.blank      = 'off'; end;
if ~isfield(g, 'dotsize'),    g.dotsize    = 5;    end;
if ~isfield(g, 'elecgreen'),  g.elecgreen  = [];   end;
if ~isfield(g, 'elecred'),    g.elecred    = [];   end;
if ~isfield(g, 'elecblue'),   g.elecblue   = [];   end;
if ~isfield(g, 'exclude'),    g.exclude    = [];   end;
if ~isfield(g, 'elecmode'),   g.elecmode   = 'normal'; end;
if ~isfield(g, 'shrink'),     if strcmpi(g.sphspline, 'on'), g.shrink = 0.75; else g.shrink = 0.95; end; end;
if isstr(g.dotsize), g.dotsize = str2num(g.dotsize); end;
if any(values == 0)
    inds = find(values == 0);
    if ~isempty( [ chanlocs(inds).theta ])
        g.contour = 'off';
        g.sphspline = 'off';
    end;
end;

if ~isnumeric(g.elecred),   g.elecred   = elecind(g.elecred,   chanlocs, values); end;
if ~isnumeric(g.elecblue),  g.elecblue  = elecind(g.elecblue,  chanlocs, values); end;
if ~isnumeric(g.elecgreen), g.elecgreen = elecind(g.elecgreen, chanlocs, values); end;
if ~isnumeric(g.exclude),   g.exclude   = elecind(g.exclude,   chanlocs); end;
if isstr(g.shrink),    g.shrink = str2num(g.shrink); end;

% exclude electrodes
% ------------------
if ~isempty(g.exclude)
    chanlocs(g.exclude) = [];
    values(g.exclude)   = [];
end;

gridres = 30;
radius = 0.5;
linewidth = 1;

pnts = linspace(0,2*pi,200);
xx = sin(pnts)*radius;
yy = cos(pnts)*radius;

% find channel coordinates
% ------------------------
emptyvals = cellfun('isempty', { chanlocs.theta }); 
th = [ chanlocs.theta ];
rd = [ chanlocs.radius ];
[y x] = pol2cart(th/180*pi, rd); x=-x;
x = x*g.shrink;
y = y*g.shrink;
newvalues            = values;
newvalues(emptyvals) = [];
labls = { chanlocs.labels }; 
labls(emptyvals) = [];

if strcmpi(g.sphspline, 'on')
    
    % spherical plotting
    % ------------------
    xelec = [ chanlocs.X ];
	yelec = [ chanlocs.Y ];
	zelec = [ chanlocs.Z ];

    dist = sqrt(xelec.^2+yelec.^2+zelec.^2);
	xelec = xelec./dist;
	yelec = yelec./dist;
	zelec = zelec./dist;
    
    if g.shrink ~= 1
        [th phi rad] = cart2sph(xelec, yelec, zelec);
        phi = (phi-pi/2)*g.shrink+pi/2;
        [xelec, yelec, zelec] = sph2cart(th, phi, rad);
    end;        
    
	[xsph, ysph, zsph, valsph] = spheric_spline(xelec,yelec,zelec,newvalues); 
    top = max(abs(valsph(:)))*1000;
    if ~strcmpi(g.blank, 'on')
        surf(-ysph/2,xsph/2,zsph/2,double(valsph), 'edgecolor', 'none'); view([0 0 1]);hold on;
        shading interp;
    
        if strcmpi(g.contour, 'on')
        	[c h] = contour3(-ysph/2, xsph/2, valsph+top/10, 5); view([0 0 1]);
            set(h, 'edgecolor', 'k')
        end;
    end;
    
	% coordinates for electrodes
	% --------------------------
    xelec(find(zelec < 0)) = [];
    yelec(find(zelec < 0)) = [];
    x = yelec/2;
    y = xelec/2;
    
else
    
	% make grid and add circle
	% ------------------------
	coords = linspace(-0.5, 0.5, gridres);
	ay = repmat(coords,  [gridres 1]);
	ax = repmat(coords', [1 gridres]);
	for ind=1:length(xx)
        [tmp closex] = min(abs(xx(ind)-coords));
        [tmp closey] = min(abs(yy(ind)-coords));
        ax(closex,closey) = xx(ind);
        ay(closex,closey) = yy(ind);
	end;
	radius = 0.49;
	xx2 = sin(pnts)*radius;
	yy2 = cos(pnts)*radius;
	for ind=1:length(xx)
        [tmp closex] = min(abs(xx2(ind)-coords));
        [tmp closey] = min(abs(yy2(ind)-coords));
        ax(closex,closey) = xx(ind);
        ay(closex,closey) = yy(ind);
	end;
	
	% linear interpolation and removal of values outside circle
	% ---------------------------------------------------------
    top = max(values)*1.5;
    if ~strcmpi(g.blank, 'on')
        a = griddata(x, y, newvalues, -ay, ax, 'v4');
        aradius = sqrt(ax.^2 + ay.^2);
        indoutcircle = find(aradius(:) > 0.51);
        a(indoutcircle) = NaN;
        surf(ay, ax, a, 'edgecolor', 'none'); view([0 0 1]); hold on;
        shading interp;
    
        % plot level lines
        % ----------------
        if strcmpi(g.contour, 'on')
            [c h] = contour3(ay, ax, a, 5);
            set(h, 'edgecolor', 'k')
        end;
    end;
end;

% main circle
% -----------
plot3(xx,yy,ones(size(xx))*top, 'k', 'linewidth', linewidth); hold on;

% ears & nose
% -----------
earx  = [0.4960    0.505    0.520    0.530    0.540    0.533   0.550    0.543    0.530   0.500    0.490]; % rmax = 0.5
eary  = [0.0655    0.0855   0.086    0.082    0.066    0.015   -0.073   -0.09   -0.11   -0.115   -0.1];
plot3(earx,eary,ones(size(earx))*top,'color','k','LineWidth',linewidth)    % plot left ear
plot3(-earx,eary,ones(size(earx))*top,'color','k','LineWidth',linewidth)   % plot right ear

nosex = [0.0900 0.0400 0.010 0 -0.010 -0.0400 -0.0900];
nosey = [0.492  0.5300 0.5700 0.570 0.5700 0.5300 0.492 ];
plot3(nosex, nosey, ones(size(nosex))*top,'color','k','LineWidth',linewidth)   % plot right ear
axis equal

% plot electrodes as dots
% -----------------------
if strcmpi(g.electrodes, 'on') || strcmpi(g.electrodes, 'labels') || strcmpi(g.electrodes, 'values')
    rad = sqrt(x.^2 + y.^2);
    x(find(rad > 0.5)) = [];
    y(find(rad > 0.5)) = [];
    
    if strcmpi(g.elecmode, 'normal')
        plot3( -x, y, ones(size(x))*top, 'k.', 'markersize', g.dotsize);
        for i = g.elecred,   plot3( -x(i), y(i), double(top), 'y.', 'markersize', 4*g.dotsize); plot3( -x(i), y(i), double(top), 'r.', 'markersize', 2*g.dotsize); end;
        for i = g.elecgreen, plot3( -x(i), y(i), double(top), 'y.', 'markersize', 4*g.dotsize); plot3( -x(i), y(i), double(top), 'g.', 'markersize', 2*g.dotsize); end;
        for i = g.elecblue,  plot3( -x(i), y(i), double(top), 'y.', 'markersize', 4*g.dotsize); plot3( -x(i), y(i), double(top), 'b.', 'markersize', 2*g.dotsize); end;
        offset = 0.02;
    else
        whitedots = setdiff(1:length(x), union(union(g.elecred, g.elecgreen), g.elecblue));
        plot3( -x, y, ones(size(x))*top, 'k.', 'markersize', g.dotsize);
        for i = g.elecred,   plot3( -x(i), y(i), double(top), 'k.', 'markersize', 6*g.dotsize); h = plot3( -x(i), y(i), double(top), 'r.', 'markersize', 5*g.dotsize); set(h, 'color', [255 204 153]/255); end;
        for i = g.elecgreen, plot3( -x(i), y(i), double(top), 'k.', 'markersize', 6*g.dotsize); h = plot3( -x(i), y(i), double(top), 'g.', 'markersize', 5*g.dotsize); set(h, 'color', [255 204 153]/255); end;
        for i = g.elecblue,  plot3( -x(i), y(i), double(top), 'k.', 'markersize', 6*g.dotsize); h = plot3( -x(i), y(i), double(top), 'b.', 'markersize', 5*g.dotsize); set(h, 'color', [153 204 255]/255); end;
        for i = whitedots,   plot3( -x(i), y(i), double(top), 'k.', 'markersize', 6*g.dotsize); plot3( -x(i), y(i), double(top), 'w.', 'markersize', 5*g.dotsize); end;    
        offset = -0.045;
        g.electrodes = 'values';
    end;
    if strcmpi(g.electrodes, 'labels')
        for index = 1:length(x)
            text( -x(index)+offset, y(index), double(top), labls{index});
        end;
    end;
    if strcmpi(g.electrodes, 'values')
        for index = 1:length(x)
            strval = num2str(values(index), 2); if length(strval) == 1, strval = [ ' ' strval ]; end;
            if length(strval) > 3 && strval(1) == '0', strval(1) = []; end;
            if length(strval) > 3 && strval(1) == '-' && strval(2) == '0', strval(2) = []; end;
            if length(strval) > 3, strval(4:end) = []; end;
            hhh = text( -x(index)+offset, y(index), double(top), strval);
            if ~strcmpi(g.elecmode, 'normal'), set(hhh, 'fontsize', 4.25, 'fontweight', 'bold'); end;
        end;
    end;
else
    % invisible electrode that avoid plotting problem (no surface, only
    % contours)
    plot3( -x, y, -ones(size(x))*top, 'k.', 'markersize', 0.001); 
end;

% special colormaps
% -----------------
if isstr(g.colormap) 
    if ~isempty(strmatch(g.colormap, { 'hsv' 'jet' 'gray' 'hot' 'cool' 'bone' ...
            'copper', 'pink' 'flag' 'prism' }, 'exact'))
    elseif strcmpi(g.colormap, 'yellowredblue'), g.colormap = yellowredbluecmap;
    elseif strcmpi(g.colormap, 'coolhot'),   g.colormap = coolhotcmap;
    elseif strcmpi(g.colormap, 'blueredyellow'), g.colormap = yellowredbluecmap; g.colormap = g.colormap(end:-1:1,:);
    elseif strcmpi(g.colormap, 'bluered'), g.colormap = redbluecmap; g.colormap = g.colormap(end:-1:1,:);
    elseif strcmpi(g.colormap, 'redblue'), g.colormap = redbluecmap; 
    elseif strcmpi(g.colormap, 'jet2'), g.colormap = jet(128); g.colormap(1:64,:) = []; 
    elseif strcmpi(g.colormap, 'hsv2'), g.colormap = hsv(128); g.colormap(1:64,:) = []; 
    else % read text file
        g.colormap = load('-ascii', g.colormap);
    end;
end;    
colormap(g.colormap);

if ~isempty(g.maplimits)
    if ~isstr(g.maplimits) && ~isempty(g.maplimits) && ~isnan(g.maplimits(1))
        caxis(g.maplimits);
    end;
end;

axis off;
set(gca, 'ydir', 'normal');
ylim([-0.65 0.6]);

% ----------------
% spherical spline
% ----------------
function [x, y, z, Res] = spheric_spline( xelec, yelec, zelec, values);

SPHERERES = 20;
[x,y,z] = sphere(SPHERERES);
x(1:(length(x)-1)/2,:) = [];
y(1:(length(x)-1)/2,:) = [];
z(1:(length(x)-1)/2,:) = [];

Gelec = computeg(xelec,yelec,zelec,xelec,yelec,zelec);
Gsph  = computeg(x,y,z,xelec,yelec,zelec);

% equations are 
% Gelec*C + C0  = Potential (C unknow)
% Sum(c_i) = 0
% so 
%             [c_1]
%      *      [c_2]
%             [c_ ]
%    xelec    [c_n]
% [x x x x x]         [potential_1]
% [x x x x x]         [potential_ ]
% [x x x x x]       = [potential_ ]
% [x x x x x]         [potential_4]
% [1 1 1 1 1]         [0]

% compute solution for parameters C
% ---------------------------------
meanvalues = mean(values); 
values = values - meanvalues; % make mean zero
C = pinv([Gelec;ones(1,length(Gelec))]) * [values(:);0];

% apply results
% -------------
Res = zeros(1,size(Gsph,1));
for j = 1:size(Gsph,1)
    Res(j) = sum(C .* Gsph(j,:)');
end
Res = Res + meanvalues;
Res = reshape(Res, size(x));

% compute G function
% ------------------
function g = computeg(x,y,z,xelec,yelec,zelec)

unitmat = ones(length(x(:)),length(xelec));
EI = unitmat - ((repmat(x(:),1,length(xelec)) - repmat(xelec,length(x(:)),1)).^2 +... 
                (repmat(y(:),1,length(xelec)) - repmat(yelec,length(x(:)),1)).^2 +...
                (repmat(z(:),1,length(xelec)) - repmat(zelec,length(x(:)),1)).^2)/2;

g = zeros(length(x(:)),length(xelec));
m = 4; % 3 is linear, 4 is best according to Perrin's curve
for n = 1:7
    L = legendre(n,EI);
    g = g + ((2*n+1)/(n^m*(n+1)^m))*squeeze(L(1,:,:));
end
g = g/(4*pi);    

% find electrode indices
% ----------------------
function allinds = elecind( str, chanlocs, values );

    findmax = 0;
    findmin = 0;
    if ~iscell(str)
         if strmatch(str, 'max', 'exact'), findmax = 1; end;
         if strmatch(str, 'min', 'exact'), findmin = 1; end;         
         indunderscore = [ 0 find( str == '_' ) length(str)+1 ];
    else indunderscore = [1:length(str)+1];
    end;
     
    % find maximum or minimum
    % -----------------------
    if findmax, [tmp allinds] = max(values); return; end;
    if findmin, [tmp allinds] = min(values); return; end;
    
    % find indices for labels
    % -----------------------
    labels = lower({ chanlocs.labels });
    for i = 1:length(indunderscore)-1
        if ~iscell(str)
             tmpstr = str(indunderscore(i)+1:indunderscore(i+1)-1);
        else tmpstr = str{i};
        end;
        tmpind = strmatch(lower(tmpstr), labels, 'exact');
        if isempty(tmpind)
            if str2num(tmpstr) > 0
                tmpind = str2num(tmpstr);
            else
                error(sprintf('Could not find channel "%s"', tmpstr));
            end;
        end;
        allinds(i) = tmpind;
    end;
    
        
