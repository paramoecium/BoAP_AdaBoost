function [estimateclasstotal,model,confidence]=adaboost(mode,datafeatures,dataclass_or_model,itt)
% This function AdaBoost, consist of two parts a simpel weak classifier and
% a boosting part:
% The weak classifier tries to find the best treshold in one of the data
% dimensions to sepparate the data into two classes -1 and 1
% The boosting part calls the clasifier iteratively, after every classification
% step it changes the weights of miss-classified examples. This creates a
% cascade of "weak classifiers" which behaves like a "strong classifier"
%
%  Training mode:
%    [estimateclass,model]=adaboost('train',datafeatures,dataclass,itt)
%  Apply mode:
%    estimateclass=adaboost('apply',datafeatures,model)
% 
%  inputs/outputs:
%    datafeatures : An Array with size number_samples x number_features
%    dataclass : An array with the class off all examples, the class
%                 can be -1 or 1
%    itt : The number of training itterations
%    model : A struct with the cascade of weak-classifiers
%    estimateclass : The by the adaboost model classified data
%               
%  %% Example
%
%  example.m
%
%  Function is written by D.Kroon University of Twente (June 2010)

switch(mode)
    case 'train'
        % Train the adaboost model
        confidence = [];
        % Set the data class 
        dataclass=dataclass_or_model(:);
        model=struct;

        % Weight of training samples, first every sample is even important
        % (same weight)
        %D=ones(length(dataclass),1)/length(dataclass);
        D=ones(length(dataclass),1);
        posNum = length(dataclass(dataclass == 1));
        negNum = length(dataclass(dataclass == -1));
        D(1:posNum) = 1/(2*posNum);
        D(posNum+1:posNum+negNum) = 1/(2*negNum);
        % This variable will contain the results of the single weak
        % classifiers weight by their alpha
        estimateclasssum=zeros(size(dataclass));
        
        % Do all model training itterations
        for t=1:itt
            t
            % Find the best treshold to separate the data in two classes
            [estimateclass,err,h] = WeightedThresholdClassifier(datafeatures,dataclass,D);
             
            % Weak classifier influence on total result is based on the current
            % classification error
            alpha=1/2 * log((1-err)/err);
            
            % Store the model parameters
            model(t).alpha = alpha;
            model(t).dimension=h.dimension;
            model(t).threshold=h.threshold;
            model(t).direction=h.direction;
            
            % We update D so that wrongly classified samples will have more weight
            D = D.* exp(-model(t).alpha.*dataclass.*estimateclass);
            D = D./sum(D);
            
            % Calculate the current error of the cascade of weak
            % classifiers
            estimateclasssum=estimateclasssum +estimateclass*model(t).alpha;
            estimateclasstotal=sign(estimateclasssum);
            model(t).error=sum(estimateclasstotal~=dataclass)/length(dataclass);
        end
        
    case 'apply' 
        % Apply Model on the test data
        
        % Get the Trained Adaboost Model
        model=dataclass_or_model;

        % Add all results of the single weak classifiers weighted by their alpha 
        estimateclasssum=zeros(size(datafeatures,1),1);
        for t=1:length(model);
            estimateclasssum=estimateclasssum+model(t).alpha*ApplyClassTreshold(model(t), datafeatures);
        end
        % If the total sum of all weak classifiers
        % is less than zero it is probablly class -1 otherwise class 1;
        estimateclasstotal=sign(estimateclasssum);
        confidence = estimateclasssum;
    otherwise
        error('adaboost:inputs','unknown mode');
end


function [estimateclass,err,h] = WeightedThresholdClassifier(datafeatures,dataclass,dataweight)
% This is an example of an "Weak Classifier", it tries several tresholds
% in all data dimensions. The treshold which divides the data into two
% class with the smallest error is chosen as final treshold

% Set minimal treshold error in all dimensions to infinite
errdims = inf(1,size(datafeatures,2)); 

% Struct which will contain the optimal tresholds for all dimensions
datadim=struct;
ntre=200;
% Loop through the dimensions

for dim=1:size(datafeatures,2)
    % Switch between calling everything below the treshold from "class -1"
    % to "class +1"
    for dir=[-1 1];
        % Loop through thresholds
        thresholds = linspace(min(datafeatures(:,dim))-1e-16,max(datafeatures(:,dim))+1e-16,ntre);
        for tre=1:ntre
            % Test treshold data
            
            test_h.dimension = dim;
            test_h.threshold = thresholds(tre); 
            test_h.direction = dir;
            % Apply the treshold
            dataclassestimate=ApplyClassTreshold(test_h,datafeatures);
            % Calculate the total classify error
            test_e = sum(dataweight.*(dataclassestimate ~= dataclass));
            % If a new minimum in the dimension is found store the data
            if( test_e < errdims(dim))
                errdims(dim) = test_e;
                datadim(dim).min= thresholds(max(tre-1,1));
                datadim(dim).max= thresholds(min(tre+1,ntre));
                datadim(dim).dir= dir;
            end
        end
    end
end

% Refine treshold by searching in the neighborhood of minimum in all
% dimensions
err=inf;
ntre=50;
% Loop through the dimensions
for dim=1:size(datafeatures,2)
    dir= datadim(dim).dir;
    % Loop through thresholds
    thresholds = linspace( datadim(dim).min, datadim(dim).max,ntre);
    for tre=1:ntre
        % Test treshold data
        test_h.dimension = dim; 
        test_h.threshold = thresholds(tre); 
        test_h.direction = dir;
        % Apply the treshold
        dataclassestimate=ApplyClassTreshold(test_h,datafeatures);
        % Calculate the total classify error
        test_e = sum(dataweight.*(dataclassestimate ~= dataclass));
        % If a new minimum in the dimension is found store the data
        if( test_e < err), err = test_e; h = test_h; end
    end
end
estimateclass=ApplyClassTreshold(h,datafeatures);


function y = ApplyClassTreshold(h, x)
% Draw a line in one dimension (like horizontal or vertical)
% and classify everything below the line to one of the 2 classes
% and everything above the line to the other class.
if(h.direction == 1)
    y =  double(x(:,h.dimension) >= h.threshold);
else
    y =  double(x(:,h.dimension) < h.threshold);
end
y(y==0) = -1;
