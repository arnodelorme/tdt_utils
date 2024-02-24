function barreport(data, datasd, elec, titles, scales, varargin);

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
    eloc = asc_readloc('chanlocs10-5.ced', elec{ind1});
    for ind2 = 1:size(data{ind1},2)
    
        % plot scalp map
        % --------------
        subplot(nr,nc,[(count-1)*nc+1 (count-1)*nc+2]);
        tmpdata = [ data{  ind1}{:,ind2} ];
        if ~isempty(datasd{ind1})
            tmpstd  = [ datasd{ind1}{:,ind2} ];
        else
            tmpstd  = [ data{  ind1}{:,ind2} ]/5;
        end;
        %if ind1 == 1, tmpdata = tmpdata*2; tmpstd = tmpstd*2; end;
        
        %plotscalp(tmpdata, eloc, 'colormap', mycmap, varargin{:});
        plotscalp(tmpdata, eloc, varargin{:});
        if ind1 == 1
             caxis([0 maxamp(ind1)/2]);
        else caxis([0 maxamp(ind1)/2]);
        end;
        xlim([-0.6 0.6])
        colorbar;

        % plot bars
        % ----------
        ax = subplot(nr,nc,[(count-1)*nc+3 (count-1)*nc+8]);
        ps = get(ax, 'position');
        set(ax, 'position', [ps(1) ps(2) ps(3) ps(4)*0.8]);
        [tmp ord] = sort([tmpdata+tmpstd]);
        h = bar([tmpdata(ord); tmpstd(ord)]', 0.6, 'stacked');
        tmps = size(get(get(h(1), 'children'), 'FaceVertexCData'),1);
        set(get(h(1), 'children'), 'FaceVertexCData', zeros(tmps,3), 'cdatamapping', 'direct')
        set(get(h(2), 'children'), 'FaceVertexCData', [ zeros(tmps,1) ones(tmps,2) ], 'cdatamapping', 'direct')
        xlim([0 length(tmpdata)+1]);
        ylim([0 maxamp(ind1)]); 
        set(gca, 'xtickmode', 'manual', 'xtick', [1:length(tmpdata)], 'xticklabel', upper({ eloc(ord).labels }));
        if ind1 == 1
             set(gca, 'ytick', [0 10 20], 'ygrid', 'on', 'gridlinestyle', '-');
        elseif ind1 == 2
            set(gca, 'ytick', [0 30 60 90 ], 'ygrid', 'on', 'gridlinestyle', '-');
        else
            set(gca, 'ytick', [0 5 10 15 20], 'ygrid', 'on', 'gridlinestyle', '-');
        end;
        
        yl = ylim;
        text( 0.5, yl(2)*1.05, [titles{ind1}{ind2} ' Means and SDs by sensor site' ]);
        %title([titles{ind1}{ind2} ' Means and SDs by sensor site' ]);
        box off
        %title([bands{index} ' means across channels' ]);
        
        count = count+1;
    end;
end;
set(gcf, 'color', 'w')
