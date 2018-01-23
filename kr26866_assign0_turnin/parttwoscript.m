%{
 Krishna Ramdeep
 CS 376 Computer Vision
 Assignment 0
%}

% Read in the original image
I = imread('vision_assign0.jpg'); % grayscale, for parts a-b, d-e
Icolor = imread('vision_assign0_color.jpg'); % color for part c

%{
 a.
 map  a  grayscale  image  to  its
 "negative  image",  in  which  the  lightest  values  appear  
 dark and vice versa.
%}
ia = negimage(I);

%{
 b.
 map the image to its "mirror image", i.e., flipping it 
 left to right.
%}
ib = mirrorimage(I);

%{
 c.
 swap the red and green color channels of the input color image
%}
ic = colorswap(Icolor);

%{
 d.
 average the input image with its mirror image (use typecasting!)
%}
id = averagewithmirror(I);

%{
 e.
 add or subtract a random value between [0,255] to every pixel in a
 grayscale image, then clip the resulting image to have a minimum value of
 0 and a maximum value of 255.
%}
ie = transformandclip(I);


% Display our images.
subplot(2, 3, 1), imshow(I)
title('Original grayscale')
subplot(2, 3, 2), imshow(ia)
title('negative')
subplot(2, 3, 3), imshow(ib)
title('mirror')
subplot(2, 3, 4), imshow(ic)
title('modified color')
subplot(2, 3, 5), imshow(uint8(id))
title('average')
subplot(2, 3, 6), imshow(ie)
title('random add/clip')

function ia = negimage(pic)
	% imcomplement does what we need, making light dark and vice versa
	ia = imcomplement(pic);
end

function ib = mirrorimage(pic)
	% another builtin function that does what we need, flipping the image
	ib = fliplr(pic);
end

function ic = colorswap(pic)
    % get the red and green channels
    redchannel = pic(:, :, 1);
    greenchannel = pic(:, :, 2);
    % swap them
    temp = greenchannel;
    greenchannel = redchannel;
    redchannel = temp;
    ic = cat(3, redchannel, greenchannel, pic(:, :, 3));
end

function id = averagewithmirror(pic)
	% typecasting is necessary, otherwise we get floor division, thus losing
	% precision
	id = (double(pic) + double(mirrorimage(pic))) / 2;
end

function ie = transformandclip(pic)
	% add a random integer [0,255]
	ie = pic + (randi(256, 1) - 1);
	% clip to a max of 255
	ie(ie > 255) = 255;
	% this will never happen, since we're adding, but clip to a min of 0
	ie(ie < 0) = 0;
end