% LEXPHASE - Function to compute lexicor phase. See validation script
%            test_lexicor_phase (the matching with Lexicor is not perfect)
%
% Usage:
%  [lexcoh, freq] = lexphase(data,srate,bands,outputFormat)
%
% Inputs:
%    data      - [channel x sample] data array
%    srate     - [number] sampling rate in Hz
%    bands     - [array] frequency bands, e.g. [4 6; 8 12] (theta and alpha)
%    outputFormat - [string] Output format
%                          'percent' for percentage (0 to 100) default
%                          'deg'     for degrees
%                          'rad'     for radians
%                          'ms'      for milliseconds
% Outputs:
%    lexcoh  - [channel x channel x frequencies] output matrix
%    freq    - [array] frequency array

function [lexcoh, f] = lexphase(a,srate,bands,outputFormat)

if size(a,1) < 2
    error('Need at least two channels');
end

[r, f] = fftlex(a, srate);
amp = abs(r);
r   = angle(r);

if nargin < 3 || isempty(bands)
    bands = [ f(1:end); f(1:end)+1 ]';
end
if nargin < 4
    outputFormat = 'percent';
end

lexcoh = zeros(size(r,1), size(r,1), size(bands,1));
warning off;
for ind = 1:size(bands,1)
    fmin = find(f >= bands(ind,1)); fmin = fmin(1); % inclusive lower edge
    fmax = find(f <  bands(ind,2)); fmax = fmax(end); % exclusive higher edge

    for ind1 = 1:size(r,1)
        for ind2 = ind1+1:size(r,1)
            phase = zeros(1,size(r,3));
            for t = 1:size(r, 3)
                [~, fInd] = max( amp(ind1,fmin:fmax,t));
                fInd = fmin+fInd-1;

                phase1 = r(ind1,fInd,t); if(phase1<0.0) phase1=2*pi+phase1; end
                phase2 = r(ind2,fInd,t); if(phase2<0.0) phase2=2*pi+phase2; end

                phaseval=phase1-phase2;
                phaseval=abs(phaseval);
                ftemp=abs(phaseval-2*pi);
                if(ftemp<phaseval) phaseval=ftemp; end;
            
                phaseval=mod(abs(phaseval),pi);
                if strcmpi(outputFormat, 'deg')
                    phase(t) = phaseval/pi*180;
                elseif strcmpi(outputFormat, 'rad')
                    phase(t) = phaseval;
                elseif strcmpi(outputFormat, 'percent')
                    phase(t)=100.0*(1.0-abs(phaseval/pi));
                elseif strcmpi(outputFormat, 'ms')
                    phase(t) = phaseval / (2*pi) / ( (fmin+fmax)/2 ) * 1000;
                else
                    error('Unknown format')
                end
            end
            lexcoh(ind2,ind1,ind) = mean(phase);
        end
    end
%             %lexcoh(ind2,ind1,ind) = 100*mean(1-abs( r(ind1,fcenter,:)-r(ind2,fcenter,:))/pi);
%             %lexcoh(ind2,ind1,ind) = 100*mean(mean(1-abs( r(ind1,fmin:fmax,:)-r(ind2,fmin:fmax,:))/pi));
%             %lexcoh(ind2,ind1,ind) = 100*mean(1-abs( mean(r(ind1,fmin:fmax,:)-r(ind2,fmin:fmax,:)))/pi);
%             lexcoh(ind2,ind1,ind) = 100*mean(1-abs( mean(r(ind1,fmin:fmax,:)-r(ind2,fmin:fmax,:)))/pi);
%             %lexcoh(ind2,ind1,ind) = 100*mean(1-abs( mean(r(ind1,fmin:fmax,:)-r(ind2,fmin:fmax,:)))/pi);
%             %lexcoh(ind2,ind1,ind) = 100*mean(1-mean(abs(r(ind1,fmin:fmax,:)-r(ind2,fmin:fmax,:)))/pi); 
%             %lexcoh(ind2,ind1,ind) = 100*mean(max(1-abs(r(ind1,fmin:fmax,:)-r(ind2,fmin:fmax,:))/pi));  8.2 diff
%         end;
%     end;
end;
warning on;
