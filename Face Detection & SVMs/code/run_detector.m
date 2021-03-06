% Starter code prepared by James Hays for CS 143, Brown University
% This function returns detections on all of the images in a given path.
% You will want to use non-maximum suppression on your detections or your
% performance will be poor (the evaluation counts a duplicate detection as
% wrong). The non-maximum suppression is done on a per-image basis. The
% starter code includes a call to a provided non-max suppression function.
function [bboxes, confidences, image_ids] = .... 
    run_detector(test_scn_path, w, b, feature_params, fsize)
% 'test_scn_path' is a string. This directory contains images which may or
%    may not have faces in them. This function should work for the MIT+CMU
%    test set but also for any other images (e.g. class photos)
% 'w' and 'b' are the linear classifier parameters
% 'feature_params' is a struct, with fields
%   feature_params.template_size (probably 36), the number of pixels
%      spanned by each train / test template and
%   feature_params.hog_cell_size (default 6), the number of pixels in each
%      HoG cell. template size should be evenly divisible by hog_cell_size.
%      Smaller HoG cell sizes tend to work better, but they make things
%      slower because the feature dimensionality increases and more
%      importantly the step size of the classifier decreases at test time.

% 'bboxes' is Nx4. N is the number of detections. bboxes(i,:) is
%   [x_min, y_min, x_max, y_max] for detection i. 
%   Remember 'y' is dimension 1 in Matlab!
% 'confidences' is Nx1. confidences(i) is the real valued confidence of
%   detection i.
% 'image_ids' is an Nx1 cell array. image_ids{i} is the image file name
%   for detection i. (not the full path, just 'albert.jpg')

% The placeholder version of this code will return random bounding boxes in
% each test image. It will even do non-maximum suppression on the random
% bounding boxes to give you an example of how to call the function.

% Your actual code should convert each test image to HoG feature space with
% a _single_ call to vl_hog for each scale. Then step over the HoG cells,
% taking groups of cells that are the same size as your learned template,
% and classifying them. If the classification is above some confidence,
% keep the detection and then pass all the detections for an image to
% non-maximum suppression. For your initial debugging, you can operate only
% at a single scale and you can skip calling non-maximum suppression.

    test_scenes = dir( fullfile( test_scn_path, '*.jpg' ));

    detection_threshold = 0.00;
    win = feature_params.template_size / feature_params.hog_cell_size;

    %initialize these as empty and incrementally expand them.
    bboxes = zeros(0,4);
    confidences = zeros(0,1);
    image_ids = cell(0,1);



    for i = 1:length(test_scenes)
          
        fprintf('Detecting faces in %s\n', test_scenes(i).name)
        img = imread( fullfile( test_scn_path, test_scenes(i).name ));
        img = single(img)/255;
        if(size(img,3) > 1)
            img = rgb2gray(img);
        end
        confidence_current = zeros(0, 1);
        current_im_ids = cell(0, 1);
        bboxes_current = zeros(0, 4);
        % run the classifier at multiple scales
        for scale_factor = 1.25:-.05:0.5
            img_copy = imresize(img, scale_factor);
            % don't continue if image becomes too small
            if (size(img_copy, 1) < feature_params.template_size || size(img_copy, 2) < feature_params.template_size)
              break;
            end
            % get hog features
            hog_feats = vl_hog(img_copy, feature_params.hog_cell_size);
            rhog = size(hog_feats, 1) - win; chog = size(hog_feats, 2) - win;

            % go through retreived hog features
            for r = 1:rhog
                for c = 1:chog
                    % get the window
                    final_feats = reshape(hog_feats(r:(r - 1 + win), c:(c - 1 + win), :), [fsize, 1]);
                    conf = (transpose(w) * final_feats) + b;
                    if detection_threshold < conf
                        min_x = floor((c - 1) * feature_params.hog_cell_size + 1) / scale_factor; max_x = min_x + (feature_params.template_size / scale_factor);
                        min_y = floor((r - 1) * feature_params.hog_cell_size + 1) / scale_factor; max_y = min_y + (feature_params.template_size / scale_factor);
                        % incremental expansion
                        bboxes_current = [bboxes_current; [min_x, min_y, max_x, max_y]];
                        confidence_current = [confidence_current; conf];
                        current_im_ids = [current_im_ids; test_scenes(i).name];
                    end
                end
            end
        end

        % remove duplicate detections
        [valid_detection] = non_max_supr_bbox(bboxes_current, confidence_current, size(img));
        
        % incremental expansion
        bboxes_current = bboxes_current(valid_detection, :);
        bboxes = [bboxes; bboxes_current];

        confidence_current = confidence_current(valid_detection, :);
        confidences = [confidences; confidence_current];

        current_im_ids = current_im_ids(valid_detection, :);
        image_ids = [image_ids; current_im_ids];
    end
end




