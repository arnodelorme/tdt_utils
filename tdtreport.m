% TDTREPORT - graphic interface to compute Lexicor measures
%
% Usage:
%   >> measures = tdtreport; % pop up window to input arguments
%   >> measures = tdtreport('file.asc', 'key', val, ...);
%   >> measures = tdtreport(EEG, 'key', val, ...);
%
% Inputs:
%   'file.asc' - File in the ASCII format
%   EEG        - Continuous EEGLAB dataset
%
% Optional inputs:
% 'banddefs'      - [cell or string] frequency band definition or text file
%                   containing frequency band definition. See file 
%                   'banddef.txt' for an example.
% 'exportbands    - ['on'|'off'] 'on' will add the band frequency limits in
%                   addition to the band names to the table header. Default
%                   is 'on'.
% 'exporthz'      - ['on'|'off'] 'on' will export values at every single
%                   frequency output with 1 Hz increment.
% 'computesd'     - ['on'|'off'] 'on' will compute standard deviation in
%                   addition to the mean.
% 'fftlen'        - [float] length of the FFT window in seconds (default is
%                   1). Note that if the length of the data is not an exact 
%                   multiplier of the window length, the last partial
%                   chunck of data is ignored.
% 'overlap'       - [float] overlap beween windown in seconds (default is 0)
% 'latency'       - [float] onset of the data in seconds (default is 0 which
%                   is the beginning).
% 'duration'      - [float] offset of the data in seconds (default is Inf
%                   which is the end).
% 'reorderchannels' - ['on'|'off'] 'on' will reorder channels according to the
%                   Lexicor convention and only keep Lexicor channels 
%                   (default is 'off')
% 'exportlist'    - [cell] list of measures to export. The choices are:
%                   'FFT Absolute Power (uV Sq)'
%                   'FFT peak frequencies'
%                   'FFT Relative Power (%)'
%                   'FFT peak amplitudes'                 
%                   'FFT Coherence'
%                   'FFT Phase Lag (Deg)'
% 'fileout'       - [string] name of the output file. By default, it is the
%                   name of the EEG dataset or input file with 'report.tdt'
%                   added at the end. Enter empty '' if you do not want to
%                   save any file.
% 'measuresin'    - [struct] input measure structure where the new measures
%                   from this function are concatenated. Default is empty.
%
% Output:
%   measures  - [struct] structure containing all the output measures
%
% Examples:
%
% % compute FFT absolute power on the default EEGLAB dataset
% eeglab cont
% tdtreport(EEG, 'exportlist', { 'FFT Absolute Power (uV Sq)' });
%
% % compute all measures on the default EEGLAB dataset for delta and theta
% banddefs = { 'delta' 1 4; 'theta' 4 8 };
% tdtreport(EEG, 'banddefs', banddefs);

function measures = tdtreport(filein, varargin)

% constants
srate = 250; 
channel_order = { 'FP1' 'FP2' 'F7' 'F8' 'F3' 'F4' 'T3' 'T4' 'C3' 'C4' 'T5' 'T6' 'P3' 'P4' 'O1' 'O2' 'Fz' 'Cz' 'Pz' };
export_options = { 'FFT Absolute Power (uV Sq)' ...
                   'FFT peak frequencies' ...
                   'FFT Relative Power (%)' ...
                   'FFT peak amplitudes' ...                   
                   'FFT Coherence' ...
                   'FFT Phase Lag (Deg)' };
               
%                    'Z Scored FFT Absolute Power' ...
%                    'Z Scored FFT Relative Power' ...
%                    'Z Scored FFT Power Ratio' ...
%                    'Z Scored FFT Amplitude Asymmetry' ...
%                    'Z Scored FFT Coherence' ...
%                    'Z Scored FFT Phase Lag' ...
%                    'FFT Power Ratio' ...

if nargin < 2 
    if nargin >= 1 && isstruct(filein) && ~isempty(filein)
       ButtonName = questdlg( [ 'Do you want to process the current dataset' 10 'or load a new one (EDF or ASC format' ], ...
                         '', 'Load', 'Use current', 'Use current');
        if strcmpi(ButtonName, 'Load')
            filein = [];
        end
    else
        filein = [];
    end
    if isempty(filein)
        [tmpf, tmpp] = uigetfile({'*.*'}, 'Pick an ASC or EDF file');
        if tmpf(1) == 0, return; end
        filein = fullfile(tmpp, tmpf);
    end

    fig = hgload('lexfig.fig');
    cb_loadbands = [ '[tmpf tmpp] = uigetfile(''*.*'', ''Pick a text file containing band definition'');' ...
                     'if tmpf(1) ~= 0,' ...
                     '    tdtreport(gcbf, ''loadbands'', fullfile(tmpp, tmpf));' ...
                     'end;' ...
                     'clear tmpf tmpp;' ];
                   
    set(findobj(fig, 'tag', 'pushbutton2'), 'callback', cb_loadbands);
    set(findobj(fig, 'tag', 'pushbutton1'), 'callback', 'set(gcbo, ''userdata'', ''ok'');' );
    set(findobj(fig, 'tag', 'listbox1'), 'string', export_options, 'max', 2, 'min', 0);
    tdtreport(fig, 'loadbands', []);

	waitfor( findobj(fig, 'tag', 'pushbutton1'), 'userdata');
    
    try
        res = findobj(fig); % figure still exist ?
        if isempty(res)
            return
        end
    catch, return; end
    
    % get output from GUI
    % -------------------
    listvals  = get(findobj(fig, 'tag', 'listbox1'),  'value');
    valbdexp  = get(findobj(fig, 'tag', 'checkbox1'), 'value');
    valhzexp  = get(findobj(fig, 'tag', 'checkbox2'), 'value');
    vachan    = get(findobj(fig, 'tag', 'checkbox4'), 'value');
    fftlen    = str2num(get(findobj(fig, 'tag', 'fftlen'  ), 'string'));
    overlap   = str2num(get(findobj(fig, 'tag', 'overlap' ), 'string'));
    latency   = str2num(get(findobj(fig, 'tag', 'latency' ), 'string'));
    duration  = str2num(get(findobj(fig, 'tag', 'duration'), 'string'));
    
    options = { 'exportlist' export_options(listvals) 'fftlen' fftlen 'overlap' overlap };
    if ~valbdexp, options = { options{:} 'exportbands' 'off' }; end
    if ~valhzexp, options = { options{:} 'exporthz'    'off' }; end
    if get(findobj(fig, 'tag', 'computesd'), 'value') == 1
        options = { options{:} 'computesd' 'on' }; 
    end
    
    % get power band values
    % ---------------------
    count = 1;
    for rows = 1:12
        for col = 1:3
            bands{count} = get(findobj(fig, 'tag', [ 'edit' int2str(count) ]), 'string');
            if col > 1, bands{count} = str2num(  bands{count} ); end
            count = count+1;
        end
    end
    bands = reshape(bands, 3, 12)';
    options = { options{:} 'banddefs' bands };
    close(fig);
elseif ~isstr(filein)
    fig = filein;
    command = varargin{1};

    if ischar(varargin{1}) && strcmpi(varargin{1}, 'loadbands')
        filename = varargin{2};
        if isempty(filename)
            filename = 'banddef.txt';
        end
        bands = myloadband(filename);

        % write bands to GUI
        bands{13,1} = [];
        bands = bands(1:12,:);
        bands = bands';
        for index = 1:length(bands(:))
            obj = findobj(fig, 'tag', [ 'edit' int2str(index) ]);
            set(obj, 'string', num2str(bands{index}));
        end
        return;
    end
    options = varargin;
else
    options = varargin;
end

% decode arguments
opt = struct;
if ~isempty(options)
    for iOpt = 1:length(options)
        if iscell(options{iOpt})
            options{iOpt} = {options{iOpt}};
        end
    end
    try   opt = struct(options{:});
    catch error('Wrong ''key'', val, sequence');
    end
end
vachan = false;
defaultopt.banddefs    = 'banddef.txt';
defaultopt.exportbands = 'on';
defaultopt.exporthz    = 'on';
defaultopt.computesd   = 'off';
defaultopt.fftlen      = 1;
defaultopt.overlap     = 0;
defaultopt.fileout     = 'auto';
defaultopt.latency     = 0;
defaultopt.duration    = Inf;
defaultopt.measuresin  = [];
defaultopt.reorderchannels = fastif(vachan, 'on', 'off');
defaultopt.exportlist  = export_options;
fieldsopt   = fieldnames(defaultopt);
errorfields = setdiff(fieldnames(opt), fieldsopt);
if ~isempty(errorfields), error([ 'Unknown option field ''' errorfields{1} '''' ]); end
for i=1:length(fieldsopt)
    if ~isfield(opt, fieldsopt{i}), opt = setfield(opt, fieldsopt{i}, getfield(defaultopt, fieldsopt{i})); end
end
if isstr(opt.exportlist), opt.exportlist = { opt.exportlist }; end
if ischar(opt.banddefs)
    opt.banddefs = myloadband(opt.banddefs);
end

% load the data file
% ------------------
%filein = 'C:\Documents and Settings\delorme\My Documents\R_lawson\256_nsync.rec\256_nsync.rec.data';
if ~isstruct(filein)
    if strcmpi(filein(end-2:end), 'asc')
        [chans, headerlines, nc] = asc_readheader(filein);
        [tmpdata] = asc_readdata(filein,headerlines,nc);
    else
        if ~exist(filein), error('Cannot find file'); end
        EEG = pop_biosig(filein);
        tmpdata = EEG.data;
        chans   = { EEG.chanlocs.labels };
    end
else
    EEG = filein;
    EEG = pop_resample(EEG, srate);
    filein = fullfile(EEG.filepath, EEG.filename);
    tmpdata = EEG.data;
    chans   = { EEG.chanlocs.labels };
end
if isequal(opt.fileout, 'auto')
    [tmpp, fileout] = fileparts(filein);
    opt.fileout = [ fileout '_report.tdt' ];
    opt.fileout = fullfile(tmpp, opt.fileout);
end

% reorder channels the lexicor way (some channels may be missing)
% ---------------------------------------------------------------
if strcmpi(defaultopt.reorderchannels, 'on')
    disp('Reordering channels...')
    [~, b, c]  = intersect(lower(chans), lower(channel_order));
    [~, cc] = sort(c);
    neworder = b(cc);
    if length(neworder) < length(chans)
        disp('Warning: some Lexicor channels were not found');
    end
    chans    = chans( neworder );
    tmpdata = tmpdata(neworder,:);
end
%lastchans = setdiff(1:length(chans), neworder); % add remaining channels
%chans    = chans([ neworder lastchans ]);

% get band values
% ---------------
indempty = find(cellfun(@isempty, opt.banddefs(:,1)));
if ~isempty(indempty)
    opt.banddefs(indempty(1):end,:) = [];
end
banddefs = [ opt.banddefs{:,2:end} ];
banddefs = reshape(banddefs, length(banddefs)/2,2);

% extract data
% ------------
tmpdata = tmpdata(:, round(opt.latency*srate)+1:min(round((opt.latency+opt.duration)*srate), size(tmpdata,2)));
%     maxpnts = floor(size(tmpdata,2)/(opt.fftlen*srate))*srate*opt.fftlen;
%     tmpdata(:,maxpnts+1:end) = [];
%     tmpdata = reshape(tmpdata,size(tmpdata,1), srate*opt.fftlen, size(tmpdata,2)/(srate*opt.fftlen));
newdata = zeros(size(tmpdata,1), round(srate*opt.fftlen), floor(size(tmpdata,2)/round(srate*(opt.fftlen-opt.overlap))));
indeeg  = 1;
counttrial = 1;
while indeeg+round(srate*opt.fftlen) < size(tmpdata,2)
    newdata(:,:,counttrial) = tmpdata(:,indeeg:(indeeg+round(srate*opt.fftlen)-1));
    indeeg     = indeeg+round(srate*(opt.fftlen-opt.overlap));
    counttrial = counttrial+1;
end
tmpdata = newdata;

% generate values for file report
% -------------------------------
if ~isempty(opt.fileout)
    fid = fopen(opt.fileout, 'w');
    fprintf('Writing file %s\n', opt.fileout)
    if fid == -1, return; end
    fprintf(fid, '\n'); % important to topo_neuroguide
else
    fid = NaN;
end
f_hz = strcmpi(opt.exporthz, 'on'); 
f_bd = strcmpi(opt.exportbands, 'on'); 
f_sd = strcmpi(opt.computesd, 'on');
measures = opt.measuresin;
for index = 1:length(opt.exportlist)
    switch opt.exportlist{index}
        case 'FFT Absolute Power (uV Sq)'
            [magval, freqs, bandvals, bandsd]  = fftamplitude(tmpdata, srate, banddefs);
            if f_sd, stdmagvals = std(magval,[],3); else stdmagvals = []; end
            if f_sd, stdbdvals  = bandsd';          else stdbdvals  = []; end
            if f_hz,        myprintf(fid, measures, opt.exportlist{index}, mean(magval,3), stdmagvals, chans, freqs); end
            if f_bd,        myprintf(fid, measures, opt.exportlist{index}, bandvals'     , stdbdvals,  chans, opt.banddefs); end
        case 'FFT Relative Power (%)'        
            [magval, freqs, bandvals, bandsd]  = fftmagnitude(tmpdata, srate, banddefs);
            if f_sd, stdmagvals = std(magval,[],3); else stdmagvals = []; end
            if f_sd, stdbdvals  = bandsd';          else stdbdvals  = []; end
            if f_hz,        measures = myprintf(fid, measures, opt.exportlist{index}, mean(magval,3), stdmagvals, chans, freqs); end
            if f_bd,        measures = myprintf(fid, measures, opt.exportlist{index}, bandvals'     , stdbdvals,  chans, opt.banddefs); end
        case 'FFT Coherence'
            if strcmpi(opt.exporthz,    'on')
                [lexcoh, freqs, lexstd ] = lexcoherence(tmpdata, srate);
                if ~f_sd, lexstd = []; end
                measures = myprintfcoh(fid, measures, opt.exportlist{index}, lexcoh, lexstd, chans, freqs); 
            end
            if strcmpi(opt.exportbands, 'on')
                [lexcoh, freqs, lexstd ] = lexcoherence(tmpdata, srate, banddefs);
                if ~f_sd, lexstd = []; end
                measures = myprintfcoh(fid, measures, opt.exportlist{index}, lexcoh, lexstd, chans, opt.banddefs); 
            end
        case 'FFT Phase Lag (Deg)' 
            if strcmpi(opt.exporthz,    'on')
                [lexphaseres,freqs] = lexphase(tmpdata, srate);
                measures = myprintfcoh(fid, measures, opt.exportlist{index}, lexphaseres, [], chans, freqs); 
            end
            if strcmpi(opt.exportbands, 'on')
                lexphaseres = lexphase(tmpdata, srate, banddefs);
                measures = myprintfcoh(fid, measures, opt.exportlist{index}, lexphaseres, [], chans, opt.banddefs); 
            end
        case 'FFT peak frequencies' 
            [magval, freqs, bandvals, bandsd] = fftpeakfreq( tmpdata, srate, banddefs);
            if f_sd, stdmagvals = std(magval,[],3); else stdmagvals = []; end
            if f_sd, stdbdvals  = bandsd';          else stdbdvals  = []; end
            if f_hz,        measures = myprintf(fid, measures, opt.exportlist{index}, mean(magval,3), stdmagvals, chans, freqs); end
            if f_bd,        measures = myprintf(fid, measures, opt.exportlist{index}, bandvals'     , stdbdvals,  chans, opt.banddefs); end
        case 'FFT peak amplitudes' 
            [magval, freqs, bandvals, bandsd] = fftpeakamp(  tmpdata, srate, banddefs);
            if f_sd, stdmagvals = std(magval,[],3); else stdmagvals = []; end
            if f_sd, stdbdvals  = bandsd';          else stdbdvals  = []; end
            if f_hz,        measures = myprintf(fid, measures, opt.exportlist{index}, mean(magval,3), stdmagvals, chans, freqs); end
            if f_bd,        measures = myprintf(fid, measures, opt.exportlist{index}, bandvals'     , stdbdvals,  chans, opt.banddefs); end
    end
end
disp('Done.')
fclose all;

% load freq. band file
% --------------------
function str = myloadband(filename)
    
    str = table2cell(readtable(filename));
    
% write into file
% ---------------
function measures = myprintf(fid, measures, arraytitle, values, valuestd, elecs, bands)

    tmpField = rename_field(arraytitle, bands);
    measures.(tmpField).mean    = values;
    measures.(tmpField).labels  = elecs;
    measures.(tmpField).labels2 = bands2str(bands);

    if ~isempty(valuestd)
        measures.([ tmpField '_std' ]).mean    = valuestd;
        measures.([ tmpField '_std' ]).labels  = elecs;
        measures.([ tmpField '_std' ]).labels2 = bands2str(bands);
    end

    if isnan(fid), return; end

    % print header line
    % -----------------
    fprintf(fid, '%s\n\n', arraytitle); % print title
    if iscell(bands)
        fprintf('Writing to file "%s" (freq. band values)\n', arraytitle)
        for band = 1:size(bands,1)
            fprintf(fid, '\t%s', bands{band,1});
        end
        fprintf(fid, '\n');
        for band = 1:size(bands,1)
            fprintf(fid, '\t%1.1f Hz - %1.1f Hz', bands{band,2}, bands{band,3});
        end
    else
        fprintf('Writing to file "%s" (Hz values)\n', arraytitle)
        for band = 1:length(bands)
            fprintf(fid, '\t%d Hz', bands(band));
        end
    end
    fprintf(fid, '\n');
    
    % write data
    % ----------
    for elec = 1:length(elecs)
        fprintf(fid, '%s', elecs{elec});
        if iscell(bands)
            nbands = size(bands,1);
        else
            nbands = length(bands);
        end
        for band = 1:nbands
            fprintf(fid, '\t%3.2f', values(elec,band));
        end
        if ~isempty(valuestd)
            for band = 1:nbands
                fprintf(fid, '\t%3.2f', valuestd(elec,band));
            end
        end
            
        fprintf(fid, '\n');
    end
    fprintf(fid, '\n'); % final traler line


% write into file
% ---------------
function measures = myprintfcoh(fid, measures, arraytitle, values, valstd, elecs, bands)

    if size(bands,1) > size(values,3)
        bands = bands(1:size(values,3),:);
    end
    
    tmpBand = bands2str(bands);
    for iBand = 1:length(tmpBand)
        tmpField = [ rename_field(arraytitle, bands) '_' tmpBand{iBand} ];
        measures.(tmpField).mean    = values(:,:,iBand);
        measures.(tmpField).labels  = elecs;
        measures.(tmpField).labels2 = elecs;
    
        if ~isempty(valstd)
            measures.([ tmpField '_std' ]).mean    = valstd(:,:,iBand);
            measures.([ tmpField '_std' ]).labels  = elecs;
            measures.([ tmpField '_std' ]).labels2 = elecs;
        end
    end

    if isnan(fid), return; end

    % print header line
    % -----------------
    fprintf(fid, '%s\n\n', arraytitle); % print title
    if iscell(bands)
        fprintf('Writing to file "%s" (freq. band values)\n', arraytitle)
        fprintf(fid, '\t');
        for band = 1:size(bands,1)
            fprintf(fid, '\t%s', bands{band,1});
        end
        fprintf(fid, '\n\t');
        for band = 1:size(bands,1)
            fprintf(fid, '\t%1.1f Hz - %1.1f Hz', bands{band,2}, bands{band,3});  % x.x Hz important to topo_neuroguide
        end
    else
        fprintf('Writing to file "%s" (Hz values)\n', arraytitle)
        fprintf(fid, '\t');
        for band = 1:length(bands)
            fprintf(fid, '\t%d Hz', bands(band));
        end
    end
    fprintf(fid, '\n');
    
    % write data
    % ----------
    if iscell(bands)
        nbands = size(bands,1);
    else
        nbands = length(bands);
    end
    for elec1 = 1:length(elecs)
        for elec2 = elec1+1:length(elecs)
            fprintf(fid, '%s\t%s', elecs{elec1},  elecs{elec2});
            for band = 1:nbands
                fprintf(fid, '\t%3.2f', values(elec2,elec1,band));
            end
            if ~isempty(valstd)
                for band = 1:nbands
                    fprintf(fid, '\t%3.2f', valstd(elec2,elec1,band));
                end
            end
            fprintf(fid, '\n');
        end
    end
    fprintf(fid, '\n'); % final traler line

% rename title so it can fit in a structure
function str = rename_field(str, bands)

    str(str == '(') = [];
    str(str == ')') = [];
    str(str == ' ') = '_';
    if any(str == '%')
        str(str == '%') = '';
        str = [ str 'percent' ];
    end
    if isnumeric(bands)
        str = [ str '_allfreqs' ];
    end

function cellstr = bands2str(bands)

    if isnumeric(bands)
        for iBand = 1:length(bands)
            cellstr{iBand} = sprintf('%dHz', bands(iBand));
        end
    else
        cellstr = bands(:,1)';
    end