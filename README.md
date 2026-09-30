## Introduction to SurfProfStressFEM
A MATLAB code to estimate the elastic stress concentration factor for surface roughness profiles!

1) Brief description of the requirements of the profile!

2) Description of the estimateKfFEM function itself

3) Example of application!


<p align="center">
  <img src="https://github.com/user-attachments/assets/75faedf4-280d-4696-9322-fa52da30da44" width="50%" alt="Notch">
  <br>
  <em><b>Figure 1:</b> Malla de elementos finitos generada para el perfil de rugosidad importado.</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/e38c27f9-d978-4594-b967-9dbfeccb614c"" width="50%" alt="Notch">
  <br>
  <em><b>Figure 1:</b> Malla de elementos finitos generada para el perfil de rugosidad importado.</em>
</p>


<p align="center">
  <img src="https://github.com/user-attachments/assets/8e1352fe-45a8-4a87-92c5-59506b4fe4c4" width="50%" alt="Notch">
  <br>
  <em><b>Figure 1:</b> Malla de elementos finitos generada para el perfil de rugosidad importado.</em>
</p>


## Examples

``` matlab
% Clear previous vars, clear memory, and so on
clear; clc; close all

% Read the .txt file with the filtered profile and import it
[filename, pathname] = uigetfile({'*.txt';'*.csv';'*.slx';'*.xslx'}, 'File Selector');
roughnessProfile = rmmissing(importRoughnessProfile(strcat(pathname, filename))); % See additional files!
roughnessX = roughnessProfile.X;
roughnessY = roughnessProfile.Y;

% Estimate the profile parameters
[ra, rq, rv, rp, ry, rz, ktFEM, kfFEM] = estimateKfFEM(roughnessX, roughnessY, 206000, 0.296, 1097, -200, 1);

```
## Citation

If you use this code or the provided data in your research, please cite both the software and the original research paper as follows:

**Plain Text:**

* Díaz-Salamanca, Diego. (2026). *Surface Profile Elastic Stress Estimation code via Finite Element Method (SurfProfStressFEM)* (Version 1.0) [Software]. GitHub. https://github.com/DiegoDiazSalamanca/SurfProfStressFEM
* Díaz-Salamanca et al. (2026). *Influence of Machining-Induced Surface Integrity on High-Cycle Fatigue Behavior: Application to 42CrMo4+QT Steel*. Engineering Failure Analysis, XX(XX). doi: [AQUÍ_TU_DOI]

**BibTeX:**

```bibtex
@software{diazsalamanca2026surfprofstressfem,
  author       = {Díaz-Salamanca, Diego},
  title        = {Surface Profile Elastic Stress Estimation code via Finite Element Method (SurfProfStressFEM)},
  year         = 2026,
  version      = {1.0},
  publisher    = {GitHub},
  url          = {(https://github.com/DiegoDiazSalamanca/SurfProfStressFEM)}
}

@article{diazsalamanca2026influence,
  author       = {Díaz-Salamanca, D. and others},
  title        = {Influence of Machining-Induced Surface Integrity on High-Cycle Fatigue Behavior: Application to 42CrMo4+QT Steel},
  journal={Engineering Failure Analysis},
  volume={XX},
  number={XX},
  pages={XX--XX},
  year={2026},
  publisher={Elsevier}
}
