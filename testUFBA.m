% -------------------------------------------------------------------------
% testUFBA.m
%
% This script tests the uFBA algorithm for integrating exo- and endo-
% metabolomics data into a constraint-based metabolic model. 
% 
% Returns 1 for correct, else 0
% 
% James Yurkovich 5/08/2017
% -------------------------------------------------------------------------
function x = testUFBA()

initCobraToolbox();


%% Load in data and model, and initialize
% This data is quantified and volume adjusted. The following 
% variables will be loaded into your workspace:
%   met_data        exo- and endo-metabolomics data
%   met_IDs         BiGG IDs for the measured metabolites
%   model           modified iAB-RBC-283 COBRA model structure
%   time            time points (in days)
%   uFBAvariables   input for uFBA algorithm
load sample_data;

changeCobraSolver('gurobi7', 'LP');
changeCobraSolver('gurobi7', 'MILP');


%% Linear regression
% Find the rate of change of each metabolite concentration
changeSlopes = zeros(length(met_IDs), 1);
changeIntervals = zeros(length(met_IDs), 1);
for i = 1:length(met_IDs)
    [tmp1, tmp2] = regress(met_data(:, i), [time ones(length(time), 1)], 0.05);
    changeSlopes(i, 1) = tmp1(1);
    changeIntervals(i, 1) = abs(changeSlopes(i, 1) - tmp2(1));
end


%% Run uFBA algorithm
% Determine which changes in metabolite concentration are siginificant
% (based on 95% confidence):
tmp1 = changeSlopes - changeIntervals;
tmp2 = changeSlopes + changeIntervals;
ignoreSlopes = double(tmp1 < 0 & tmp2 > 0);

% Set inputs to uFBA function
uFBAvariables.metNames = met_IDs;
uFBAvariables.changeSlopes = changeSlopes;
uFBAvariables.changeIntervals = changeIntervals;
uFBAvariables.ignoreSlopes = ignoreSlopes;

uFBAoutput = buildUFBAmodel(model, uFBAvariables);


%% Test output
sol = optimizeCbModel(uFBAoutput.model);

if sol.f > 0.225 && sol.f < 0.235
    x = 1;
else
    x = 0;
end