# Content

This EEGLAB plugin allows the computation of measures provided by the Lexicor Neurofeedback company. It is a valuable resource for Neurofeedback users. Please note that the Lexicor TDT data format is also compatible with the Neuroguide format. Therefore, this plugin can also replot measures computed using Neuroguide.

Thanks to Robert Lawson from EEGWorks for his assistance in the development of these tools.

# Instalation

Use the EEGLAB plugin manager to install the plugin (menu item **File > Manage EEGLAB extensions**, then search for TDT_utils). 

# Tutorial

This plugin works on continuous data (ideally pre-cleaned data). Start EEGLAB and load the **eeglab_data.set** file in the **sample_data** directory of EEGLAB. 

Then, use menu item **Tools > Create/plot TDT files**, the following interface will pop up. Hold the shift key and select all measures as shown below.

![Screenshot 2024-08-07 at 18 30 11](https://github.com/user-attachments/assets/8776be02-a771-450c-809e-7891f6390e63)

You may also load a file containing your frequency band definition. "Latency" and "Duration" indicate the onset and offset of data to be considered for processing (0 indicates to start at the beginning of the data and inf indicates to use all the data). The window size (default of 1 second) and window overlap (default of 0 second) used for spectral decomposition may also be changed. Press **OK** to compute the measures.

# Screen captures

Some of the plots below may require calling the plotting functions from the command line to use options not available in the menus.

## Example of spectral power plot at each frequency

![](https://github.com/user-attachments/assets/6c97df46-5b5b-470e-95b4-8de1baa0beb5)

## Example of spectral plot in frequency bands

![](https://github.com/user-attachments/assets/6919415a-ec8b-42a5-bf20-23b2c26709d4)

## Example of coherence plots

![](https://github.com/user-attachments/assets/b4645b71-9c93-43ce-85d2-71768742c8e8)

![](https://github.com/user-attachments/assets/9a65e084-bee0-4c20-b6b7-45b56620e8ae)

# Testing

* test_lexicor_power.m - this compares the output of Lexicor software for power analysis with the output of the MATLAB function in this repository. The correspondence is almost perfect.

* test_lexicor_phase.m - this compares the output of Lexicor software for phase analysis with the output of the MATLAB function in this repository. Note that the correspondence is not perfect. 

# Version history:

v1.3 - increase neuroguide compatibility

v1.2 - adding documentation and fileout option to tdtreport.m

v1.1 - fix window size issue when computing spectral decomposition

v1.0 - initial release 
