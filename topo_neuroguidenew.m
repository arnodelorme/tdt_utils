function topo_neuroguidenew(filename, stringtype, varargin )

if nargin > 1 & nargin < 2,
    help topo_neuroguide;
    return;
end

if nargin > 1 && isstr(filename) && ~exist(filename)
    com = filename;
    fig = stringtype;
    try
        tmpuser  = get(fig, 'userdata');
    catch
        error('File not found');
    end

    switch com
        case 'putinlist'
            tmplist1 = get(findobj(fig, 'tag', 'listbox1'), 'string');
            tmplist2 = get(findobj(fig, 'tag', 'listbox2'), 'string');
            tmpval1  = get(findobj(fig, 'tag', 'listbox1'), 'value');
            tmpuser.scale(length(tmplist2)+[1:length(tmpval1)]) = { NaN };
            for index = 1:length(tmpval1)
                tmpuser.title{length(tmplist2)+index} = tmplist1{tmpval1(index)};
            end
            tmplist2 = { tmplist2{:} tmplist1{tmpval1} };
            set(findobj(fig, 'tag', 'listbox2'), 'string', tmplist2);
            set(fig, 'userdata', tmpuser);
            topo_neuroguidenew('setlist2', fig);
            return;
        case 'rmfromlist'
            tmplist2 = get(findobj(fig, 'tag', 'listbox2'), 'string');
            tmpval2  = get(findobj(fig, 'tag', 'listbox2'), 'value');
            tmplist2(tmpval2) = [];
            tmpuser.scale(tmpval2) = [];
            tmpuser.title(tmpval2) = [];
            set(findobj(fig, 'tag', 'listbox2'), 'string', tmplist2, 'value', 1);
            set(fig, 'userdata', tmpuser);
            topo_neuroguidenew('setlist2', fig);
            return;
        case 'setscale'
            tmpval2  = get(findobj(fig, 'tag', 'listbox2'), 'value');
            tmpscale = get(findobj(fig, 'tag', 'editscale'), 'string');
            tmpuser.scale(tmpval2) = { str2num(tmpscale) };
            %if length(tmpuser.scale{tmpval2(1)}) ~= 2, tmpuser.scale(tmpval2) = { NaN }; end
        case 'settitle'
            tmpval2  = get(findobj(fig, 'tag', 'listbox2') , 'value');
            tmptitle = get(findobj(fig, 'tag', 'edittitle'), 'string');
            for index = 1:length(tmpval2)
                tmpuser.title{tmpval2(index)} = tmptitle;
            end
        case 'setlist2'
            tmpval2  = get(findobj(fig, 'tag', 'listbox2'), 'value');
            if ~isempty(tmpval2)
                if ~isempty(tmpuser.scale) && all(~isnan(tmpuser.scale{tmpval2(1)}))
                    if length(tmpuser.scale(tmpval2)) == 1 || isequal(tmpuser.scale{tmpval2})
                        for index = 1:length(tmpval2),
                            set(findobj(fig, 'tag', 'editscale'), 'string', num2str(tmpuser.scale{tmpval2(index)}));
                        end
                    end
                else
                    set(findobj(fig, 'tag', 'editscale'), 'string', '');
                end
                if 0 %~isempty(tmpuser.title) && length(unique(tmpuser.title(tmpval2))) == 1
                    for index = 1:length(tmpval2),
                        set(findobj(fig, 'tag', 'edittitle'), 'string', tmpuser.title{tmpval2(1)});
                    end
                else
                    set(findobj(fig, 'tag', 'edittitle'), 'string', '');
                end
            end
    end
    set(fig, 'userdata', tmpuser);
    return;
elseif nargin > 1 && exist(filename)
    if nargin > 2 && exist(stringtype)
        filename = { filename stringtype };
        stringtype = varargin{1};
        varargin(1) = [];
    else
        filename = { filename };
    end
end

plotflag = 'band';
if length(varargin) > 0
    if isstr(varargin{1})
        if strcmpi(varargin{1}, 'hz') || strcmpi(varargin{1}, 'band')
            plotflag = varargin{1};
            varargin = varargin(2:end);
        end
    end
end

% search for options
% ------------------
opt = struct(varargin{:});
if ~isfield(opt, 'compmode'),  opt.compmode  = 'difference'; end
if ~isfield(opt, 'sqrtpower'), opt.sqrtpower = 'off'; end
if ~isfield(opt, 'logpower'),  opt.logpower  = 'off'; end
if ~isfield(opt, 'threshold'), opt.threshold = []; end

% ask for file name
% -----------------
graphicmode = 0;
if nargin < 1
    [tmpf tmpp] = uigetfile('*.tdt;*.TDT', 'Choose one or two TDT files', 'MultiSelect', 'on');
    if ~iscell(tmpf)
        if tmpf(1) == 0, return; end
    end
    if iscell(tmpf)
        filename{1} = fullfile(tmpp, tmpf{1});
        filename{2} = fullfile(tmpp, tmpf{2});
    else
        filename = { fullfile(tmpp, tmpf) };
    end
    graphicmode = 1;
end

% superchoice
% -----------
[ fileinfo choices subchoices choicesfull] = gettdtcontent(filename{1});
if length(filename) > 1
    [ fileinfo2 choices2 subchoices2 choicesfull2] = gettdtcontent(filename{1});
    [choicesfull tmpi] = intersect(choicesfull, choicesfull2);
    subchoices  = subchoices(tmpi);
    choices     = choices(tmpi);
end
count = 1;
for ind1 = 1:length(choices)
    for ind2 = 1:length(subchoices{ind1})
        choicesall{count}     = choices{ind1};
        choicesallfull{count} = choicesfull{ind1}; % with "by Hz" or "by freq"
        subchoicesall{count}  = subchoices{ind1}{ind2};
        superchoice{count} = [ choices{ind1} ' * ' subchoices{ind1}{ind2} ];
        superindex{count}  = [ ind1 ind2 ];
        count = count+1;
    end
end

% pop up GUI for choosing bands
% -----------------------------
if nargin < 2
    fig = hgload('barreportgui2.fig');

    % load default options
    % --------------------
    if exist('defaultopt.mat'),
        filecontent = load('defaultopt.mat');
        userdata.scale = filecontent.scale;
        userdata.title = filecontent.title;
        tmpopt         = filecontent.options;
    else
        userdata.scale = {};
        userdata.title = {};
        tmpopt   = {};
    end
    if ~isempty(tmpopt)
        for index = length(tmpopt):-1:1
            if isempty(strmatch(tmpopt{index}, superchoice))
                tmpopt(index)         = [];
                userdata.scale(index) = [];
                userdata.title(index) = [];
            end
        end
    end

    % create GUI
    % ----------
    cmaps = { 'jet' 'hsv' 'hot' 'cool' 'spring' 'summer' 'autumn' 'winter' 'gray' 'boe' 'copper' 'pink' 'yellowredblue' 'blueredyellow' 'coolhot' 'bluered' 'redblue' 'jet2' 'hsv2' };
    set(findobj(fig, 'tag', 'putinlist') , 'callback', 'topo_neuroguidenew(''putinlist'' , gcbf);' );
    set(findobj(fig, 'tag', 'rmfromlist'), 'callback', 'topo_neuroguidenew(''rmfromlist'', gcbf);' );
    set(findobj(fig, 'tag', 'listbox2'),   'callback', 'topo_neuroguidenew(''setlist2''  , gcbf);' );
    set(findobj(fig, 'tag', 'editscale'),  'callback', 'topo_neuroguidenew(''setscale'', gcbf);' );
    set(findobj(fig, 'tag', 'edittitle'),  'callback', 'topo_neuroguidenew(''settitle'', gcbf);' );
    set(findobj(fig, 'tag', 'edittitle'), 'enable', 'off');
    set(findobj(fig, 'tag', 'listbox1'), 'string', superchoice, 'max', 2, 'min', 0);
    set(findobj(fig, 'tag', 'listbox2'), 'string', tmpopt, 'max', 2, 'min', 0);
    set(findobj(fig, 'tag', 'colormap'), 'string', cmaps);
    set(findobj(fig, 'tag', 'generate'), 'callback', 'set(gcbo, ''userdata'', ''ok'');' );
    set(fig,'userdata', userdata);
    topo_neuroguidenew('setlist2', fig)

    waitfor( findobj(fig, 'tag', 'generate'), 'userdata');

    try, findobj(fig); % figure still exist ?
    catch, return; end

    userdata  = get(fig, 'userdata');
    scale     = userdata.scale;
    alltitle  = userdata.title;
    options   = get(findobj(fig, 'tag', 'listbox2'),  'string');
    savelist  = get(findobj(fig, 'tag', 'savelist'),  'value');
    opt.sqrtpower = fastif(get(findobj(fig, 'tag', 'sqrtpower'), 'value'), 'on', 'off');
    opt.logpower  = fastif(get(findobj(fig, 'tag', 'logpower'),  'value'),  'on', 'off');
    opt.cmap      = cmaps{ get(findobj(fig, 'tag', 'colormap'),  'value')};
    opt.threshold = str2double( get(findobj(fig, 'tag', 'threshold'),  'string') );
    close(fig);
    if savelist
        save defaultopt.mat scale title options;
    end
    for index = 1:length(options)
        optind(index) = strmatch(options{index}, superchoice, 'exact');
    end

else
    optind = strmatch(stringtype, choicesallfull);

    if isempty(optind)
        error('Could not find selected entry');
    end
end

if length(unique(choicesall(optind))) > 1
    errordlg2('You can only select one type of measure at a time')
    return;
end

countline = 0;
oldtmpchoice = '';
if contains(lower(choicesall{optind(1)}), 'coherence') || contains(lower(choicesall{optind(1)}), 'phase')
    % only one file, copy lines to a new file
    % ---------------------------------------
    tmpchoice = choicesall{optind(1)};
    copytdtdatatosinglefile(filename{1}, tmpchoice, subchoicesall(optind), 'temp.tdt');
else
    for index = 1:length(optind)
        tmpchoice = choicesall{optind(index)};
        tmpi = findstr( tmpchoice, ' by Hz increment');
        if ~isempty(tmpi), tmpchoice = tmpchoice(1:tmpi-1); end
        tmpi = findstr( tmpchoice, ' by freq. bands');
        if ~isempty(tmpi), tmpchoice = tmpchoice(1:tmpi-1); end
        if ~strcmpi(oldtmpchoice, tmpchoice), countcol = 1; countline = countline+1; oldtmpchoice = tmpchoice;
        else                                  countcol = countcol+1; end

        [tmpdata tmpstd elec{countline}] = gettdtdata(filename{1}, tmpchoice, subchoicesall{optind(index)});
        if iscell(tmpdata), tmpdata = [ tmpdata{:} ]; end
        if strcmpi(opt.sqrtpower, 'on')    tmpdata = sqrt(tmpdata);
        elseif strcmpi(opt.logpower, 'on') tmpdata = 10*log10(tmpdata);
        end

        % dealing with two files
        % ----------------------
        if length(filename) > 1
            [tmpdata2 tmpstd elec2] = gettdtdata(filename{2}, tmpchoice, subchoicesall{optind(index)});
            if iscell(tmpdata2), tmpdata2 = [ tmpdata2{:} ]; end
            if ~isequal(elec{countline}, elec2)
                error('Electrode lists must be identical in both files');
            end
            if strcmpi(opt.sqrtpower, 'on'),    tmpdata2 = sqrt(tmpdata2);
            elseif strcmpi(opt.logpower, 'on'), tmpdata2 = 10*log10(tmpdata2);
            end
            tmpdata = tmpdata-tmpdata2;
        end

        data{countline}{countcol}   = tmpdata;
        datasd{countline}{countcol} = tmpstd;
        titles{countline}{countcol} = [ tmpchoice ' at ' subchoicesall{optind(index)} ];
        titlecols{countline}{countcol} = subchoicesall{optind(index)};
    end
end

% get title
% ---------
maintitle = tmpchoice;
tmpi = findstr(lower(maintitle), 'uv sq');
if strcmpi(opt.sqrtpower, 'on')
    if ~isempty(tmpi), maintitle = [ maintitle(1:tmpi-1) '\muV)' ];
    else               maintitle = [ maintitle ' (square root applied)' ];
    end
elseif strcmpi(opt.logpower, 'on')
    if ~isempty(tmpi), maintitle = [ maintitle(1:tmpi-1) '10*log_{10} of \muV^{2})' ];
    else               maintitle = [ maintitle ' (log applied)' ];
    end
else
    if ~isempty(tmpi), maintitle = [ maintitle(1:tmpi-1) '\muV^{2})' ]; end
end

% % getting the actual data
% % -----------------------
% for index = 1:length(choicestr)
%     [data{index} datasd{index} elec{index} titles{index}] = gettdtdata(filename, choicesall{optind}, subchoicesall{optind});
%     for tmpi = 1:length(titles{index})
%         titles{index}{tmpi} = [ choicestr{index} ' ' titles{index}{tmpi} ];
%     end
% end
%
% titles{3} = titles{2};
% titles{2} = titles{1}(5);
% titles{1}(5) = [];
% data{3} = data{2};
% data{2} = data{1}(:,5);
% data{1}(:,5) = [];
% datasd{3} = datasd{2};
% datasd{2} = datasd{1}(:,5);
% datasd{1}(:,5) = [];

% make name for file on disk
% --------------------------
tmpi = find(maintitle == '(');
if ~isempty(tmpi), filetmp = maintitle(1:tmpi(1)-2);
else               filetmp = maintitle;
end
filetmp(find(filetmp == ' ')) = '_';
if length(filename) == 1
    str.fileout   = [ filename{1}(1:end-4) '-' filetmp '.jpg' ];
else
    [tmp tmpf1] = fileparts(filename{1});
    [tmp tmpf2] = fileparts(filename{2});
    str.fileout   = fullfile(tmp, [ tmpf1 '_vs_' tmpf2 '-' filetmp '.jpg' ]);
end

if ~contains(lower(tmpchoice), 'coherence') && ~contains(lower(tmpchoice), 'phase')
    str.data  = [ data{:}{:} ];
    str.data  = reshape(str.data, length(str.data)/length(elec{1}), length(elec{:}))';
    str.title = maintitle;
    str.titlecols = { titlecols{:}{:} };
    str.chanlocs  = asc_readloc('chanlocs10-5.ced', elec{1});
    options = varargin;
    if exist('scale') == 1, options = { 'maplimits', scale, options{:} }; end
    if isfield(opt, 'cmap'), options = { 'colormap', opt.cmap, options{:} }; end
    if nargin < 2, options = { 'visible', 'on', options{:} }; end
    topo_tdt(str, options{:});
    %topo_tdt('temp.tdt', varargin{:}, 'fileout', fileout, 'visible', visible);
    %delete('temp.tdt');
else
    asc_coherplot('temp.tdt', varargin{:}, 'fileout', str.fileout, 'title', maintitle, 'visible', 'on', 'usethreshold', opt.threshold);
    %asc_coherplot(str, options{:});
end

%barreport(data, datasd, elec, titles, scale);

function res = fastif(s1, s2, s3);

if s1, res = s2;
else,  res = s3;
end