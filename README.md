# Content

This EEGLAB plugin allows the computation of measures provided by the Lexicor Neurofeedback company. It is a valuable resource for Neurofeedback users. Please note that the Lexicor TDT data format is also compatible with the Neuroguide format. Therefore, this plugin can also replot measures computed using Neuroguide.

Thanks to Robert Lawson from EEGWorks for his assistance in the development of these tools.

# Instalation

Use the EEGLAB plugin manager to install the plugin (menu item **File > Manage EEGLAB extensions**, then search for TDT_utils). 

# Tutorial

This plugin works on continuous data (ideally pre-cleaned data). Start EEGLAB and load the **eeglab_data.set** file in the **sample_data** directory of EEGLAB. 

Then, use menu item **Tools > Create/plot TDT files > Compute measures for TDT text files**, and the following interface will pop up. 

![Screenshot 2024-08-07 at 18 28 41](https://github.com/user-attachments/assets/1d31f612-5d08-4ab3-ac67-61cd30f3303c)

Select **Use current**, which will use the current dataset. The plugin also allows to load ASC data files (text files organized in a tabular form with each column containing the data for one electrode) or EDF file. Then the following interface pops up allowing you to select measures to compute. Hold the shift key and select all measures, as shown below.

![Screenshot 2024-08-07 at 18 30 11](https://github.com/user-attachments/assets/8776be02-a771-450c-809e-7891f6390e63)

You may also load a file containing your frequency band definition. "Latency" and "Duration" indicate the onset and offset of data to be considered for processing (0 indicates to start at the beginning of the data and inf indicates to use all the data). The window size (default of 1 second) and window overlap (default of 0 seconds) used for spectral decomposition may also be changed. Press **Generate Report** to compute the measures. The measures are saved in a TDT file with the same name as the dataset file name. This is the same type saved by Neuroguide (although the measures computed by Neuroguide may differ).

Once the measures have been computed, they may be plotted. Use menu item **Tools > Create/plot TDT files > Plot measures from TDT text files**. First, the program will ask you to select a TDT file. The TDT file is being saved in the same folder as the data so it may not be in the current folder. After selecting the TDT file, the following interface will pop up.

![Screenshot 2024-08-07 at 18 30 11](https://github.com/user-attachments/assets/26c2345b-b2e6-4196-b483-88f23eefb837)

Select the first 30 values, and press the ">>" button, then select the **Cool** colormap and press the **Generate plot** button. The following graphics will pop up.

![Screenshot 2024-08-07 at 18 45 34](https://github.com/user-attachments/assets/af77349e-defc-4c12-962b-a28bd275da0c)


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
