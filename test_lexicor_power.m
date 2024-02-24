%% Match the lexicor numbers 
clear
srate = 250;
filein = 'data.asc';
fprintf('Matching is almost perfect except at low frequencies\n')
fprintf('----------------------------------------------------\n')

[chans headerlines nc, res] = asc_readheader(filein);
[tmpdata res] = asc_readdata(filein,headerlines,nc);

chans([1 2 11 12 3 4 13 14 5 6 15 16 7 8 9 10 17 18 19 ]);
tmpdata = tmpdata([1 2 11 12 3 4 13 14 5 6 15 16 7 8 9 10 17 18 19 ],:);
tmpdata = tmpdata - repmat(mean(tmpdata,2), [1 size(tmpdata,2) ]);

maxpnts = floor(size(tmpdata,2)/srate)*srate;
tmpdata(:,maxpnts+1:end) = [];
tmpdata = reshape(tmpdata,size(tmpdata,1), srate, size(tmpdata,2)/srate);
freqBands = { 'Delta' 'Theta' 'Alpha1' 'Beta1' 'Beta2' };

%% match amplitude
% ---------------
tmpdata(:,:,end+1:end+size(tmpdata,3)) = tmpdata;
[magval freqs bandvals] = fftamplitude(tmpdata, srate, [0 4; 4 8; 8 13; 13 32; 32 64]);
figure; plot(bandvals');
legend(freqBands)

bandvals2 = [ ...
36.27	37.40	14.16	19.74	18.08	19.57	9.06	10.57	12.56	13.83	9.02	9.41	11.09	11.76	10.25	10.58	19.86	14.89	12.71;
10.86	11.02	6.09	7.13	7.75	7.95	4.90	5.06	6.90	7.14	5.44	5.40	6.83	7.04	6.81	6.89	8.25	8.05	7.72;
12.94	13.03	11.05	11.35	15.15	15.08	13.26	12.35	19.13	18.38	19.39	17.84	24.17	24.11	29.16	29.31	15.75	20.20	26.83;
18.34	18.27	16.99	19.27	20.58	20.79	15.80	16.98	21.78	21.58	17.54	17.68	21.42	21.43	19.82	20.63	20.94	23.02	23.18;
8.34	8.46	8.86	12.59	6.48	7.02	6.95	10.01	6.63	7.22	6.88	8.19	6.87	7.28	6.79	7.24	6.39	6.96	7.25 ];

tmpStd  = std(bandvals./bandvals2,[],2);
tmpMean = mean(bandvals./bandvals2,2);
fprintf('FFT absolute power (LEX amplitude)\n');
for index = 1:length(tmpMean)
    fprintf('%s ratio: %1.2f (+-%1.2f)\n', freqBands{index}, tmpMean(index), tmpStd(index));
end

%% match magnitude
% ---------------
[magval freqs bandvals] = fftmagnitude(tmpdata, srate, [0 4; 4 8; 8 13; 13 32; 32 64]);
bandvals2 = [ ...
36.41	36.90	23.26	25.79	24.70	25.70	17.71	18.51	18.18	19.49	15.32	15.69	15.65	16.15	14.08	14.12	25.77	19.63	16.17
12.45	12.46	10.71	10.18	11.55	11.39	9.99	9.30	10.46	10.57	9.44	9.31	9.85	9.93	9.47	9.34	11.71	11.11	10.03
16.16	16.02	19.59	16.60	22.52	21.74	26.26	22.62	28.10	26.81	32.13	29.94	33.18	32.95	38.87	38.29	22.45	27.37	33.79
24.06	23.64	30.63	28.71	31.36	30.79	32.23	31.29	33.13	32.34	30.95	30.79	31.15	30.49	27.89	28.21	30.71	32.11	30.34
10.92	10.98	15.81	18.72	9.86	10.38	13.81	18.28	10.13	10.78	12.17	14.26	10.17	10.48	9.69	10.04	9.36	9.77	9.67 ];

tmpStd  = std(bandvals./bandvals2,[],2);
tmpMean = mean(bandvals./bandvals2,2);
fprintf('FFT relative power (LEX relative power)\n');
for index = 1:length(tmpMean)
    fprintf('%s ratio: %1.2f (+-%1.2f)\n', freqBands{index}, tmpMean(index), tmpStd(index));
end;

% peak frequency
% --------------
[magval freqs bandvals] = fftpeakfreq(tmpdata, srate, [0 4; 4 8; 8 13; 13 32; 32 64]);
bandvals2 = [ ...
0.82	0.76	0.99	1.04	1.05	0.99	1.20	1.18	1.20	1.16	1.28	1.30	1.29	1.32	1.35	1.42	1.00	1.25	1.31
5.06	5.15	5.53	5.41	5.59	5.56	5.66	5.80	5.89	5.78	5.94	5.99	6.05	6.03	6.25	6.22	5.51	5.81	6.06
9.42	9.57	9.60	9.65	9.62	9.70	9.78	9.70	9.77	9.73	9.73	9.68	9.68	9.69	9.64	9.62	9.58	9.63	9.63
15.97	16.15	16.32	17.15	15.95	15.92	15.59	16.37	15.75	16.06	15.87	16.33	15.90	16.24	16.36	16.67	15.86	16.07	16.28
36.43	36.91	37.57	38.33	36.01	36.21	37.06	37.63	36.26	36.41	36.72	36.72	36.17	36.66	36.11	36.16	36.11	36.16	36.08 ];

tmpStd  = std(bandvals./bandvals2,[],2);
tmpMean = mean(bandvals./bandvals2,2);
fprintf('LEX peak frequency\n');
for index = 1:length(tmpMean)
    fprintf('%s ratio: %1.2f (+-%1.2f)\n', freqBands{index}, tmpMean(index), tmpStd(index));
end;

% peak magnitude
% --------------
[magval freqs bandvals] = fftpeakamp(tmpdata, srate, [0 4; 4 8; 8 13; 13 32; 32 64]);
bandvals2 = [ ...
13.48	13.88	5.10	7.15	6.52	7.05	3.17	3.78	4.46	4.90	3.14	3.32	3.88	4.11	3.57	3.71	7.17	5.26	4.44
4.05	4.09	2.30	2.62	2.89	2.99	1.89	1.87	2.65	2.70	2.13	2.04	2.67	2.71	2.69	2.69	3.11	3.06	3.00
3.88	3.90	3.33	3.37	4.54	4.49	4.05	3.68	5.79	5.53	6.07	5.56	7.59	7.58	9.41	9.49	4.73	6.14	8.43
2.28	2.27	2.05	2.25	2.64	2.66	2.08	2.12	2.89	2.87	2.32	2.31	2.90	2.88	2.62	2.73	2.74	3.03	3.11
0.80	0.79	0.80	1.18	0.65	0.69	0.64	0.93	0.67	0.72	0.66	0.78	0.68	0.72	0.67	0.72	0.64	0.70	0.72 ];

tmpStd  = std(bandvals./bandvals2,[],2);
tmpMean = mean(bandvals./bandvals2,2);
fprintf('LEX peak amplitude\n');
for index = 1:length(tmpMean)
    fprintf('%s ratio: %1.2f (+-%1.2f)\n', freqBands{index}, tmpMean(index), tmpStd(index));
end;
