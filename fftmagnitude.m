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

function [r f bandmagnitude bandsd] = fftmagnitude(a, srate, bands, mode);

if nargin < 3
    bands = [];
    bandmagnitude = [];
    bandsd = [];
end;

[r f] = fftlex(a, srate);
r = abs(r);
summag = sum(r(:,:,:),2);

% get amplitude in all of the amplitude bands
% -------------------------------------------
for c = 1:size(a,1) % channels
    for ind = 1:size(bands,1)
        fmin = find(f >= bands(ind,1)); fmin = fmin(1); % inclusive lower edge
        fmax = find(f <  bands(ind,2)); fmax = fmax(end); % exclusive higher edge
        bandmagnitude(ind,c) = 100*mean(sum(r(c,fmin:fmax,:),2)./summag(c,1,:),3);
        bandsd(ind,c)        = 100*std(sum(r(c,fmin:fmax,:),2)./summag(c,1,:),[],3);
    end;
end;

%c(1) = a(1) + b(1);
%c(2) = a(1) - b(1);
%d(1) = a(2) * b(2);
%d(2) = a(2) / b(2);
