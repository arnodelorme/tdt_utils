% Function to compute lexcoherence (spectral correlation)

function [lexcohout f] = lexcoherencelight(a,srate,bands);

if size(a,1) ~= 2
    error('Need exactly least two channels');
end;

[lexcoh f] = lexcoherence(a,srate,bands);
lexcohout = squeeze(lexcoh(2,1,:))';