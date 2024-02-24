function barreport(data, datasd, elec, titles, maxamp, varargin);

if sum(cellfun(@length, titles)) > 6
    error('Cannot plot more than 6 rows');
end;

ndiv = 4;
nc = 8;
nr = sum(cellfun(@length, titles));

figure;
%figure('numbertitle', 'off', 'menubar', 'none', 'name', 'Bar graph report');
pos = get(gcf,'position');
set(gcf, 'position', [ pos(1) pos(2)+400-600 800 600]);

count = 1;
load('-mat','barreportcmap.mat');
for ind1 = 1:length(data)
    for ind2= 1:size(data{ind1},2)
        eloc = asc_readloc('chanlocs10-5.ced', elec{ind1});

        % plot scalp map
        % --------------
        subplot(nr,nc,[(count-1)*nc+1 (count-1)*nc+2]);
        tmpdata = [ data{  ind1}{:,ind2} ];
        if ~isempty(datasd{ind1}{ind2})
            tmpstd  = [ datasd{ind1}{:,ind2} ];
        else
            tmpstd  = [ data{  ind1}{:,ind2} ]/5;
        end;
        %if ind1 == 1, tmpdata = tmpdata*2; tmpstd = tmpstd*2; end;

        %plotscalp(tmpdata, eloc, 'colormap', mycmap, varargin{:});
        plotscalp(tmpdata, eloc, varargin{:});
        if ~isnan(maxamp(ind1))
             caxis([0 maxamp(ind1)/2]);
        end;
        xlim([-0.6 0.6])
        colorbar;

        % plot bars
        % ----------
        ax = subplot(nr,nc,[(count-1)*nc+3 (count-1)*nc+8]);
        ps = get(ax, 'position');
        set(ax, 'position', [ps(1) ps(2) ps(3) ps(4)*0.8]);
        if ~isempty(tmpstd)
            [tmp ord] = sort([tmpdata+tmpstd]);
            h = bar([tmpdata(ord); tmpstd(ord)]', 0.6, 'stacked');
        else
            [tmp ord] = sort([tmpdata]);
            h = bar([tmpdata(ord)]', 0.6, 'stacked');
        end;
        tmps = size(get(get(h(1), 'children'), 'FaceVertexCData'),1);
        set(get(h(1), 'children'), 'FaceVertexCData', zeros(tmps,3), 'cdatamapping', 'direct')
        set(get(h(2), 'children'), 'FaceVertexCData', [ zeros(tmps,1) ones(tmps,2) ], 'cdatamapping', 'direct')
        xlim([0 length(tmpdata)+1]);
        if ~isnan(maxamp(ind1))
            ylim([0 maxamp(ind1)]); 
        end;
        set(gca, 'xtickmode', 'manual', 'xtick', [1:length(tmpdata)], 'xticklabel', upper({ eloc(ord).labels }));
        set(gca, 'ytick', gridscale(maxamp(ind1)), 'ygrid', 'on', 'gridlinestyle', '-');

    %     if ind1 == 1
    %          set(gca, 'ytick', [0 10 20], 'ygrid', 'on', 'gridlinestyle', '-');
    %     elseif ind1 == 2
    %         set(gca, 'ytick', [0 30 60 90 ], 'ygrid', 'on', 'gridlinestyle', '-');
    %     else
    %         set(gca, 'ytick', [0 5 10 15 20], 'ygrid', 'on', 'gridlinestyle', '-');
    %     end;

        yl = ylim;
        text( 0.5, yl(2)*1.05, [titles{ind1}{ind2} ' - Means and SDs by sensor site' ]);
        %title([titles{ind1}{ind2} ' Means and SDs by sensor site' ]);
        box off
        %title([bands{index} ' means across channels' ]);

        count = count+1;
    end;
end;
set(gcf, 'color', 'w')

function gridval = gridscale(yl);

array = [5 9 15 20 25 30 40 50 60 75 90 100 120 150 160 200 250 300];
ndiv  = [5 3 3  4  5  3  4  5  4  5  3  5   4   3   4   4   5   3 ];
ind   = find( array -yl > 0);
ind   = ind-1;
if isempty(ind) || ind == 0
    gridval = round(linspace(0, yl, 5));
else
    gridval = linspace(0, array(ind), ndiv(ind));
end;
