% Default plot
topo_tdt('FFT_Absolute_Power.txt');

% Disable spherical splines (default is on)
topo_tdt('FFT_Absolute_Power.txt','sphspline','off');

% Disable displaying electrodes
topo_tdt('FFT_Absolute_Power.txt','electrodes','off');

% Display electrode labels
topo_tdt('FFT_Absolute_Power.txt','electrodes','labels');

% Change colormap
topo_tdt('FFT_Absolute_Power.txt','colormap','hsv');
topo_tdt('FFT_Absolute_Power.txt','colormap','testcolmap.txt');

% For independent symmetrical color axis for each map
topo_tdt('FFT_Absolute_Power.txt','maplimits','absmax');

% For a common color axis for each map
topo_tdt('FFT_Absolute_Power.txt','maplimits','common');

% For a common symmetrical color axis for each map
topo_tdt('FFT_Absolute_Power.txt','maplimits','commonsym');

% For a common symmetrical color axis between -20 and 20 for each map
topo_tdt('FFT_Absolute_Power.txt','maplimits','20');

% Electrode colors
topo_tdt('FFT_Absolute_Power.txt', 'elecred', '2_3_4', 'elecblue', '5_6', 'elecgreen', '7_8');