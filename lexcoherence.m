% Function to compute lexcoherence (spectral correlation)

function [lexcoh, f, lexstd] = lexcoherence(a,srate,bands)

if size(a,1) < 2
    error('Need at least two channels');
end

[r, f] = fftlex(a, srate);
r = abs(r);

if nargin < 3
    bands = [ f(1:end); f(1:end)+1 ]';
end

lexcoh = zeros(size(r,1), size(r,1), size(bands,1));
if nargout > 2
    lexstd = zeros(size(r,1), size(r,1), size(bands,1));
end
warning off;
for ind = 1:size(bands,1)
    fmin = find(f >= bands(ind,1)); fmin = fmin(1); % inclusive lower edge
    fmax = find(f <  bands(ind,2)); fmax = fmax(end); % exclusive higher edge

    for ind1 = 1:size(r,1) % scan channels
        for ind2 = ind1+1:size(r,1) % scan channels
            tmpval = sum(r(ind1,fmin:fmax,:).*r(ind2,fmin:fmax,:)).^2./(sum(r(ind1,fmin:fmax,:).^2).*sum(r(ind2,fmin:fmax,:).^2));
            lexcoh(ind2,ind1,ind) = mean(tmpval); % mean accross trials
            if nargout > 2
                lexstd(ind2,ind1,ind) = std( tmpval);
            end
        end
    end
end
warning on;

