# Content

This EEGLAB plugin allows the computation of measures provided by the Lexicor Neurofeedback company. It is a valuable resource for Neurofeedback users. Please note that the Lexicor TDT data format is also compatible with the Neuroguide format. Therefore, this plugin can also replot measures computed using Neuroguide.

Thanks to Robert Lawson from EEGWorks for assistance on the development of these tools.

Testing files:
- test_lexicor_power.m - this compares the output of Lexicor software for power analysis with the output of the MATLAB function in this repository
- test_lexicor_phase.m - this compares the output of Lexicor software for phase analysis with the output of the MATLAB function in this repository

# Screen captures

## Example of spectral power plot at each frequency

![](https://github.com/user-attachments/assets/6c97df46-5b5b-470e-95b4-8de1baa0beb5)

## Example of spectral plot in frequency bands

![](https://github.com/user-attachments/assets/6919415a-ec8b-42a5-bf20-23b2c26709d4)

## Example of coherence plots

![](https://github.com/user-attachments/assets/b4645b71-9c93-43ce-85d2-71768742c8e8)

![](https://github.com/user-attachments/assets/9a65e084-bee0-4c20-b6b7-45b56620e8ae)

# Version history:

v1.3 - increase neuroguide compatibility

v1.2 - adding documentation and fileout option to tdtreport.m

v1.1 - fix window size issue when computing spectral decomposition

v1.0 - initial release 
