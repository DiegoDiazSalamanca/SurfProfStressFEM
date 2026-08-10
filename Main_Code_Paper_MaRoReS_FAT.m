%% Code to estimate main surface parameters and simulate roughness via FEM
% This code allows the user to evaluate the main surface roughness profile
% parameters from a known 2D surface profile (X and Y data points), i.e, Ra,
% Rq, Rv, etc. 
%
% Once this main paramters are estimated, the notch radious is calculated
% using the proposal of Fang Quan et al. published in International Journal
% of Fatigue (doi:https://doi.org/10.1016/j.ijfatigue.2021.106440)
%
% Knowing the notch radius, the Kt parameter are estimated using numerical 
% and analytical approaches.
%
% Finally, the desired fatigue limit corrector parameter is estimated.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%   Programmed by Diego Díaz-Salamanca    diazsdiego@uniovi.es   %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1. Preliminary surface profile preparation

% 1.1) Clear previous vars, clear memory, etc
clear; clc; close all

% 1.2) Read the .txt file with the filtered profile
[filename, pathname] = uigetfile({'*.txt';'*.csv';'*.slx';'*.xslx'}, 'File Selector');
roughnessProfile = rmmissing(importRoughnessProfile(strcat(pathname, filename))); % See additional files
roughnessX = roughnessProfile.X;
roughnessY = roughnessProfile.Y;

% 1.3) Delete roughness profile tendency if exists
roughnessYCln = detrend(roughnessY, 1, "omitnan");
roughnessYCln = roughnessYCln.*1000; % Convert the roughness from mm to microns

% 1.4) Increase the sample points by interpolation
samplingRateIncrease = 100;
newXPoints = linspace(0, max(roughnessX), length(roughnessX)*samplingRateIncrease);
smoothedY = spline(roughnessX, roughnessYCln, newXPoints);

% 1.5) Plot the profile
figure
plot(newXPoints, smoothedY);
hold on;
applyMyStyle(gca,'Length [mm]', 'Depth [$\mu$m]', 14, 14, 0, 0.99*max(roughnessX), min(roughnessYCln), max(roughnessYCln), 12);

%% 2. Computation of the main surface profile parameters

% 2.1) Ra
ra = mean(abs(roughnessYCln(:)), 'omitnan');

% 2.2) Rq
rq = std(roughnessYCln(:), 'omitnan');

% 2.3) Rv
rv = abs(min(roughnessYCln(:), [], 'omitnan'));

% 2.4) Rp
rp = abs(max(roughnessYCln(:), [], 'omitnan'));

% 2.5) Ry 
ry = rv + rp;

% 2.6) Rz
[pSor,plSor] = findpeaks(roughnessYCln, roughnessX, 'SortStr', 'descend');
[vSor,vlSor] = findpeaks(-roughnessYCln, roughnessX, 'SortStr', 'descend', 'MinPeakDistance', 0.1);
vSor = -vSor;
roughnessDepth = pSor(1:10) - vSor(1:10);
rz = mean(roughnessDepth);

% 2.7) Rsm
zeroLevel = zeros(size(roughnessX));
[xi, yi] = polyxpoly(roughnessX, roughnessYCln, roughnessX, zeroLevel);
if mod(length(xi), 2) ~= 0
    xi = xi(1:end-1);
end
sm = xi(3:2:end)-xi(1:2:end-2);
rsm = mean(sm)*1000;

% 2.8) Rmr
rmr = (sum(roughnessYCln>0)/length(roughnessX));

%% 3. Computation of the notch radius according to Quan et al.'s proposal

h = rv;
l = rsm*(1 - rmr);
if h>l/2
    rho = (l/2);
else
    rho = (h/2) + ((l^2)/(8*h));
end

%% 4. Preparation of the signal for FEM analysis

% 4.1) Generation of the 2D contour for the FEM analysis
roughnessYCln = roughnessYCln./1000; % The countour should be in mm!
y0 = min(roughnessYCln(1), roughnessYCln(end)) - 0.1;
yEnd = y0;
x0 = roughnessX(1);
xEnd = roughnessX(end);
contourY = [y0; roughnessYCln; yEnd; y0*ones(length(roughnessX), 1); y0];
contourX = [x0; roughnessX; xEnd; flipud(roughnessX); x0];

% 4.2) Generation of mesh main points
meshPoints = [contourX, contourY];
dt = delaunayTriangulation(contourX, contourY);

% 4.3) Selection of mesh interior points
triangles = dt.ConnectivityList;
points = dt.Points;
centroids = (points(triangles(:, 1), :) + points(triangles(:, 2), :) + points(triangles(:, 3), :))/3;
in = inpolygon(centroids(:,1), centroids(:,2), contourX, contourY);
filteredTriangles = triangles(in, :);
tr = triangulation(filteredTriangles, points);
gm = fegeometry(tr); 

% 4.4) Final mesh generation
edgeIds = 1:gm.NumEdges;
hedgeValues = repmat({0.00025}, 1, gm.NumEdges);
hedgeSpec = reshape([num2cell(edgeIds); hedgeValues], 1, []);
gm = generateMesh(gm, "Hedge", hedgeSpec, "GeometricOrder", "quadratic");

% 4.5) Visualization
figure
pdemesh(gm);

% 4.6) Visualization of the elements label
figure
pdegplot(gm, "EdgeLabels", "on");
hold on;

%% 5. Kt estimation by means of the finite element method

% 5.1) FEM model creation
model = femodel("AnalysisType", "structuralStatic", "Geometry", gm);
model.PlanarType = "planeStrain";
model.MaterialProperties = materialProperties(YoungsModulus = 206000, PoissonsRatio = 0.296);

% 5.2) Definition of the model boundary conditions
mesh = model.Geometry.Mesh;
edgeFixed = nearestEdge(gm, [x0, y0/2]);
model.EdgeBC(edgeFixed) = edgeBC("Constraint", "fixed"); 

% 5.3) Definition of the model load case
pressure = -200; % Pressure load in MPa!
edgeId = nearestEdge(gm, [xEnd, y0/2]);
model.EdgeLoad(edgeId) = edgeLoad("Pressure", pressure);

% 5.4) Model simulation
result = solve(model);

% 5.5) Post−processing of the mesh results to delete extreme values
nodesFiltered = findNodes(mesh, "box", [roughnessX(1) + 0.2, roughnessX(end) - 0.2], [-1.1*(rv/1000), 1.1*(rv/1000)]);
elementsFiltered = findElements(mesh, "box", [roughnessX(1) + 0.2, roughnessX(end) - 0.2],[-1.1*(rv/1000), 1.1*(rv/1000)]);

% 5.6) Extraction of results
maxStressSxx = max(result.Stress.sxx);
minStressSxx = min(result.Stress.sxx);
[maxStressSxxFiltered, idexMax] = max(result.Stress.sxx(nodesFiltered));

% 5.7) Kt estimation
ktFEM = maxStressSxxFiltered/abs(pressure);
nodeIdMax = nodesFiltered(idexMax);

% 5.8) Representation of results
figure
pdeplot(mesh.Nodes, mesh.Elements,'XYData',result.Stress.sxx,'ColorMap','jet');
hold on;
applyMyStyle(gca,'Length [mm]', 'Depth [mm]', 14, 14, x0, xEnd, y0/10, -yEnd/10, 12);
cb = colorbar;   
cb.TickLabelInterpreter = 'latex';
ylabel (cb,'$\sigma_{xx}$ [MPa]','FontSize',14,'Interpreter','latex');
clim([floor(minStressSxx/10)*10 round(maxStressSxx/10)*10]);
clim([100 400]);
hold on
plot(mesh.Nodes(1, nodeIdMax), mesh.Nodes(2, nodeIdMax), "or", "MarkerFaceColor", "g", "MarkerSize", 8);
legend('Roughness profile', 'Critical node', 'Interpreter', 'latex', 'FontSize', 12);

%% 6. Kf parameter estimation 

% 6.1) Material parameters
sigmaU = 1097; % Specific parameter for the analyzed material
gamma = 0.025*(2070/sigmaU).^(1.8);
q = 1/(1+gamma/(rho/1000));

% 6.2) Kf computation
kfFEM = 1+q*(ktFEM - 1); 

function profileData = importRoughnessProfile(filename, dataLines)
    %IMPORTFILE Import data from a text file
    %  ProfileData = IMPORTFILE(FILENAME) reads data from text file FILENAME
    %  for the default selection.  Returns the data as a table.
    %
    %  ProfileData = IMPORTFILE(FILE, DATALINES) reads data for the specified
    %  row interval(s) of text file FILENAME. Specify DATALINES as a
    %  positive scalar integer or a N-by-2 array of positive scalar integers
    %  for dis-contiguous row intervals.
    %
    %  Example:
    %  ProfileData = importfile("F:\30- DIEGO DIAZ SALAMANCA\60. MaRoReS-FAT\10. RoughnessFEM\Scenario1_0.4_4_2_filtered_profile.txt", [1, Inf]);
    %
    %  See also READTABLE.
    %
    % Auto-generated by MATLAB on 17-Jun-2025 19:50:31
    
    %% Input handling
     % If dataLines is not specified, define defaults
    if nargin < 2
        dataLines = [1, Inf];
    end
    
    %% Set up the Import Options and import the data
    opts = delimitedTextImportOptions("NumVariables", 2);
    
    % Specify range and delimiter
    opts.DataLines = dataLines;
    opts.Delimiter = "\t";
    
    % Specify column names and types
    opts.VariableNames = ["X", "Y"];
    opts.VariableTypes = ["double", "double"];
    
    % Specify file level properties
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    
    % Import the data
    profileData = readtable(filename, opts);

end

function applyMyStyle(ax, xTitle, yTitle, xTitleSize, yTitleSize, xLimInf, xLimSup, yLimInf, yLimSup, gcaSize)
    % Labels, box and ticks configuration
    xlabel(ax, xTitle, 'interpreter', 'latex', 'FontSize', xTitleSize);
    ylabel(ax, yTitle, 'interpreter', 'latex', 'FontSize', yTitleSize);     
    set(ax, 'TickLabelInterpreter', 'latex', 'FontSize', gcaSize, 'Layer', 'top', 'Box', 'on');
    
    % Figure limits implementation
    if ~isempty(xLimInf) && ~isempty(xLimSup)
        xlim(ax, [xLimInf xLimSup]);
    end
    if ~isempty(yLimInf) && ~isempty(yLimSup)
        ylim(ax, [yLimInf yLimSup]);
    end
end