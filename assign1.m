% To test code, simply write some here:
mtn = imread('mtn.jpg');
mtn = reduceHeight(mtn, 4);


% Calculate energy function
function [pixel_energies] = calc_energy(pic)
	% Convert to grayscale and get gradient values in x, y directions
    pic = double(rgb2gray(pic));
    [x_gradient, y_gradient] = gradient(pic);

    % Magnitutde of the gradient represents energy at this pixel
     pixel_energies = sqrt((x_gradient.^2) + (y_gradient.^2));
end

% Make cumulative map.
function [cumulative_energies] = get_energy_matrix(direction, pixel_energies)
	% this function will populate a matrix with the cumulative
	% energies of the pixels depending on the given seam direction
	% (0 = horizontal, 1 = vertical).
	% This will be used to find the optimal seams.
	cumulative_energies = zeros(size(pixel_energies));

	% we do a different calculation based on direction
	if direction == 0
		% horizontal, so set the first column of cumulative_energies
		% to the first column of pixel_energies
		cumulative_energies(:, 1) = pixel_energies(:, 1);
		% cumulative energy at (i, j) = pixel_energies(i, j)
		% + min(cumulative_energies(i, j - 1), cumulative_energies(i - 1, j - 1), cumulative_energies(i + 1, j - 1))
		for j = 2:size(cumulative_energies, 2) % loop through columns
			for i = 1:size(cumulative_energies, 1) % loop through rows
				up_and_left = 99999; % undefined if i is first row
				down_and_left = 99999; % undefined if i is last row
				direct_left = cumulative_energies(i, j - 1);
				if i ~= 1
					up_and_left = cumulative_energies(i - 1, j - 1);
				end
				if i ~= size(cumulative_energies, 1)
					down_and_left = cumulative_energies(i + 1, j - 1);
				end
				cumulative_energies(i, j) = pixel_energies(i, j) + min([direct_left up_and_left down_and_left]);
			end
		end
	end
	if direction == 1
		% vertical so set the first row of cumulative_energies
		% to the first row of pixel_energies
		cumulative_energies(1, :) = pixel_energies(1, :);
		% cumulative energy at (i, j) = pixel_energies(i, j)
		% + min(up_and_left, direct_up, up_and_right)
		for i = 2:size(cumulative_energies, 1) % rows
			for j = 1:size(cumulative_energies, 2) % columns
				up_and_left = 99999; % undefined if j is first col
				up_and_right = 99999; % undefined if j is last col
				direct_up = cumulative_energies(i - 1, j);
				if j ~= 1
					up_and_left = cumulative_energies(i - 1, j - 1);
				end
				if j ~= size(cumulative_energies, 2)
					up_and_right = cumulative_energies(i - 1, j + 1);
				end
				cumulative_energies(i, j) = pixel_energies(i, j) + min([up_and_right up_and_left direct_up]);
			end
		end
	end
end

% Find the optimal vertical seam.
function [vertical_seam] = optimal_vertical_seam(pic)
	% first, we get the pixel_energies
	p_e = calc_energy(pic);
	% then, pass it into get_energy_matrix to get our cumulative map
	c_e = get_energy_matrix(1, p_e);
	% now, we trace back to find our seam path
	vertical_seam = zeros(size(c_e, 1), 1);
	% column of last pixel in seam
    index = find(c_e(end, :) == min(c_e(end, :)));
	vertical_seam(end) = index(1);
	column_of_last = vertical_seam(end);
	% go through rows of energy map starting from second-to-last row
	% and going up to first row
	for i = size(c_e, 1) - 1:-1:1
		% find min of up_and_left, up_and_right, direct_up, just like in
		% get_energy_matrix function
		up_and_left = 99999; % undefined if column_of_last is first col
		up_and_right = 99999; % undefined if column_of_last is last col
		direct_up = c_e(i, column_of_last);
		if column_of_last ~= 1
			up_and_left = c_e(i, column_of_last - 1);
		end
		if column_of_last ~= size(c_e, 2)
			up_and_right = c_e(i, column_of_last + 1);
		end
		% use the minimum to get the column of the next pixel
		min_en = min([up_and_left up_and_right direct_up]);
		if min_en == up_and_left
			vertical_seam(i) = column_of_last - 1;
		end
		if min_en == direct_up
			vertical_seam(i) = column_of_last;
		end
		if min_en == up_and_right
			vertical_seam(i) = column_of_last + 1;
		end
		column_of_last = vertical_seam(i);
	end
end

% Find the optimal horizontal seam.
function [horizontal_seam] = optimal_horizontal_seam(pic)
	% first, we get the pixel_energies
	p_e = calc_energy(pic);
	% then, pass it into get_energy_matrix to get our cumulative map
	c_e = get_energy_matrix(0, p_e);
	% now, we trace back to find our seam path
	horizontal_seam = zeros(size(c_e, 2), 1);
	% column of last pixel in seam
    index = find(c_e(:, end) == min(c_e(:, end)));
	horizontal_seam(end) = index(1);
	row_of_last = horizontal_seam(end);
	% go through cols of energy map starting from second-to-last col
	% and going up to first col
	for i = size(c_e, 2) - 1:-1:1
		% just like in get_energy_matrix function
		left_and_up = 99999; % undefined if row_of_last is first row
		left_and_down = 99999; % undefined if row_of_last is last row
		direct_left = c_e(row_of_last, i);
		if row_of_last ~= 1
			left_and_up = c_e(row_of_last - 1, i);
		end
		if row_of_last ~= size(c_e, 1)
			left_and_down = c_e(row_of_last + 1, i);
		end
		% use the minimum to get the row of the next pixel
		min_en = min([left_and_up left_and_down direct_left]);
		if min_en == left_and_up
			horizontal_seam(i) = row_of_last - 1;
		end
		if min_en == direct_left
			horizontal_seam(i) = row_of_last;
		end
		if min_en == left_and_down
			horizontal_seam(i) = row_of_last + 1;
		end
		row_of_last = horizontal_seam(i);
	end
end

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

% Reduce the height of image im by numPixels.
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

% Display the seam on the image, commented out in reduce_width and
% reduce_height.
function seam_display(pic, seam, direction)
	figure,
	imshow(pic);
	hold on;
	if direction == 0
		% horizontal
		plot(1:numel(seam), seam)
	end
	if direction == 1
		% vertical
		plot(seam, 1:numel(seam))
	end
end