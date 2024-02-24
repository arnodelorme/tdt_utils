chans = [1 31]; % FPz and Oz

signal = EEG.icawinv(chans,1:3)*EEG.icaact([1:3],:);
%signal = EEG.icawinv(chans,:)*EEG.icaact(:,:);

% remove mean
signal = signal - repmat(mean(signal,2), [1 size(signal,2)]);

% put in the range -1 to 1
signal = signal/max(abs(signal(:))*1.001);

wavwrite(signal', 'eeg_2channels_3components.wav');
%wavwrite(signal', 'eeg_2channels.wav');
