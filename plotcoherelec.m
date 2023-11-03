% this function plots coherence by masking each electrode one by one
% it assumes a size of 4*5 (19 electrodes) but only the electrodes which
% needs to be plotted are plotted
% Assume a symmetrical matrix

function plotcoherelec( data, eloc, varargin);

if ndims(data) > 2
    error('This function may only process 2-D arrays of size 19x19');
end;

options = varargin;
visible   = 'off';
titleval  = '';
for index = length(options)-1:-2:1
    key = options{index};
    val = options{index+1};
    if strcmpi(key, 'title')
        titleval = val;
        options(index:index+1) = [];
    elseif strcmpi(key, 'visible')
        visible = val;
        options(index:index+1) = [];
    end;
end;

fig = figure('visible', visible);
pos = get(gcf, 'position');
nc = 5;
nr = 4;
newpos = [ pos(1)+15 pos(2)+15 pos(3)*1.5 pos(4)/nc*nr*2.2 ];
newpos = [ max(1,newpos(1)-newpos(3)+pos(3)) max(0, newpos(2)-newpos(4)+pos(4)) newpos(3) newpos(4)];
set(fig, 'position', newpos);
drawnow;

count = 1;
for index = 1:size(data,1)
    dataout = zeros(size(data));
    dataout(index,:) = data(index,:);
    dataout(:,index) = data(:,index);
    mysubplot(5,4,count);
    if any(dataout(:))
        plotcoher(dataout, eloc, varargin{:});
        tmp = title( eloc(index).labels );
        set(tmp, 'unit', 'normalized', 'interpreter', 'none');
        try, set(tmp, 'fontname', 'arial'); catch, end;
        count = count+1;
        axis off;
    end;
end;
tmp = disptitle(titleval);
%topoarray = titletext; eloc = tmp;
set(tmp, 'fontsize', 16, 'interpreter', 'tex');

% subplot in figure
% -----------------
function h = mysubplot(geom1, geom2, coord);
    
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
    
    % add border
    % ----------
    posx   = posx/(1+left_border+right_border)+left_border;
    posy   = posy/(1+top_border+bottom_border)+bottom_border;
    width  = width/(1+left_border+right_border);
    height = height/(1+top_border+bottom_border);
    h = axes('unit', 'normalized', 'position', [ posx posy width height ]);

function h = disptitle(txt)

    ax = axes('Units','Normal','Position',[0 0 1 1], 'Visible','Off');

    tmp = text('Units','normal','String','tmp','Position',[0 0 0]);
    ext = get(tmp,'Extent'); delete(tmp)
    textheight = ext(4);

    x = .5;
    y = 1 - .60*textheight;
    h = text(x,y,txt,'VerticalAlignment','Middle', ...
         'HorizontalAlignment','Center');


