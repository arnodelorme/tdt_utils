% plotscalp() - plot scalp map
%
% plotscalp( vals, chanlocs, 'key', 'val');
%
% Input:
%   vals     - values, one per channel
%   chanlocs - channel structure, same size as vals
%
% Optional inputs:
%   colormap  - colormap. Possible values are cool, jet, hsv, ...
%   maplimits - can be [-x x]
%   electrodes - can be 'on', 'off', or 'labels'
%   sphspline  - can be 'on' or 'off'
%
% References:
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
if ~isfield(g, 'sphspline'),  g.sphspline  = 'on';   end;
if ~isfield(g, 'contour'),    g.contour    = 'on';   end;
if ~all(values)
    g.contour = 'off';
    g.sphspline = 'off';
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
	[xsph, ysph, zsph, valsph] = spheric_spline(xelec,yelec,zelec,newvalues); 
    surf(ysph/2,xsph/2,zsph/2,double(valsph), 'edgecolor', 'none'); view([0 0 1]);hold on;
    shading interp;
    
    if strcmpi(g.contour, 'on')
    	[c h] = contour3(ysph/2, xsph/2, valsph, 5); view([0 0 1]);
        set(h, 'cdata', [], 'edgecolor', 'k')
    end;
    
	% coordinates for electrodes
	% --------------------------
    xelec(find(zelec < 0)) = [];
    yelec(find(zelec < 0)) = [];
    x = xelec/2;
    y = yelec/2;
    
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
    if ~all(newvalues), a = zeros(gridres, gridres); 
    else                a = griddata(x, y, newvalues, -ay, ax, 'invdist');
    end;
	aradius = sqrt(ax.^2 + ay.^2);
	indoutcircle = find(aradius(:) > 0.51);
	a(indoutcircle) = NaN;
	surf(-ay, ax, a, 'edgecolor', 'none'); view([0 0 1]); hold on;
	shading interp;

	% plot level lines
	% ----------------
    if strcmpi(g.contour, 'on')
        [c h] = contour3(-ay, ax, a, 5);
        set(h, 'cdata', [], 'edgecolor', 'k')
    end;
end;

% plot electrodes as dots
% -----------------------
top = max(values)*1.5;
if strcmpi(g.electrodes, 'on') | strcmpi(g.electrodes, 'labels')
    rad = sqrt(x.^2 + y.^2);
    x(find(rad > 0.5)) = [];
    y(find(rad > 0.5)) = [];
    plot3( x, y, ones(size(x))*top, 'k.');
    if strcmpi(g.electrodes, 'labels')
        for index = 1:length(x)
            text( x(index)+0.02, y(index), double(top), labls{index});
        end;
    end;
end;

colormap(g.colormap);
if ~isempty(g.maplimits)
    if isstr(g.maplimits)
        tmp = caxis;
        caxis([-max(abs(tmp)) max(abs(tmp))]);
    else
        caxis(g.maplimits);
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
