% Reduce the width of image im by numPixels.
function [reduced_width_image] = reduceWidth(im, numPixels)
	for i = 1:numPixels
		vertical_seam = optimal_vertical_seam(im);
		% create a matrix with same # of rows, but one less col
		reduced_width_image = zeros(size(im, 1), size(im, 2) - 1, 3);
		for j = 1:numel(vertical_seam)
			reduced_width_image(j, :, :) = [im(j, 1:vertical_seam(j) - 1, :) im(j, vertical_seam(j) + 1:end, :)];
		end
		reduced_width_image = uint8(reduced_width_image);
        im = reduced_width_image;
	end
% 	seam_display(im, vertical_seam, 1);
end