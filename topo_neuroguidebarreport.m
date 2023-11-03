function topo_neuroguidenew(com, fig);

if nargin > 1 && isstr(com)
    tmpuser  = get(fig, 'userdata');
    switch com
        case 'putinlist'
            tmplist1 = get(findobj(fig, 'tag', 'listbox1'), 'string');
            tmplist2 = get(findobj(fig, 'tag', 'listbox2'), 'string');
            tmpval1  = get(findobj(fig, 'tag', 'listbox1'), 'value');
            tmpuser.scale(length(tmplist2)+[1:length(tmpval1)]) = NaN;
            for index = 1:length(tmpval1)
                tmpuser.title{length(tmplist2)+index} = tmplist1{tmpval1(index)};
            end;
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
            tmpuser.scale(tmpval2) = str2double(tmpscale);
        case 'settitle'
            tmpval2  = get(findobj(fig, 'tag', 'listbox2') , 'value');
            tmptitle = get(findobj(fig, 'tag', 'edittitle'), 'string');
            for index = 1:length(tmpval2)
                tmpuser.title{tmpval2(index)} = tmptitle;
            end;
        case 'setlist2'
            tmpval2  = get(findobj(fig, 'tag', 'listbox2'), 'value');
            if ~isempty(tmpval2)
                if ~isempty(tmpuser.scale) && ...
                        (length(unique(tmpuser.scale(tmpval2))) == 1 && ~isnan(tmpuser.scale(tmpval2(1))))
                    for index = 1:length(tmpval2),
                       set(findobj(fig, 'tag', 'editscale'), 'string', num2str(tmpuser.scale(tmpval2(index))));
                    end;
                else
                    set(findobj(fig, 'tag', 'editscale'), 'string', '');                
                end;
                if ~isempty(tmpuser.title) && length(unique(tmpuser.title(tmpval2))) == 1
                    for index = 1:length(tmpval2),
                       set(findobj(fig, 'tag', 'edittitle'), 'string', tmpuser.title{tmpval2(1)});
                    end;
                else
                    set(findobj(fig, 'tag', 'edittitle'), 'string', '');                
                end;
            end;
    end;
    set(fig, 'userdata', tmpuser);
    return;
end;

% select TDT file
% ---------------
[tmpf tmpp] = uigetfile('*.tdt');
if tmpf(1) == 0, return; end;
filename = fullfile(tmpp, tmpf);

% superchoice
% -----------
[ fileinfo choices subchoices ] = gettdtcontent(filename);
count = 1;
for ind1 = 1:length(choices)
    for ind2 = 1:length(subchoices{ind1})
        choicesall{count}    = choices{ind1};
        subchoicesall{count} = subchoices{ind1}{ind2};
        superchoice{count} = [ choices{ind1} ' * ' subchoices{ind1}{ind2} ];
        superindex{count}  = [ ind1 ind2 ];
        count = count+1;
    end;
end;

% pop up window for choosing bands
% --------------------------------
fig = hgload('barreportgui.fig');

% load default options
% --------------------
if exist('defaultopt.mat'), 
    filecontent = load('defaultopt.mat'); 
    userdata.scale = filecontent.scale;
    userdata.title = filecontent.title;
    tmpopt         = filecontent.options;
else
    userdata = [];
    tmpopt   = {};
end;
if ~isempty(tmpopt)
    for index = length(tmpopt):-1:1
        if isempty(strmatch(tmpopt{index}, superchoice))
            tmpopt(index)         = [];
            userdata.scale(index) = [];
            userdata.title(index) = [];
        end;
    end;
end;

% create GUI
% ----------
cmaps = { 'jet' 'hsv' 'hot' 'cool' 'spring' 'summer' 'autumn' 'winter' 'gray' 'boe' 'copper' 'pink' };
set(findobj(fig, 'tag', 'putinlist') , 'callback', 'topo_neuroguidenew(''putinlist'' , gcbf);' );
set(findobj(fig, 'tag', 'rmfromlist'), 'callback', 'topo_neuroguidenew(''rmfromlist'', gcbf);' );
set(findobj(fig, 'tag', 'listbox2'),   'callback', 'topo_neuroguidenew(''setlist2''  , gcbf);' );
set(findobj(fig, 'tag', 'editscale'),  'callback', 'topo_neuroguidenew(''setscale'', gcbf);' );
set(findobj(fig, 'tag', 'edittitle'),  'callback', 'topo_neuroguidenew(''settitle'', gcbf);' );
set(findobj(fig, 'tag', 'listbox1'), 'string', superchoice, 'max', 2, 'min', 0);
set(findobj(fig, 'tag', 'listbox2'), 'string', tmpopt, 'max', 2, 'min', 0);
set(findobj(fig, 'tag', 'colormap'), 'string', cmaps);
set(findobj(fig, 'tag', 'generate'), 'callback', 'set(gcbo, ''userdata'', ''ok'');' );
set(fig,'userdata', userdata);
topo_neuroguidenew('setlist2', fig)

waitfor( findobj(fig, 'tag', 'generate'), 'userdata');

try, findobj(fig); % figure still exist ?
catch, return; end;

userdata  = get(fig, 'userdata');
scale     = userdata.scale;
title     = userdata.title;
options   = get(findobj(fig, 'tag', 'listbox2'),  'string');
computecv = get(findobj(fig, 'tag', 'computecv'), 'value');
savelist  = get(findobj(fig, 'tag', 'savelist'),  'value');
cmap      = cmaps(get(findobj(fig, 'tag', 'colormap'),  'value'));
if savelist
    save defaultopt.mat scale title options;
end;

% return;
% initvals = [];
% initvals = [1 2 3 4 8];
% [s,v] = listdlg('PromptString','Select a property to plot:',...
%               'SelectionMode','single',...
%               'ListString', superchoice, 'ListSize', [300 300], 'selectionmode', 'multiple', 'InitialValue', initvals);
% if v == 0, return; end;

% decoding entries
% ----------------
% previousind = 0;
% countstr    = 0;
% clear subchoicesstr;
% for index = 1:length(s)
%     
%     if superindex{s(index)}(1) ~= previousind
%         countstr                   = countstr + 1;
%         choicestr{countstr}        = choices{   superindex{s(index)}(1)};
%         subchoicesstr{countstr}{1} = subchoices{superindex{s(index)}(1)}{superindex{s(index)}(2)};
%         previousind                = superindex{s(index)}(1);
%         countinds                  = 1;
%     else
%         countinds                          = countinds + 1;
%         subchoicesstr{countstr}{countinds} = subchoices{superindex{s(index)}(1)}{superindex{s(index)}(2)};
%     end;
% 
% end;
for index = 1:length(options)
    optind(index) = strmatch(options{index}, superchoice, 'exact');
end;

countline = 0;
oldtmpchoice = '';
titles = {};
for index = 1:length(options)
    tmpchoice = choicesall{optind(index)};
    tmpi = findstr( tmpchoice, ' by Hz increment');
    if ~isempty(tmpi), tmpchoice = tmpchoice(1:tmpi-1); end;
    tmpi = findstr( tmpchoice, ' by freq. bands');
    if ~isempty(tmpi), tmpchoice = tmpchoice(1:tmpi-1); end;
    if ~strcmpi(oldtmpchoice, tmpchoice), countcol = 1; countline = countline+1; oldtmpchoice = tmpchoice;
    else                                  countcol = countcol+1; end;
    [tmpdata tmpstd elec{countline}] = gettdtdata(filename, tmpchoice, subchoicesall{optind(index)});
    if iscell(tmpdata), tmpdata = [ tmpdata{:} ]; end;
    data{countline}{countcol}   = tmpdata;
    datasd{countline}{countcol} = tmpstd;
    titles{countline}{countcol} = [ tmpchoice ' at ' subchoicesall{optind(index)} ];
end;

% % getting the actual data
% % -----------------------
% for index = 1:length(choicestr)
%     [data{index} datasd{index} elec{index} titles{index}] = gettdtdata(filename, choicesall{optind}, subchoicesall{optind});
%     for tmpi = 1:length(titles{index})
%         titles{index}{tmpi} = [ choicestr{index} ' ' titles{index}{tmpi} ];
%     end;
% end;
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

barreport(data, datasd, elec, titles, scale);
