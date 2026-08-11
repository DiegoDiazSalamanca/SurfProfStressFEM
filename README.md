A MATLAB code to estimate the elastic stress concentration factor for surface roughness profiles!

1) Brief description of the requirements of the profile!

2) Description of the estimateKfFEM function itself

3) Example of application!

And now if you want to see the code at all we can do something like this: 
```
% Clear previous vars, clear memory, and so
clear; clc; close all

% Read the .txt file with the filtered profile and import it
[filename, pathname] = uigetfile({'*.txt';'*.csv';'*.slx';'*.xslx'}, 'File Selector');
roughnessProfile = rmmissing(importRoughnessProfile(strcat(pathname, filename))); % See additional files!
roughnessX = roughnessProfile.X;
roughnessY = roughnessProfile.Y;

% Estimate the profile parameters
[ra, rq, rv, rp, ry, rz, ktFEM, kfFEM] = estimateKfFEM(roughnessX, roughnessY, 206000, 0.296, 1097, -200, 1);
