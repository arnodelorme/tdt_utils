% asc_convertcohfile() - Convert coherence file from a single array to
%                        many arrays
% Usage:
%   >> [res] = asc_convertcohfile( filein, fileout);
%
% Inputs:
%   filein   - [string] input file name.
%   fileout  - [string] output file name.
%
% Outputs:
%  res    - [0|1] 1 means successful conversion
%
% Example for the first file:
%
% FFT Amplitude Asymmetry
%
%           Delta	Theta	Alpha	Beta	High Beta	Gamma	High Gamma	Alpha 1	Alpha 2	Beta 1	Beta 2	Beta 3	Gamma 1	Gamma 2
%       	1.0 - 4.0 Hz	4.0 - 8.0 Hz	8.0 - 12.0 Hz	12.0 - 25.0 Hz	25.0 - 30.0 Hz	30.0 - 40.0 Hz	40.0 - 50.0 Hz	8.0 - 10.0 Hz	10.0 - 12.0 Hz	12.0 - 15.0 Hz	15.0 - 18.0 Hz	18.0 - 25.0 Hz	30.0 - 35.0 Hz	35.0 - 40.0 Hz
%FP1	FP2	-11.958385	-6.428141	-2.627430	1.546044	20.706424	6.601129	8.772099	-3.151713	-2.001879	-6.233131	-16.857658	15.683079	9.280661	3.312816
%FP1	F3	-47.506977	-56.672187	-42.788223	-29.702338	-19.976461	-3.365156	11.765151	-51.250016	-31.411958	-35.273038	-23.926799	-29.246421	-7.889619	2.664213
%FP1	F4	-51.750765	-66.177757	-53.123269	-37.347078	-38.403697	-4.493639	22.097094	-58.439000	-46.275816	-42.740399	-40.403805	-32.978158	-8.476150	0.780283
%FP1	C3	-67.263690	-64.010354	-48.970299	-45.417351	-22.754146	-25.897505	-32.001858	-60.228631	-33.015170	-41.890832	-40.725819	-49.131255	-22.498985	-30.008943
%FP1	C4	-60.313695	-54.232533	-58.374150	-41.175214	-12.821513	24.186697	54.240800	-70.721285	-40.278695	-36.002134	-43.760300	-42.556950	15.857402	35.674374
%
% Example for the second file:
%
% Delta (1.0 - 4.0 Hz)
%
%	FP1	FP2	F7	F3	FZ	F4	F8	T3	C3	CZ	C4	T4	T5	P3	PZ	P4	T6	O1	O2
%FP1	1	-0.5457	-0.4849	-0.4892	-0.1713	0.0577	0.0421	0.0686	-0.0023	0.106	0.2089	0.0497	0.046	0.242	0.4217	-0.4676	-0.2583	-0.2139	-0.3307
%FP2	0.5457	1	0.0654	0.0957	0.1412	-0.3863	0.4898	0.0059	0.1659	0.1406	0.0481	0.0244	0.1524	-0.4073	-0.4671	-0.3345	0.1028	-0.2452	0.2607
%F7	-0.4849	-0.0654	1	0.4371	0.0286	-0.0194	0.0048	-0.5424	-0.0426	0.1348	-0.3108	0.0632	0.011	0.0836	0.3236	-0.4142	-0.1898	0.0927	-0.2258
% ...
%
% Theta (4.0 - 8.0 Hz)
%
%	FP1	FP2	F7	F3	FZ	F4	F8	T3	C3	CZ	C4	T4	T5	P3	PZ	P4	T6	O1	O2
%FP1	1	-0.8028	-0.6296	-0.6675	-0.5085	0.4671	0.4176	0.0121	-0.0341	0.0385	0.0256	0.0189	0.3356	0.5907	0.5977	-0.4946	-0.2901	-0.4626	-0.379
%FP2	0.8028	1	0.3283	0.4557	0.5197	-0.6796	0.7322	0.0114	0.0776	0.0366	0.0751	0.0935	0.434	-0.6775	-0.5836	-0.4105	0.2275	-0.4972	0.3638
%F7	-0.6296	-0.3283	1	0.4968	0.1887	-0.1184	0.152	-0.3148	-0.018	0.0632	-0.0442	0.0034	0.0686	0.3214	0.5371	-0.5185	-0.1768	0.2193	-0.2377
% ...
%
% 

function res = asc_convertcohfile( filein, fileout);

    if nargin < 1
        [tmpf tmpp] = uigetfile('*.tdt;*.TDT', 'Choose a TDT file'); 
        if tmpf(1) == 0, return; end;
        filein = fullfile(tmpp, tmpf);
    end;
    if nargin < 2
        [tmpf tmpp] = uiputfile('*.tdt;*.TDT', 'Choose a TDT file'); 
        if tmpf(1) == 0, return; end;
        fileout = fullfile(tmpp, tmpf);
    end;

    fid = fopen(filein, 'r');
    if fid == -1, return; end;
    
    % find title
    % ----------
    skip = 0;
    tmpline = []; % blank line
    while isempty(tmpline)
        tmpline = fgetl(fid); skip = skip+1; % blank line
    end;
    skip = skip-1;
    fclose(fid);
    
    % read all data lines
    % -------------------
    tmpa = myloadtxt(filein, skip, 9);
    %tmpa = loadtxt(filename, 'skipline', skip, 'delim', 9);
    
    % Title of plot
    % -------------
    titletext = tmpa{1,1};
    tmpa(1,:) = [];
    
    % handle 2 lines of title
    % -----------------------
    if isstr(tmpa{2,2}), 
        for index = 1:size(tmpa,2)
            tmpa{1,index} = [ tmpa{1,index} ' (' tmpa{2,index} ')' ];
        end;
        tmpa(2,:) = [];
    end;
    if isempty(tmpa{end,1}), tmpa(end,:) = []; 
    elseif tmpa{end,1}(1) == -1, tmpa(end,:) = []; 
    end;

    % title 
    % -----
    titles = tmpa(1,:);
    if isempty(titles{end}), titles(end) = []; end;
    if isempty(titles{end}), titles(end) = []; end;
    if isempty(titles{end}), titles(end) = []; end;
    if strcmpi(titles{end},' ()'), titles(end) = []; end;
    if strcmpi(titles{end},' ()'), titles(end) = []; end;
    tmpa(1,:) = [];
    chanlab = unique(tmpa(:,1));
    nchans  = length(chanlab);
    
    % divide by 100?
    % --------------
    divide = 1;
    allvals = [ tmpa{:, 3:end} ];
    if max(allvals) > 100, error('Coherence greater than 100'); end;
    if std(allvals) > 10, divide = 100; end;
    
    % write output file
    % -----------------
    fod = fopen(fileout, 'w');
    if fod == -1, return; end;
    linecount = 1;
    for i1 = 1:length(titles)
        fprintf(fod,'\n%s\n\n', titles{i1});
        for i2=1:nchans
            fprintf(fod,'\t%s', chanlab{i2});
        end;
        fprintf(fod,'\n');        
        
        % make coherence array
        % --------------------
        valarray = ones(length(chanlab), length(chanlab))*divide;
        for i2 = 1:size(tmpa,1)
            lab1 = tmpa{i2,1};
            lab2 = tmpa{i2,2};
            ind1 = strmatch(lab1, chanlab, 'exact');
            ind2 = strmatch(lab2, chanlab, 'exact');
            valarray(ind1, ind2) = tmpa{i2,i1+2};
            valarray(ind2, ind1) = tmpa{i2,i1+2};
        end;

        % write results
        % -------------
        for i2=1:nchans
            fprintf(fod,'%s', chanlab{i2});
            for i3=1:nchans
                fprintf(fod,'\t%1.5f', valarray(i2,i3)/divide);
            end;
            fprintf(fod,'\n');
        end;
    end;
    fclose(fod);
            
    
    
% load text file
% --------------
function alldat = myloadtxt(filename, skip, delim);

    fid = fopen(filename, 'r');
    % skip lines ---------
    index = 0;
    while index < abs(skip)
        tmpline = fgetl(fid); 
        if skip > 0 | ~isempty(tmpline)
            index = index + 1;
        end;    
    end; 
    
    % read file
    % ---------
    r = 1;
    while(~feof(fid))
        
        args = fgetl(fid);
        if isempty(args), args = fgetl(fid); end;
        c = 1;
        while ~isempty(args)
             [tmp args] = strtok(args, delim);
             if ~isempty(tmp) & tmp(1) > 43 & tmp(1) < 59, tmp2 = str2num(tmp);
             else tmp2 = []; end;
             if isempty( tmp2 )  , alldat{r,c} = tmp;
             else                  alldat{r,c} = tmp2;
             end;
             c = c+1;
        end;
        r = r+1;
    end;
    
    fclose(fid);    

