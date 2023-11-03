% compute FFT amplitude
%
% Inputs:  
% - data array (channels x points)
% - sampling rate
% - bands (n x 2) n times upper and lower edges
%
% Outputs: 
% - FFT amplitude 
% - Frequencies
% - average results in specific frequency bands

function [r f bandamplitude bandsd] = fftamplitude(a, srate, bands, mode);

if nargin < 3
    bands = [];
    bandamplitude = [];
    bandsd = [];
end;

if 0
    fid = fopen('myinfo.txt', 'w');
    if fid == -1
        error('Cannot open file');
    end;
    fprintf(fid, 'Size of a: %d %d\n', size(a,1),     size(a,2));
    fprintf(fid, 'Size of b: %d %d\n', size(srate,1), size(srate,2));
    fclose(fid);
end;

[r f] = fftlex(a, srate);

% compute FFT amplitude
% ---------------------
r = abs(r)/srate*4;
%r(:,1,:) = 0;
f = f(1:end); % remove DC (match the output of PSD)

% get amplitude in all of the amplitude bands
% -------------------------------------------
for c = 1:size(a,1) % channels
    for ind = 1:size(bands,1)
        fmin = find(f >= bands(ind,1)); fmin = fmin(1); % inclusive lower edge
        fmax = find(f <  bands(ind,2)); fmax = fmax(end); % exclusive higher edge
        bandamplitude(ind,c) = mean(sum(r(c,fmin:fmax,:),2),3);
        bandsd(ind,c)        = std( sum(r(c,fmin:fmax,:),2),[],3);
    end;
end;

%c(1) = a(1) + b(1);
%c(2) = a(1) - b(1);
%d(1) = a(2) * b(2);
%d(2) = a(2) / b(2);
