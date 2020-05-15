# Flex-printed forehead EEG sensors (fEEGrid) for long-term EEG acquisition

This repository contains code from our latest paper in which we present the fEEGrid, a new sensor headband to record long-term EEG data.
Further information and sample data sets will be added shortly, if you have any questions, please contact me.

## Usage
Start to read or run the code from sab_000_main.m, it is an overview script which contains all the analysis steps and calls to plotting and classification functions. Note that this script is not meant to be executed from start to end, it is meant as a guidance script to document the analysis steps and which data went into which function.

## Dependencies
The analysis pipeline makes use of the Riemannian ASR method to correct artifacts [0] and it uses the effect-size toolbox for statistics [1]

## Paper and Analysis Code
Our evaluation and development has been published in Journal of Neural Engineering and is available openly: https://iopscience.iop.org/article/10.1088/1741-2552/ab914c

# References
[0] https://github.com/s4rify/rASRMatlab
[1] https://github.com/hhentschke/measures-of-effect-size-toolbox

# License
This code is published under the MIT license. 