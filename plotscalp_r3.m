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
%   electrodes - can be 'on' or 'off'

% limitation: does not plot anything below the upper part of the head
function plotscalp(values, chanlocs, varargin);

g = struct(varargin{:});
if ~isfield(g, 'electrodes'), g.electrodes = 'on'; end;
if ~isfield(g, 'colormap'),   g.colormap   = jet;  end;
if ~isfield(g, 'maplimits'),  g.maplimits  = [];   end;
if ~isfield(g, 'sphspline'),  g.sphspline  = 'on';   end;

gridres = 30;
radius = 0.5;
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

if strcmpi(g.sphspline, 'on')
	xelec = [ chanlocs.X ];
	yelec = [ chanlocs.Y ];
	zelec = [ chanlocs.Z ];
	dist = sqrt(xelec.^2+yelec.^2+zelec.^2);
	xelec = xelec./dist;
	yelec = yelec./dist;
	zelec = zelec./dist;
	[xsph, ysph, zsph, valsph] = spheric_spline(xelec,yelec,zelec,newvalues); 
    surf(ysph/2,xsph/2,zsph/2,valsph, 'edgecolor', 'none'); view([0 0 1]);hold on;
    shading interp;
    
    %xsph(1:(length(xsph)-1)/2,:) = [];
    %ysph(1:(length(xsph)-1)/2,:) = [];
    %valsph(1:(length(xsph)-1)/2,:) = [];
	[c h] = contour3(ysph/2, xsph/2, valsph, 5); view([0 0 1]);
	set(h, 'cdata', [], 'edgecolor', 'k')
    
	% plot electrodes as dots
	% -----------------------
	if strcmpi(g.electrodes, 'on')
		top = max(values)*1.5;
		xelec(find(zelec < 0)) = [];
		yelec(find(zelec < 0)) = [];
		plot3( yelec/2, xelec/2, ones(size(xelec))*top, 'k.');
	end;
    
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
	a = griddata(x, y, newvalues, -ay, ax, 'invdist');
	aradius = sqrt(ax.^2 + ay.^2);
	indoutcircle = find(aradius(:) > 0.51);
	a(indoutcircle) = NaN;
	surf(-ay, ax, a, 'edgecolor', 'none'); view([0 0 1]); hold on;
	shading interp;

    % use transparancy instead of surface
    % works but more prone to bugs
    % ----------------------------
	if 0;
        h = imagesc(coords, coords, a); hold on;
        alphadata = ones(size(a,1), size(a,2));
        aradius = sqrt(ax.^2 + ay.^2);
        indoutcircle = find(aradius(:) > 0.495);
        alphadata(indoutcircle) = 0;
        set(h, 'alphadata', alphadata);
	end;
	
	% plot level lines
	% ----------------
	[c h] = contour3(-ay, ax, a, 5);
	set(h, 'cdata', [], 'edgecolor', 'k')

	% plot electrodes as dots
	% -----------------------
	if strcmpi(g.electrodes, 'on')
		top = max(values)*1.5;
		rad = sqrt(x.^2 + y.^2);
		x(find(rad > 0.5)) = [];
		y(find(rad > 0.5)) = [];
		plot3( x, y, ones(size(x))*top, 'k.');
	end;
    
end;


% remove outside patches
% not necessary with NaN in a
% ----------------------------
if 0
    for index = 1:length(h)
        tmpx  = get(h(index), 'xdata');
        tmpy  = get(h(index), 'ydata');
        tmpz  = get(h(index), 'zdata');
        vert  = get(h(index), 'vertices');
        faces = get(h(index), 'faces');
        vertnormal = get(h(index), 'vertexnormals');
        rad  = sqrt(tmpx.^2 + tmpy.^2);
        ind  = find(rad > 0.5);
        [th rd] = cart2pol(tmpx(ind), tmpy(ind));
        [tmpx(ind) tmpy(ind)] = pol2cart(th, 0.5);
        if ~isempty(tmpx)
            set(h(index), 'xdata', tmpx, 'ydata', tmpy, 'vertices', [tmpx tmpy tmpz]);
        end;
	end;
end;

colormap(g.colormap);
if ~isempty(g.maplimits)
    caxis(g.maplimits);
end;

% main circle
% -----------
plot3(xx,yy,ones(size(xx))*top, 'k', 'linewidth', 2); hold on;

% ears & nose
% -----------
earx  = [0.4960    0.505    0.520    0.530    0.540    0.533   0.550    0.543    0.530   0.500    0.490]; % rmax = 0.5
eary  = [0.0655    0.0855   0.086    0.082    0.066    0.015   -0.073   -0.09   -0.11   -0.115   -0.1];
plot3(earx,eary,ones(size(earx))*top,'color','k','LineWidth',2)    % plot left ear
plot3(-earx,eary,ones(size(earx))*top,'color','k','LineWidth',2)   % plot right ear

nosex = [0.0900 0.0400 0.010 0 -0.010 -0.0400 -0.0900];
nosey = [0.492  0.5300 0.5700 0.570 0.5700 0.5300 0.492 ];
plot3(nosex, nosey, ones(size(nosex))*top,'color','k','LineWidth',2)   % plot right ear
axis equal

axis off;
set(gca, 'ydir', 'normal');
ylim([-0.6 0.6]);

% ----------------
% spherical spline
% ----------------
function [x, y, z, P] = spheric_spline( Xe, Ye, Ze, values);

SPHERERES = 40;
[x,y,z] = sphere(SPHERERES);
x(1:(length(x)-1)/2,:) = [];
y(1:(length(x)-1)/2,:) = [];
z(1:(length(x)-1)/2,:) = [];

gx = calc_gx(x,y,z,Xe,Ye,Ze);
G = calc_gx(Xe,Ye,Ze,Xe,Ye,Ze);

% equations are 
% GC + C0  = Potential (C unknow)
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

meanval = mean(values); values = values - meanval; % make mean zero

% compute solution for parameters C
% ---------------------------------
lamd = 0.1;
C = pinv([(G + lamd);ones(1,length(G))]) * [values(:);0]; % fixing division error

% apply results
% -------------
P = zeros(1,size(gx,1));
for j = 1:size(gx,1)
    P(j) = dot(C,gx(j,:));
end
P = P + meanval;
P = reshape(P, size(x));

function gx = calc_gx(x,y,z,Xe,Ye,Ze)

onemat = ones(length(x(:)),length(Xe));
EI = onemat -     ((repmat(x(:),1,length(Xe)) - repmat(Xe,length(x(:)),1)).^2 +... 
                   (repmat(y(:),1,length(Xe)) - repmat(Ye,length(x(:)),1)).^2 +...
                   (repmat(z(:),1,length(Xe)) - repmat(Ze,length(x(:)),1)).^2)/2;
%
gx = zeros(length(x(:)),length(Xe));
m = 4; % 3 is linear
for n = 1:7
    L = legendre(n,EI);
    gx = gx + ((2*n+1)/(n^m*(n+1)^m))*squeeze(L(1,:,:));
end
gx = gx/(4*pi);    
