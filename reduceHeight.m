function [reduced_height_image] = reduceHeight(im, numPixels)
	for i = 1:numPixels
		horizontal_seam = optimal_horizontal_seam(im);
		% create a matrix with same # of cols, but one less row
		reduced_height_image = zeros(size(im, 1) - 1, size(im, 2), 3);
		for j = 1:numel(horizontal_seam)
			reduced_height_image(:, j, :) = [im(1:horizontal_seam(j) - 1, j, :); im(horizontal_seam(j) + 1:end, j, :)];
		end
		reduced_height_image = uint8(reduced_height_image);
        im = reduced_height_image;
	end
% 	seam_display(im, horizontal_seam, 0);
end