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

function [rout f] = fftlex(a, srate);

if 0
    fid = fopen('myinfo.txt', 'w');
    if fid == -1
        error('Cannot open file');
    end;
    fprintf(fid, 'Size of a: %d %d\n', size(a,1),     size(a,2));
    fprintf(fid, 'Size of b: %d %d\n', size(srate,1), size(srate,2));
    fclose(fid);
end;

% blakman Harris window (4-term) NEED TO COMPENSATE FOR WINDOWING??????
if size(a,1) > size(a,2), a = a'; end;
if mod(size(a,2),2) == 1, a(:,end+1) = a(:,end); end;
w = blackmanharris(size(a,2))';
meana = mean(a,2);
a = a - repmat(mean(a,2), [1 size(a,2) 1]);
a = a.*repmat(resphape(w, 1, length(w)), [size(a,1) 1 size(a,3)]);

% run FFT
% -------
%r = fft(a, max(size(a,2), 256), 2);
r = fft(a, [], 2);
f = linspace(0, srate/2-1, size(r,2)/2);

%r = fft(a, 256, 2);
%f = linspace(0, 256/2-1, size(r,2)/2);

% compute FFT amplitude
% ---------------------
rout = r(:,1:end/2,:);
%r(:,1,:) = 0;
%f = f(1:end); % remove DC (match the output of PSD)
