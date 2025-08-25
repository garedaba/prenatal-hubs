# Generate networks and calculate hubs

The MATLAB code will create the networks for a given parcellation and threshold, and calculate degree/rich-clubs/hubs.

Requirements:

[MATLAB R2023b](https://au.mathworks.com/products/new_products/release2023b.html)

[gifti toolbox](https://www.gllmflndn.com/software/matlab/gifti/)

[plotSurfaceROIBoundary](https://github.com/StuartJO/plotSurfaceROIBoundary) (only for making the plots of degrees spatial embedding)  

## Running the code

Add all the folders to the path with the command

```
addpath(genpath('./'))
```

The code assumes that everything will be run from this directory. This is because a) relative file paths are used and b) the gifti toolbox is dumb and cannot find .gii files that aren't located in the current directory, even if that directory has been added as a path.

To compile all the data, run

```
CompileData.m
GetGroupAverageNetwork.m
CalcIndvHubness.m
```

(note these scripts need  the full original data for all subjects, but isn't currently uploaded because it is quite large, reach out to us if you would like it!)

To calculate the degree and rich-club values, run

```
Calc_RC_Deg.m
```

To get other descrptive statistics, run


```
meanVertPerParc.m
DemoStats.m
```

All figures can be made by running

```
makeFigures.m
```