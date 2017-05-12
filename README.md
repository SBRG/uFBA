# unsteady-state Flux Balance Analysis (uFBA)

This repository contains the code for unsteady-state Flux Balance Analysis (uFBA), published in [Bordbar and Yurkovich et al. (2017)](http://www.nature.com/articles/srep46249). There are two MATLB scripts contained within this repository:
- buildUFBAmodel.m: MATLAB function takes steady-state metabolic model and integrates absolutely quantified exo- and endo-metabolomics data
- ufba_workflow.m: sample workflow for uFBA using 

These functions use the following MATLAB data file:
- sample_data.mat: MATLAB save file containing test data for the uFBA sample workflow using the red blood cell model ([Bordbar et al. (2011)](https://bmcsystbiol.biomedcentral.com/articles/10.1186/1752-0509-5-110)) and the metabolomics data published in [Bordbar et al. (2016)](http://onlinelibrary.wiley.com/doi/10.1111/trf.13460/abstract)

This repository also includes a MATLAB-generated tutorial that demonstrates use of the uFBA function:
- ufba_tutorial.mlx
- ufba_tutorial.pdf
