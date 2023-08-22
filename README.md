
# HLRTccfs

HLRTccfs is a tool that uses the high-resolution linear Radon transform (HLRT) technique to suppress near zero-time-lag noise in cross-correlation functions (CCFs).

## Requirements

This code is developed and tested on Ubuntu 22.04 with MATLAB R2021a.

## How to start and use

The program consists of five MATLAB files and some example data:

- main_modsep_auto.m: the main start function.
- modsep_auto.m: the main called function.
- readsac.m: the function to read SAC data.
- writesac.m: the function to write SAC data.
- wigbcc.m: the function for plotting CCFs.
- CCFs_original: the folder containing the original CCFs calculated from the Anninghe array (Luo et al., 2023).
- CCFs_separated: the folder containing the separated CCFs after running this program.
- sta.loc: the station list of the Anninghe array.
- sta_ex.loc: an example station list for demonstration.
- txt2sac_demo: the folder containing a demonstration that converts the CCFs from ASCII format to SAC format.

There are three main steps to run this program:

0. If you don't have CCFs in SAC format but rather in ASCII format, you can utilize the script located in the 'txt2sac_demo' folder to convert them into SAC format.
1. In main_modsep_auto.m, run the section of "Input parameters". You need to set the directory containing the original CCFs (SAC format is required), the station list file to use, the output directory for separated CCFs, and the slowness grids and slowness range of desired signals.
2. Run the "Loop for each virtual sources". In this step, the program will treat each station as a virtual source and use HLRT to separate the desired signals, which will then be stored in the subdirectory (named after the virtual source, i.e., the station name) of the output directory.
3. Since a pair of CCFs has two stations, each of them can obtain the separated CCFs as a virtual source. Therefore, there will be two pairs of CCFs for each pair of stations. In theory, they should be equal, but in reality, due to terrain and heterogeneous media or other reasons, it is difficult for them to be exactly the same. Therefore, we adopt a method of judging the cross-correlation coefficient of the two pairs of CCFs. If the correlation coefficient of the two pairs is greater than 0.5, they are considered to be similar, and the average of the two is taken as the final CCF.

After completing the above three main steps of the program, the final average CCFs will be stored in the directory of "CCFs_merged".

## References

If you use this code in your published papers, please cite the following reference:

- Luo, S., Yao, H., Wen, J., Yang, H., Tian, B., & Yan, M. (2023). Apparent low‐velocity belt in the shallow Anninghe fault zone in SW China and its implications for seismotectonics and earthquake hazard assessment. Journal of Geophysical Research: Solid Earth. DOI: 10.1029/2022jb025681.
