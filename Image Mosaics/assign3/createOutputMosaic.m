function [mosaic] = createOutputMosaic(im1, im2, original_keep, row_start, col_start)
	[r1, c1, chan1] = size(im1); [r2, c2, ~] = size(im2);
	rofs = 1 - min(1, row_start); cofs = 1 - min(1, col_start);
	mosaic = uint8(zeros(max(rofs + r1, r2), max(cofs + c1, c2), 3));
    % Put image 1 in the frame as-is.
	mosaic(rofs + (1:r1), cofs + (1:c1), 1:chan1) = im1;
	for i = 1:size(original_keep, 2)
        % Add the warped image to the frame (im2 should be the output of inverseWarp()).
		mosaic(original_keep(2, i) + rofs, original_keep(1, i) + cofs, :) = im2(original_keep(2, i) + rofs, original_keep(1, i) + cofs, :);
	end
end