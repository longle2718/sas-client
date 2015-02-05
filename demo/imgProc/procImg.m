imageDirCells = queryVid2Img(3,2015,01,07,2015,10,31);
for vidID = 1:3
    [h,w] = size(imageDirCells{vidID});
    for imgID = 1:h
        imageDirCells{vidID}(imgID,:)
    end
end
