function tdtreport(filein, varargin)

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
    
    options = { 'exportlist' { export_options(listvals) } 'fftlen' fftlen 'overlap' overlap };
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
    options = { options{:} 'banddefs' { bands } };
    close(fig);
elseif ~isstr(filein)
    fig = filein;
    command = varargin{1};

    switch command
        case 'loadbands'
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
    end
    return;
else
    options = varargin;
end

% decode arguments
opt = struct;
if ~isempty(options)
    try   opt = struct(options{:});
    catch error('Wrong ''key'', val, sequence');
    end
end
defaultopt.banddefs    = myloadband('banddef.txt');
defaultopt.exportbands = 'on';
defaultopt.exporthz    = 'on';
defaultopt.computesd   = 'off';
defaultopt.fftlen      = 1;
defaultopt.overlap     = 0;
defaultopt.latency     = 0;
defaultopt.duration    = Inf;
defaultopt.exportlist  = export_options;
fieldsopt   = fieldnames(defaultopt);
errorfields = setdiff(fieldnames(opt), fieldsopt);
if ~isempty(errorfields), error([ 'Unknown option field ''' errorfields{1} '''' ]); end
for i=1:length(fieldsopt)
    if ~isfield(opt, fieldsopt{i}), opt = setfield(opt, fieldsopt{i}, getfield(defaultopt, fieldsopt{i})); end
end
if isstr(opt.exportlist), opt.exportlist = { opt.exportlist }; end

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
    filein = fullfile(EEG.filepath, EEG.filename);
    tmpdata = EEG.data;
    chans   = { EEG.chanlocs.labels };
end

% reorder channels the lexicor way (some channels may be missing)
% ---------------------------------------------------------------
if vachan
    disp('Reordering channels...')
    [~, b, c]  = intersect(lower(chans), lower(channel_order));
    [~, cc] = sort(c);
    neworder = b(cc);
    if length(neworder) < length(chans)
        disp('Warning: some channels were not found');
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
[tmpp, fileout, ext] = fileparts(filein);
fileOutTmp = [ fileout '_report.tdt' ];
fid = fopen(fullfile(tmpp, fileOutTmp), 'w');
fprintf('Writing file %s\n', fullfile(tmpp, fileOutTmp))
if fid == -1, return; end
fprintf(fid, '\n'); % important to topo_neuroguide

f_hz = strcmpi(opt.exporthz, 'on'); 
f_bd = strcmpi(opt.exportbands, 'on'); 
f_sd = strcmpi(opt.computesd, 'on');
for index = 1:length(opt.exportlist)
    switch opt.exportlist{index}
        case 'FFT Absolute Power (uV Sq)'
            [magval, freqs, bandvals, bandsd]  = fftamplitude(tmpdata, srate, banddefs);
            if f_sd, stdmagvals = std(magval,[],3); else stdmagvals = []; end
            if f_sd, stdbdvals  = bandsd';          else stdbdvals  = []; end
            if f_hz,        myprintf(fid, opt.exportlist{index}, mean(magval,3), stdmagvals, chans, freqs); end
            if f_bd,        myprintf(fid, opt.exportlist{index}, bandvals'     , stdbdvals,  chans, opt.banddefs); end
        case 'FFT Relative Power (%)'        
            [magval, freqs, bandvals, bandsd]  = fftmagnitude(tmpdata, srate, banddefs);
            if f_sd, stdmagvals = std(magval,[],3); else stdmagvals = []; end
            if f_sd, stdbdvals  = bandsd';          else stdbdvals  = []; end
            if f_hz,        myprintf(fid, opt.exportlist{index}, mean(magval,3), stdmagvals, chans, freqs); end
            if f_bd,        myprintf(fid, opt.exportlist{index}, bandvals'     , stdbdvals,  chans, opt.banddefs); end
        case 'FFT Coherence'
            if strcmpi(opt.exporthz,    'on')
                [lexcoh, freqs, lexstd ] = lexcoherence(tmpdata, srate);
                if ~f_sd, lexstd = []; end
                myprintfcoh(fid, opt.exportlist{index}, lexcoh, lexstd, chans, freqs); 
            end
            if strcmpi(opt.exportbands, 'on')
                [lexcoh, freqs, lexstd ] = lexcoherence(tmpdata, srate, banddefs);
                if ~f_sd, lexstd = []; end
                myprintfcoh(fid, opt.exportlist{index}, lexcoh, lexstd, chans, opt.banddefs); 
            end
        case 'FFT Phase Lag (Deg)' 
            if strcmpi(opt.exporthz,    'on')
                [lexphaseres,freqs] = lexphase(tmpdata, srate);
                myprintfcoh(fid, opt.exportlist{index}, lexphaseres, [], chans, freqs); 
            end
            if strcmpi(opt.exportbands, 'on')
                lexphaseres = lexphase(tmpdata, srate, banddefs);
                myprintfcoh(fid, opt.exportlist{index}, lexphaseres, [], chans, opt.banddefs); 
            end
        case 'FFT peak frequencies' 
            [magval, freqs, bandvals, bandsd] = fftpeakfreq( tmpdata, srate, banddefs);
            if f_sd, stdmagvals = std(magval,[],3); else stdmagvals = []; end
            if f_sd, stdbdvals  = bandsd';          else stdbdvals  = []; end
            if f_hz,        myprintf(fid, opt.exportlist{index}, mean(magval,3), stdmagvals, chans, freqs); end
            if f_bd,        myprintf(fid, opt.exportlist{index}, bandvals'     , stdbdvals,  chans, opt.banddefs); end
        case 'FFT peak amplitudes' 
            [magval, freqs, bandvals, bandsd] = fftpeakamp(  tmpdata, srate, banddefs);
            if f_sd, stdmagvals = std(magval,[],3); else stdmagvals = []; end
            if f_sd, stdbdvals  = bandsd';          else stdbdvals  = []; end
            if f_hz,        myprintf(fid, opt.exportlist{index}, mean(magval,3), stdmagvals, chans, freqs); end
            if f_bd,        myprintf(fid, opt.exportlist{index}, bandvals'     , stdbdvals,  chans, opt.banddefs); end
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
function myprintf(fid, arraytitle, values, valuestd, elecs, bands)

    fprintf(fid, '%s\n\n', arraytitle); % print title

    % print header line
    % -----------------
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
function myprintfcoh(fid, arraytitle, values, valstd, elecs, bands)

    fprintf(fid, '%s\n\n', arraytitle); % print title
    if size(bands,1) > size(values,3)
        bands = bands(1:size(values,3),:);
    end
    
    % print header line
    % -----------------
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
