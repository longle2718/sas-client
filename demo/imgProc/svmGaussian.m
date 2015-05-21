function [accuracy,expectedLabels] = svmGaussian(testingData, testingLabel, trainingData, trainingLabel, learningRate, sigma, numEpochs)
    
%     trainID = 0;
%     for trainID2 = 1:(numTrainingData*numEpochs)
%         trainID = trainID + 1;
%         dotvals = cell(size(weightVectors,1),1);
%         for labelID = 1:size(weightVectors,1)
%             dotvals{labelID} =  dot(trainingData{trainID},weightVectors{labelID});
%         end
%         [val,label] = max(cell2mat(dotvals));
%         currLabel = char2label(trainingLabel{trainID});
%         if(label ~= currLabel)
%             weightVectors{label}  = weightVectors{label} - learningRate*(trainingData{trainID});
%             weightVectors{currLabel} = weightVectors{currLabel} + learningRate*(trainingData{trainID});
%         end
%         if(trainID == numTrainingData)
%             trainID = 0;
%         end
%     end
    
    numTrainingData = size(trainingData,1);
    numFeatures = size(trainingData{1},1);
    weightVectors = cell(4,1); % l = 1, e = 2, b = 3, a = 4
    
    for i = 1:4
        weightVectors{i} = 0; %zeros(numFeatures,1);
    end
    
    numTestingData = size(testingData,1);
    expLabel = cell(numTestingData,1);
    
    numCorr = 0;
    for testID = 1:numTestingData
        kernalSum = [];
        trainID = 0;
        for train2ID = 1:numTrainingData*numEpochs
            if(trainID == numTrainingData)
                trainID = 0;
            end
            trainID = trainID +1;
            for labelID = 1:size(weightVectors,1)
                currLabel = char2label(testingLabel{testID});
                if(labelID ==currLabel)
                    weightVectors{labelID} = weightVectors{labelID} + (learningRate*(1)*kernal(trainingData{trainID},testingData{testID},sigma));
                else
                    weightVectors{labelID} = weightVectors{labelID} + (learningRate*(-1)*kernal(trainingData{trainID},testingData{testID},sigma));
                end
                
            end
        end
        %disp(weightVectors);
        [val,label] = max(cell2mat(weightVectors));
        currLabel = char2label(testingLabel{testID});
        expLabel{testID} = label2char(label);
        if(label==currLabel)
            numCorr = numCorr + 1;
        end
    end
    accuracy = numCorr/numTestingData;
    expectedLabels = expLabel;

end

function label = char2label(labelchar)

    switch(labelchar)
        case 'l'
            label= 1;
        case 'e'
            label= 2;
        case 'b'
            label= 3;
        case 'a'
            label= 4;
    end
end


function label = label2char(labelnum)

    switch(labelnum)
        case 1
            label= 'l';
        case 2
            label= 'e';
        case 3
            label= 'b';
        case 4
            label= 'a';
    end
end

function value = kernal(x,y,sigma)
    
    value = exp(-1/(2*(sigma)^2)*norm(x-y,2));

end
