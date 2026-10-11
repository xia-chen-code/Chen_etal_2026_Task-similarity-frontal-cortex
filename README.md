# Chen_2026_Task-similarity dependent reconfiguration of compositional modules and geometry in frontal cortex

MATLAB code used for the population activity analyses reported in:

Chen, X., Yao, X., Yin, X., and Guo, Z. V. (2026).
Task-similarity-dependent reconfiguration of compositional modules and geometry in frontal cortex.

## Data availability
Single-trial PSTHs for each session analyzed in this study have been deposited in Zenodo and are available upon reasonable request at https://doi.org/10.5281/zenodo.21335457

## Data structure

All the Matlab code in this repository follows the data structure described below.

Each '.mat' file contains the following variables for a single recording session:

- PSTHs: Peri-stimulus time histograms with dimensions units × time × trials.

- TimeA: Time used to calculate the PSTHs. 

  TimeA.binsize: binsize to calculate PSTHs (ms).

  TimeA.time: time points aligned to sample onset (s).

- Trials: Trial information and trial-type labels.

- Units: Cell array containing information for each unit (one cell corresponds to one unit). 

## Copyright

Copyright (c) 2026 Xia Chen, Xiao Yao, Xinxin Yin, and Zengcai V. Guo. All rights reserved. The data and associated code are provided for research and educational purposes. Any reuse, redistribution, or reproduction of the materials must appropriately cite the original publication and the associated Zenodo record.
