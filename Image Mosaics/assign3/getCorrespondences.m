% getCorrespondences(imread('uttower1.jpg'), imread('uttower2.jpg'))
% getCor(imread('uttower1.jpg'), imread('uttower2.jpg'));
% function [cor1, cor2] = getCorrespondences(im1, im2)
function [cor1, cor2] = getCorrespondences(im1, im2)
	% Show the figure with the two images, and prompt the user to
	% click on the points.
	figure;	
	% Display images.
	subplot(1, 2, 1);
	imshow(im1);
    subplot(1, 2, 2);
	imshow(im2);
	% Use ginput() to collect mouse click positions.
    % Convert to x, y coordinates for the homography computation.
	collected = ginput();
    
    % cor1 will hold points from image 1, and cor2 for image 2. This is why
    % the user must click the points from the images by going back and
    % forth, so that we get the proper points in each place.
	cor1 = collected(mod(1:size(collected, 1), 2) == 1, :);
	cor2 = collected(mod(1:size(collected, 1), 2) == 0, :);
    
    % For debugging purposes, was having trouble converting to (x, y).
    % cor1
    % size(cor1, 1)
    % cor2
end