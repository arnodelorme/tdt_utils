% Function to compute phase coherence
% with only the imaginary part (garanty against volume conductance
% contributions).
% 
% Inputs:  
% - data array 1 (channels x points)
% - data array 2 (channels x points)
% - sampling rate
% - bands (n x 2) n times upper and lower edges
%
% Outputs: 
% - phase coherence amplitude 
% - Frequencies
% - average results in specific frequency bands

function [r f b] = coherenceim(a,b,srate,bands);

if size(a,1) > size(a,2), a = a'; end;
if size(b,1) > size(b,2), b = b'; end;

aa = fft(a, [], 2);
bb = fft(a, [], 2);
f = linspace(0, srate/2, length(aa)/2);

% compute coherence
% -----------------
aa = aa(:,2:end/2);
bb = bb(:,2:end/2);
f = f(2:end); % remove DC (match the output of PSD)
r = abs(imag(aa)./abs(aa).*imag(bb)./abs(bb));

% get amplitude in all of the amplitude bands
% -------------------------------------------
for ind = 1:size(bands,1)
    fmin = find(f >= bands(ind,1)); fmin = fmin(1); % inclusive lower edge
    fmax = find(f <  bands(ind,2)); fmax = fmax(end); % exclusive higher edge
    b(ind) = mean(r(1,fmin:fmax));
end;
