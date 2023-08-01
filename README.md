
# HLRTccfs

This is a tool to suppress near zero-time-lag noise in cross-correlation functions using the high-resolution linear Radon transform (HLRT) technique.

## Requirements

This code is developed and tested on Ubuntu 22.04 with MATLAB R2021a.

## How to start and use

The program includes five MATLAB files and some example data:

- main_modsep_auto.m, the main start function.
- modsep_auto.m, the main called function.
- readsac.m, the function to read SAC data.
- writesac.m, the function to write SAC data.
- wigb.m, the function for plotting cross-correlation functions (CCFs).
- CCFs_original, the folder contains the original CCFs determined from the Anninghe array (Luo et al., 2023).
- CCFs_separated, the folder contains the separated CCFs after running this program.
- sta.loc, station list of the Anninghe array.
- sta_ex.loc, example station list for demostration.

There have three main steps to run this program:

1. In the main_modsep_auto.m, run the section of "Input parameters". You need to set the directory containning the original CCFs (SAC format is required), the station list file to perform, the output directory of separated CCFs, and the slowness grids and slowness range of desired signals.
2. Run the "Loop for each virtual sources". In this step, the program will treat each station as a virtual sources and perform HLRT to separate desired signals, which will then stored in the sub directory (named after the virtual source, i.e., the station name) of the output directory.
3. Since a pair of CCFs has two stations, each of them can obtain the separated CCFs as a virtual source. Therefore, there will be two pairs of CCFs for each pair of stations. In theory, they should be equal, but in reality, due to terrain and heterogeneous media or other reasons, it is difficult to be exactly the same. Therefore, we adopt a method of judging the cross-correlation coefficient of the two pairs of CCFs. If the correlation coefficient of the two pairs is grater than 0.5, they are considered to be similar, and the average of the two is taken as the final CCFs.

After the above three main steps of the program, the final average CCFs are stored in the directory of "CCFs_merged".

## References

Please cite the following reference if you make use of this code in your published papers.

- Luo, S., Yao, H., Wen, J., Yang, H., Tian, B., & Yan, M. (2023). Apparent low‐velocity belt in the shallow Anninghe fault zone in SW China and its implications for seismotectonics and earthquake hazard assessment. Journal of Geophysical Research: Solid Earth. DOI: 10.1029/2022jb025681.
