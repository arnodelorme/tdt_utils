% compute FFT amplitude
%
% Inputs:  
% - data array (channels x points)
% - sampling rate
% - bands (n x 2) n times upper and lower edges
%
% Outputs: 
% - peak frequencies amplitude 
% - Frequencies
% - average results in specific frequency bands

function [r f bandpeakfreq bandsd] = fftpeakfreq(a, srate, bands);

if nargin < 3
    bands = [];
    bandpeakfreq = [];
end;

[r f] = fftlex(a, srate);
r = abs(r)/srate*4;

% get amplitude in all of the amplitude bands
% -------------------------------------------
for c = 1:size(a,1) % channels
    for ind = 1:size(bands,1)
        fmin = find(f >= bands(ind,1)); fmin = fmin(1); % inclusive lower edge
        fmax = find(f <  bands(ind,2)); fmax = fmax(end); % exclusive higher edge
        
        [tmp maxinds] = max(r(c,fmin:fmax,:));
        maxinds = squeeze(maxinds)+fmin-1;
        for indf = 1:size(r,3)
            allvals(indf) = r(c,maxinds(indf),indf);
        end;
        %bandpeakfreq(ind,c) = mean(sum(r(c,fmin:fmax,:),2),3);
        bandpeakfreq(ind,c) = mean(allvals);
        bandsd(      ind,c) = std( allvals);
    end;
end;

%c(1) = a(1) + b(1);
%c(2) = a(1) - b(1);
%d(1) = a(2) * b(2);
%d(2) = a(2) / b(2);
