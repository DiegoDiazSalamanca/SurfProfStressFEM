% clear previous vars, clear memory, and so
clear; clc; close all

% read the .txt file with the filtered profile and import it
[filename, pathname] = uigetfile({'*.txt';'*.csv';'*.slx';'*.xslx'}, 'File Selector');
roughnessProfile = rmmissing(importRoughnessProfile(strcat(pathname, filename))); % See additional files!
roughnessX = roughnessProfile.X;
roughnessY = roughnessProfile.Y;

% estimate the profile parameters
[ra, rq, rv, rp, ry, rz, ktFEM, kfFEM] = estimateKfFEM(roughnessX, roughnessY, 206000, 0.296, 1097, -200, 1);
