clc
clear all
close all
%----------------------------------------------------------------%
n=input('Please enter the no. of images to be identified:');
s=cell(n,1);
for i=1:n
    s{i}=input('Please enter the names of files containing the source images:','s');
end
str=input('Please enter the name of the cluttered image:','s');
str1=strcat(str,'.jpg');
tic
sceneImage1 = imread(str1);
sceneImage  = rgb2gray(sceneImage1);    %converting scene image to grayscale image
figure();
imshow(sceneImage);
title(['Image of the cluttered scene ',str]);
name=strcat('Image of the cluttered scene ',str,'.jpg');
saveas(gcf,name);
scenePoints = detectSURFFeatures(sceneImage);
figure();
imshow(sceneImage);
title(['300 Strongest Feature Points from cluttered scene ',str]);
hold on;
plot(selectStrongest(scenePoints, 300));
name=strcat('300 Strongest Feature Points from cluttered scene ',str,'.jpg');
saveas(gcf,name);
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);
%----------------------------------------------------------------%
parfor i=1:n;
    str=strcat(s{i},'.jpg');
    boxImage1 = imread(str);
    boxImage  = rgb2gray(boxImage1);
    figure();
    %ax = axes('Parent',fig);
    imshow(boxImage);
    %plot(boxImage);
    title(['Image of object ',s{i},' to be identified']);
    name=strcat('Image of object ',s{i},' to be identified','.jpg');
    saveas(gcf,name);
    %-----------------------------------------------------------------%
    boxPoints = detectSURFFeatures(boxImage);
    %-----------------------------------------------------------------%
    figure();
    imshow(boxImage);
    %plot(boxImage);
    title(['300 Strongest Feature Points from source image ',s{i}]);
    hold on;
    plot(selectStrongest(boxPoints, 300));
    name=strcat('300 Strongest Feature Points from source image ',s{i},'.jpg');
    saveas(gcf,name);
    %-----------------------------------------------------------------%
    [boxFeatures, boxPoints] = extractFeatures(boxImage, boxPoints);
    %-----------------------------------------------------------------%
    boxPairs = matchFeatures(boxFeatures, sceneFeatures);
    %-----------------------------------------------------------------%
    matchedBoxPoints = boxPoints(boxPairs(:, 1), :);%%all row entries from column 1 of boxPairs
    matchedScenePoints = scenePoints(boxPairs(:, 2), :);%%all row entries from column 2 of boxPairs into 
    figure();
    showMatchedFeatures(boxImage, sceneImage, matchedBoxPoints, matchedScenePoints, 'montage');%%montage here means that place the two images next to each other
    title(['Putatively Matched Points (Including Outliers) for source image ',s{i}]);
    name=strcat('Putatively Matched Points (Including Outliers) for source image ',s{i},'.jpg');
    saveas(gcf,name);
    %-----------------------------------------------------------------%
    [tform, inlierBoxPoints, inlierScenePoints] = estimateGeometricTransform(matchedBoxPoints, matchedScenePoints, 'affine');
    %-----------------------------------------------------------------%
    figure();
    showMatchedFeatures(boxImage, sceneImage, inlierBoxPoints, inlierScenePoints, 'montage');
    title(['Matched Points (Inliers Only) for source image ',s{i}]);
    name=strcat('Matched Points (Inliers Only) for source image ',s{i},'.jpg');
    saveas(gcf,name);
    %-----------------------------------------------------------------%
    boxPolygon = [1, 1;...                           % top-left
    size(boxImage, 2), 1;...                 % top-right
    size(boxImage, 2), size(boxImage, 1);... % bottom-right
            1, size(boxImage, 1);...                 % bottom-left
            1, 1];                   % top-left again to close the polygon
    %-----------------------------------------------------------------%
    newBoxPolygon = transformPointsForward(tform, boxPolygon);
    %-----------------------------------------------------------------%
    figure();
    imshow(sceneImage);
    %ax = axes('Parent',fig);
    hold on;
    %plot(sceneImage);
    line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'r');
    title(['Detected Box for source image ',s{i}]);
    name=strcat('Detected Box for source image ',s{i},'.jpg');
    saveas(gcf,name);
end
toc
%done%
%-----------------------------------------------------------------% 