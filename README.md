## Introduction to SurfProfStressFEM
![MATLAB](https://img.shields.io/badge/MATLAB-R2021a+-blue)
<p align="justify">
SurfProfStressFEM is a MATLAB-based code designed to compute the elastic stress concentration factor ($K_\mathrm{t}$) and the fatigue notch factor ($K_\mathrm{f}$) directly from surface roughness profiles. As an alternative to traditional commercial Finite Element Method (FEM) software, this tool takes advantage of MATLAB packages to solve the finite element problem.
</p>

<p align="justify">
The theoretical stress concentration factor ($K_\mathrm{t}$) is defined as the ratio of the maximum stress to the nominal stress:
</p>

$$
K_\mathrm{t} = \frac{\sigma_{\text{max}}}{\sigma_{\text{nom}}},
$$

<p align="justify">
while the effective fatigue stress concentration factor ($K_\mathrm{f}$) is defined as:
</p>

$$
K_\mathrm{f} = 1 + \left(\frac{1}{1 + \frac{\gamma}{\rho}}\right)(K_\mathrm{t} - 1),
$$

<p align="justify">
where $\gamma$ is a material-dependent parameter defined by Dowling [1] as a function of the ultimate tensile strength $\sigma_\mathrm{u}$, $\rho$ is the effective notch radius, and $K_\mathrm{t}$ is the aforementioned elastic stress concentration factor.
</p>

<p align="justify">
For 42CrMo4 steel, the parameter $\gamma$ can be expressed as follows (note that this empirical relation must be adjusted if a different material is used):
</p>

$$
\gamma = 0.025 \left(\frac{2070~\mathrm{MPa}}{\sigma_\mathrm{u}}\right)^{1.8}.
$$

<p align="justify">
It should be noted that, although several formulations have been historically proposed to estimate the stress concentration factor ($K_\mathrm{t}$) from surface profiles (e.g., Neuber [2] and Arola-Ramulu [3]), these methods rely on analytical expressions that typically combine standard surface roughness parameters (such as $R_\mathrm{a}$ or $R_\mathrm{z}$) with the effective notch radius, $\rho$. The latter is commonly evaluated from each measured roughness profile using graphical procedures.
</p>

<p align="justify">
As an alternative, rather than relying on traditional graphical procedures to compute the equivalent $\rho$ necessary for deriving the fatigue notch factor ($K_\mathrm{f}$), this code implements the arc-chord length formulation presented in [4] to estimate the $\rho$ in combination with a FEM to estimate the $K_\text{t}$  It is worth noting that, as reported in the original study, this methodology generally yields larger notch radius values than conventional graphical techniques. However, because graphical approaches tend to characterize the notch geometry at an excessively localized scale, the arc-chord formulation provides a macro-scale representation that is far more consistent with the physical phenomena underlying notch effect correction factors. For illustrative purposes, Figure 1 presents the two possible formulations implemented as a function of the notch depth.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/75faedf4-280d-4696-9322-fa52da30da44" width="50%" alt="Notch Radius Formulation Comparison">
  <br>
  <em><b>Figure 1:</b> Proposed methodology for the two possible notch formulations.</em>
</p>

<p align="justify">
Regarding the model and its boundary conditions, the numerical framework implemented herein relies on a two-dimensional linear elastic model under plane strain conditions, utilizing standard material properties for steel ($E = 206,000$ MPa and $\nu = 0.296$). As depicted in Figure 2, the model geometry features an unstructured two-dimensional triangular mesh with quadratic elements. To ensure mesh convergence, the boundary discretization along the roughness profile was defined with a target edge length of $0.00025$ mm. Regarding the boundary conditions, the left vertical edge was fully constrained, while a remote tensile constant pressure was applied ($200$ MPa) at the opposite edge along the longitudinal direction of the sample.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/e38c27f9-d978-4594-b967-9dbfeccb614c" width="50%" alt="Model Discretization">
  <br>
  <em><b>Figure 2:</b> Model discretization including boundary conditions.</em>
</p>

<p align="justify">
The reader should note that all model parameters, material characteristics, and the formulation used to compute the effective notch radius can be easily modified to implement further proposals.
</p>

## Example of Application
<p align="justify">
To facilitate the application of this code, a practical example using the provided MATLAB functions is presented below (see also <code>MAIN.m</code>). For users interested in testing the algorithm, several real surface roughness profiles measured during our recent research are available in the repository (see the <code>EXAMPLES</code> folder).
</p>

```matlab
% Clear previous vars, clear memory, and so on
clear; clc; close all

% Read the .txt file with the filtered profile and import it
[filename, pathname] = uigetfile({'*.txt';'*.csv';'*.slx';'*.xslx'}, 'File Selector');
roughnessProfile = rmmissing(importRoughnessProfile(strcat(pathname, filename))); % See EXAMPLES folder!
roughnessX = roughnessProfile.X;
roughnessY = roughnessProfile.Y;

% Estimate the profile parameters
[ra, rq, rv, rp, ry, rz, ktFEM, kfFEM] = estimateKfFEM(roughnessX, roughnessY, 206000, 0.296, 1097, -200, 1);
```

Figure 3 show the result of applying the “*S3_005.txt*” roughness profile found in the (see <folder>EXAMPLES</folder>) folder.

<p align="center">
  <img src="https://github.com/user-attachments/assets/55e5ab27-991a-48c6-9409-09874d9a902f" width="50%" alt="Model Discretization">
  <br>
  <em><b>Figure 3:</b> Finite element model of one profile.</em>
</p>


## Citation
<p align="justify">
If you use this code or the provided data in your research of for industrial purposes, please, cite both the software and the original research paper as follows:

**Plain Text:**

* Díaz-Salamanca, Diego. (2026). *Surface Profile Elastic Stress Estimation code via Finite Element Method (SurfProfStressFEM)* (Version 1.0) [Software]. GitHub. https://github.com/DiegoDiazSalamanca/SurfProfStressFEM
* Díaz-Salamanca et al. (2026). *Influence of Machining-Induced Surface Integrity on High-Cycle Fatigue Behavior: Application to 42CrMo4+QT Steel*. Engineering Failure Analysis, XX(XX). doi: XXX
</p>

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
```

## References
**[1]** N. Dowling (1999). *Mechanical behavior of materials: engineering methods for deformation, fracture, and fatigue*, Prentice Hall.

**[1]** H. Neuber (1937). Kerbspannungslehre: Grundlagen für genaue Festigkeitsberechnung mit Berücksichtigung12
von Konstruktionsform und Werkstoff, Springer-Verlag, Berlin.

**[2]** D. Arola, C. Williams (2002). *Estimating the fatigue stress concentration factor of machined surfaces*, International Journal of fatigue, 24(9), 923–930.

**[3]** F. Quan, Z. Chen, H. Ye, C. Cui, Y. Cui (2021). *Study of the effect of surface roughness on fatigue strength of gh4169 based on indirect evaluation of the notch root radius*, International Journal of Fatigue, 223, 106440.
