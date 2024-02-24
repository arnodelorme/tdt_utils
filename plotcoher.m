% plotcoher() - plot coher map
%
% plotcoher( vals, chanlocs );
%
% Input:
%   vals         - values, one column per channel and one row per channel
%   chanlocs     - channel structure, same size as vals
%   usethreshold - treshold to plot coherence values
%
% Exemple:
%   figure; plotcoher(normrnd(0, 0.7, EEG.nbchan,EEG.nbchan), EEG.chanlocs);

function plotcoher(array, chanlocs, varargin)

radius = 0.5;
linewidth = 1;
%threshold = [1.6449 2.3263 3.0902];
threshold = [0.7 0.8 0.9];
pnts = linspace(0,2*pi,200);
xx = sin(pnts)*radius;
yy = cos(pnts)*radius;

% settings
% --------
g = struct(varargin{:});
try, g.maxcoh;     catch, g.maxcoh   = max(max(abs(array))); end;
try, g.colormap;   catch, g.colormap = 'bluered'; end;
try, g.electrodes; catch, g.electrodes = 'off'; end;
try, g.usethreshold; catch, g.usethreshold = 0; end;
if isempty(g.usethreshold), g.usethreshold = 0; end;
if isnan(g.usethreshold), g.usethreshold = 0; end;
allcurvevals = read_curve(chanlocs);
if strcmpi(g.colormap, 'bluered'), cmap = redbluecmap; cmap = cmap(end:-1:1,:);
else                               cmap = yellowredbluecmap;
end;    

% find channel coordinates
% ------------------------
emptyvals = cellfun('isempty', { chanlocs.theta }); 
th = [ chanlocs.theta ];
rd = [ chanlocs.radius ];
[y x] = pol2cart(th/180*pi, rd); x=-x;
array(emptyvals,:) = [];
array(:,emptyvals) = [];
labls = { chanlocs.labels }; 
labls(emptyvals) = [];
elec1 = { labls };
elec2 = { labls };

% determine line thickness and polarity
% -------------------------------------
array2 = zeros(size(array));
tmpind = find(array(:) > threshold(3)); array2(tmpind) = 1;
tmpind = find(array(:) > threshold(2)); array2(tmpind) = array2(tmpind)+1;
tmpind = find(array(:) > threshold(1)); array2(tmpind) = array2(tmpind)+1;
tmpind = find(array(:) < -threshold(3)); array2(tmpind) = -1; 
tmpind = find(array(:) < -threshold(2)); array2(tmpind) = array2(tmpind)-1;
tmpind = find(array(:) < -threshold(1)); array2(tmpind) = array2(tmpind)-1;

plotscalp(zeros(1,length(chanlocs)), chanlocs, 'electrodes', 'off', 'blank', 'on');

% make lines between pairs of electrodes
% --------------------------------------
warning off;
read = 1;
for ind1 = 1:size(array2,1)
    for ind2 = 1:size(array2,2)
        if ind1 ~= ind2
            if abs(array(ind1, ind2)) >= g.usethreshold

                % color and thickness
                % -------------------
                thickness = abs(array2(ind1, ind2)); if thickness == 0, thickness = 0.5; end;
                if strcmpi(g.colormap, 'blueredonly')
                    if array2(ind1, ind2) < 0, color = 'b'; else color = 'r'; end;
                else
                    color = cmap(round(max(-1,min(array(ind1, ind2)/g.maxcoh,1))*31)+32,:);
                    %thickness = round(array(ind1, ind2)/g.maxcoh*3);
                end;   

                % get curvature and plot
                % ----------------------
                if read
                    curve = allcurvevals(ind1, ind2);
                else
                    elecx = [x(1:min(ind1,ind2)-1) x(min(ind1,ind2)+1:max(ind1,ind2)-1) x(max(ind1,ind2)+1:end) ];
                    elecy = [y(1:min(ind1,ind2)-1) y(min(ind1,ind2)+1:max(ind1,ind2)-1) y(max(ind1,ind2)+1:end) ];
                    if disterror(0, x(ind1), y(ind1), x(ind2), y(ind2), elecx, elecy) > 0.95
                         eval('curve = fminbnd(@disterror, -0.1, 0.1, [], x(ind1), y(ind1), x(ind2), y(ind2), elecx, elecy);');
                    else curve = 0;
                    end;
                end;
                [cx cy] = plotortho([x(ind1), y(ind1)],[x(ind2), y(ind2)], curve);
                if thickness
                    [arcx arcy] = plotarc([x(ind1), y(ind1)], [x(ind2), y(ind2)], [cx cy], 'color', color, ...
                        'linewidth', thickness);
                end;
                %line([x(ind1) x(ind2)]', [y(ind1) y(ind2)]', 'color', color, ...
                %    'linewidth', abs(array2(ind1, ind2))); hold on;
                % bended lines necessary
            end;
        end;
    end;
end;
warning on;

% replot electrodes as dots
% -------------------------
top = 0;
rad = sqrt(x.^2 + y.^2);
x(find(rad > 0.5)) = [];
y(find(rad > 0.5)) = [];
plot3( x, y, ones(size(x))*top, 'k.');
hold on;
if strcmpi(g.electrodes, 'labels')
    for index = 1:length(x)
        text( x(index)+0.02, y(index), top, labls{index});
    end;
end;
view([0 0 1]);

% read curvature file
% -------------------
function curve = read_curve(chanlocs)

curve = zeros(length(chanlocs), length(chanlocs));
[chans headerlines nc, res] = asc_readheader('curvature.txt');
if res == -1, return; end;
[tmpdata res] = asc_readdata('curvature.txt',headerlines,nc);
if res == -1, return; end;

labls = lower({ chanlocs.labels });
chans = lower(chans);
for i=1:length(chanlocs)
    ind1 = strmatch(labls{i}, chans, 'exact');
    for j=1:length(chanlocs)
        ind2 = strmatch(labls{j}, chans, 'exact');
        if ~isempty(ind1) & ~isempty(ind2)
            curve(i,j) = tmpdata(ind1, ind2);
        end;
    end;
end;

