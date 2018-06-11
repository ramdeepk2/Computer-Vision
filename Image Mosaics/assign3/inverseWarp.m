function [warpedImage, original_keep, row_start, col_start] = inverseWarp(h, im)
	% warpedImage is the result of applying h to im using an inverse warp.
	% For color images, we need to warp each channel separately and then
	% stack them together.
	% Transform the corners of the input image.
	transformedCorners = zeros(4, 2);
	[x1, y1] = applyH(h, 0, 0);
	% Get size of im.
	[r, c, chan] = size(im);
	[x2, y2] = applyH(h, c, 0);
	[x3, y3] = applyH(h, 0, r);
	[x4, y4] = applyH(h, c, r);
	transformedCorners(1, 1) = x1;
	transformedCorners(2, 1) = x2;
	transformedCorners(3, 1) = x3;
	transformedCorners(4, 1) = x4;
	transformedCorners(1, 2) = y1;
	transformedCorners(2, 2) = y2;
	transformedCorners(3, 2) = y3;
	transformedCorners(4, 2) = y4;

	% Get the minimum and maximum x value of the transformed corners to build bounding box.
    mnxy = min(transformedCorners);
	minimum_x = mnxy(1);
	minimum_y = mnxy(2);
	% Get the minimum y value of the transformed corners to build bounding box.
    mxxy = max(transformedCorners);
	maximum_x = mxxy(1);
	maximum_y = mxxy(2);

	% Set dimensions of the warpedImage.
	row_bound = ceil(maximum_y);
	col_bound = ceil(maximum_x);
	row_start = floor(min(minimum_y, 0));
	col_start = floor(min(minimum_x, 0));
	allrows = row_start:row_bound;
	allcols = col_start:col_bound;
	rofs = 1 - min(1, row_start);
	cofs = 1 - min(1, col_start);
	warpedImage = zeros(row_bound + rofs, col_bound + cofs, chan);

	% Generate grid.
	[gridCol, gridRow] = ndgrid(allcols, allrows);
	idx = transpose([gridCol(:), gridRow(:)]);
	p = h \ ([idx; ones(1, size(idx, 2))]);
	inverseWarpIndex = zeros(2, size(idx, 2));
	inverseWarpIndex(1, :) = p(1, :) ./ p(3, :);
	inverseWarpIndex(2, :) = p(2, :) ./ p(3, :);

	% Within bounding box?
	in_original_image = inverseWarpIndex(1, :) >= 1 & inverseWarpIndex(2, :) >= 1 & inverseWarpIndex(2, :) <= r & inverseWarpIndex(1, :) <= c;
	inverse_keep = inverseWarpIndex(1:2, in_original_image);
	colors = zeros(1, size(inverse_keep, 2), chan);
	original_keep = idx(1:2, in_original_image);

	% Stack the channels together.
	for i = 1:chan
		colors(:, :, i) = interp2(double(im(:, :, i)), inverse_keep(1, :), inverse_keep(2, :));
		for k = 1:size(inverse_keep, 2)
			warpedImage(original_keep(2, k) + rofs, original_keep(1, k) + cofs, i) = colors(1, k, i);
		end
	end

	warpedImage = uint8(warpedImage);
end