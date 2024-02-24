% Function to compute lex phase 2 channels (spectral correlation)

function [lexcoh f] = lexphaselight(a,srate,bands);

if size(a,1) ~= 2
    error('Need exactly least two channels');
end;

[lexcoh f] = lexphase(a,srate,bands);
lexcoh = squeeze(lexcoh(2,1,:))';