%% Optimization Exercise (Project Work) Roni Lumpo K427692

% MAIN:

% Initial settings
settings = calibrationSettings;

% Load initial values
load("empVolatilitySurfaceData.mat");

% OPTIONAL FLAG: Visualization of the optimization process
settings.visualize = true;

% Set a setting parameter to false in order to get pricing error
settings.standardError = false;
% Construct a pricing error function
g = @(x)Optimization_PricingError(data, settings, x);
% Sum of error means with initial parameter values
initialError = g(settings.parameters0);

% Use fminsearch() to optimize parameters (kappa, theta, eta, rho, V0)
[parametersFinal, eFinal, eFlag] = fminsearch(g, settings.parameters0, settings.calibrOptions);

% Set a standardError flag to true to get IV matrix instead of pricing error
settings.standardError = true;
func = @(x)Optimization_PricingError(data, settings, x);
% Get errors for optimized parameters
f = g(parametersFinal);

% Create jacobian matrix with jacobianest()
J = jacobianest(func, parametersFinal);
% Total count of options
n = size(data.IVolSurf,1)*size(data.IVolSurf,2);
% The number of parameters
p = length(settings.parameters0);
% Calculate sigma^2
sigma2 = f/(n-p);
% Calculate standard errors for parameters
SIGMA = sigma2*inv(J'*J);
strdErrs = sqrt(diag(SIGMA));

% Print results in a nice form
names = ["Kappa", "Theta", "Eta", "Rho", "V0"];
column_names = ["Parameter name", "Initial parameter value", "Optimized parameter value", "Standard Error"];
params = [column_names; names', settings.parameters0, parametersFinal, strdErrs];
disp(params);

