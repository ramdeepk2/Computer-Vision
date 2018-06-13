% Starter code prepared by James Hays for CS 143, Brown University
% This function should return negative training examples (non-faces) from
% any images in 'non_face_scn_path'. Images should be converted to
% grayscale, because the positive training data is only available in
% grayscale. For best performance, you should sample random negative
% examples at multiple scales.

function features_neg = get_random_negative_features(non_face_scn_path, feature_params, num_samples)
% 'non_face_scn_path' is a string. This directory contains many images
%   which have no faces in them.
% 'feature_params' is a struct, with fields
%   feature_params.template_size (probably 36), the number of pixels
%      spanned by each train / test template and
%   feature_params.hog_cell_size (default 6), the number of pixels in each
%      HoG cell. template size should be evenly divisible by hog_cell_size.
%      Smaller HoG cell sizes tend to work better, but they make things
%      slower because the feature dimensionality increases and more
%      importantly the step size of the classifier decreases at test time.
% 'num_samples' is the number of random negatives to be mined, it's not
%   important for the function to find exactly 'num_samples' non-face
%   features, e.g. you might try to sample some number from each image, but
%   some images might be too small to find enough.

% 'features_neg' is N by D matrix where N is the number of non-faces and D
% is the template dimensionality, which would be
%   (feature_params.template_size / feature_params.hog_cell_size)^2 * 31
% if you're using the default vl_hog parameters

% Useful functions:
% vl_hog, HOG = VL_HOG(IM, CELLSIZE)
%  http://www.vlfeat.org/matlab/vl_hog.html  (API)
%  http://www.vlfeat.org/overview/hog.html   (Tutorial)
% rgb2gray
	% how many sample collected so far?
	how_many_samp = 0;
	temp_size = feature_params.template_size;
	feat_size = int16(31 * (temp_size / feature_params.hog_cell_size)^2);
	win = temp_size / feature_params.hog_cell_size;
	various_scales = [1, 0.6, 0.75, 0.85, 0.95, 1.25, 1.5];
	num_scales = size(various_scales, 2);
	image_files = dir( fullfile( non_face_scn_path, '*.jpg' ));
	% num_images = length(image_files);

	% placeholder to be deleted
	features_neg = zeros(num_samples, feat_size);

	while num_samples > how_many_samp
		image_to_check = randi([1, length(image_files)]);
		img = single(imread(fullfile(non_face_scn_path, image_files(image_to_check).name))) / 255;
		% convert color to grayscale
		if (1 < size(img, 3))
			img = rgb2gray(img);
		end
		% Don't want to modify our original image, so create a copy.
		img_copy = img;

		% use a random scale on the image
		scale_to_use = various_scales(randi([1, num_scales]));
		if scale_to_use ~= 1
			img_copy = imresize(img_copy, scale_to_use);
		end

		% Get hog features
		[r, c] = size(img_copy);
		if c > temp_size && r > temp_size
			% get hog feeatures
			hog_feats = vl_hog(img_copy, feature_params.hog_cell_size);
			rhog = size(hog_feats, 1); chog = size(hog_feats, 2);
			if rhog <= win || chog <= win
				continue;
			end
			% increment number of samples collected
			how_many_samp = how_many_samp + 1;
			x1 = randi([1, rhog - win]); y1 = randi([1, chog - win]);
			get_features = hog_feats(x1:(x1 + win - 1), y1:(y1 - 1 + win), :);

			% populate features_neg
			features_neg(how_many_samp, :) = reshape(get_features, [feat_size, 1]);
		end
	end
end