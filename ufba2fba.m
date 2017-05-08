function [model] = ufba2fba(uFBAmodel,option)
% ufba2fba Convert a uFBA (non-steady-state) model to a FBA (steady-state) model
% 
% INPUTS
%   uFBAmodel       COBRA uFBA model structure
%   
% OPTIONAL INPUTS
%   option          destination conversion type:
%       SSnormal       node constrains are removed, model is returned to
%                           original format, flux constraints are not
%                           changed, model will most likely not simulate
%       SSsinks     turns node constraints into sinks, model will still 
%                           simulate (default option)
% 
% OUTPUTS
%   model           COBRA model structure (according to specified option)
% 
% Aarash Bordbar, James Yurkovich 5/1/2016


%% convert model
% default is to convert node constraints to sinks
if ~exist('option')
    option = 'SSsinks';
end

tmpModel = uFBAmodel;

switch option
    case 'SSnormal'
        % 1) remove sink reactions
        sinkLoc = strmatch('sink_',tmpModel.rxns);
        sinkLoc = sinkLoc(sinkLoc > length(tmpModel.rxns) / 2);
        tmpModel = removeRxns(tmpModel, tmpModel.rxns(sinkLoc));
        
        % 2) remove extra metabolites
        tmpModel = removeMetabolites(tmpModel,...
            tmpModel.mets(length(tmpModel.mets)/2 + 1:end));
        tmpModel.mets = strrep(tmpModel.mets, '_G', '');
        
        % 3) fix csense
        tmpModel.csense = '';
        for l = 1:length(tmpModel.mets)
            tmpModel.csense(end + 1) = 'E';
        end
        
        % 4) fix b
        tmpModel.b = zeros(length(tmpModel.mets), 1);  
        
    case 'SSsinks'
        tmpModel.mets = strrep(tmpModel.mets, '_G', '');
        tmpMetbG = tmpModel.b(1:length(tmpModel.mets) / 2);
        tmpMetbL = tmpModel.b(length(tmpModel.mets)/2 + 1:end);
        
        ssMets = find(tmpMetbG == 0 & tmpMetbL == 0);
        nonSSMets = setdiff([1:length(tmpModel.mets) / 2]', ssMets);
        
        tmpModel = removeMetabolites(tmpModel, ...
            tmpModel.mets(length(tmpModel.mets) / 2 + 1:end));
        
        tmpModel.csense = '';
        for l = 1:length(tmpModel.mets)
            tmpModel.csense(end + 1) = 'E';
        end
        
        tmpModel.b = zeros(length(tmpModel.mets), 1);

        sinkMetNames = tmpModel.mets(nonSSMets);
        sinkMetbG = tmpMetbG(nonSSMets);
        sinkMetbL = tmpMetbL(nonSSMets);
        
        [~, tmp] = strtok(sinkMetNames, '[');
        extMets = strmatch('[e]', tmp, 'exact');
        intMets = strmatch('[c]', tmp, 'exact');
        
        tmpModel = addSinkReactions(tmpModel,sinkMetNames(intMets), ...
            sinkMetbG(intMets),sinkMetbL(intMets));
                
        sinkMetNamesForRxnNames = strrep(sinkMetNames, '[e]', '(e)');
        
        tmpLength = length(sinkMetNames(extMets));
        tmpRxns = sinkMetNamesForRxnNames(extMets);
        tmpMets = sinkMetNames(extMets);
        for i = 1:tmpLength
            tmpModel = addReaction(tmpModel, strcat('EX_', ...
                tmpRxns{i}), tmpMets(i), -1, 0, 0, 1000, 0, '', '', [], [], false);
        end
        
        tmpModel = changeRxnBounds(tmpModel,strcat('EX_', ...
            sinkMetNamesForRxnNames(extMets)),sinkMetbG(extMets), 'l');
        tmpModel = changeRxnBounds(tmpModel,strcat('EX_', ...
            sinkMetNamesForRxnNames(extMets)),sinkMetbL(extMets), 'u');
        
    otherwise
        error('Invalid conversion option.')
        
end

model = tmpModel;