image1 = imread('uttower1.jpg');
image2 = imread('uttower2.jpg');

[c1, c2] = getCorrespondences(image1, image2);
h = getHomMatrix(c1, c2);

[warpedImage, ok, rs, cs] = inverseWarp(h, image1);
figure;
imshow(warpedImage);
title('Warped Image');
finimg = createOutputMosaic(image2, warpedImage, ok, rs, cs);
figure;
imshow(finimg);
title('Final Mosaic');