function confusionMatrix = labelsToMatrix(expectedLabels, originalLabels)

    numLabels = size(expectedLabels,1);
    if(numLabels ~= size(originalLabels) )
        disp('error');
        labelMatrix = [];
    else
        labels = ['l','e','b','a'];
        labelMatrix = zeros(size(labels,2));
        for labelID = 1:numLabels
            labelMatrix(char2label(originalLabels{labelID}),char2label( expectedLabels{labelID}))= labelMatrix(char2label(originalLabels{labelID}),char2label( expectedLabels{labelID})) + 1;
        end
        labelMatrix = bsxfun(@rdivide,labelMatrix,sum(labelMatrix,2));
    end
    confusionMatrix = labelMatrix;
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
