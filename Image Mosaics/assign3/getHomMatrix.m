% c1 = [3 2;14 19;100 105;98 96];
% c2 = [4 3;15 20;101 109;99 92];
% z = getHomMatrix2(c1, c2);
function [h] = getHomMatrix(c1, c2)
	% c1 and c2 are the sets of corresponding points.
	% We need to solve the least squares problem for the system Ah = b.
	pointsCollected = size(c1, 1); % this is n, the number of points collected from each image.
	b = reshape(c2, 2 * pointsCollected, 1);

	% 8 unknowns, so A needs to have 8 columns (h has 8 rows).

	% Fill in the matrix A according to the calculations in the pdf report.
	a = zeros(2 * pointsCollected, 8);
	a(1:pointsCollected, 1:2) = c1; % fill in the top corner of A with c1.
	a(1:pointsCollected, 3) = ones(pointsCollected, 1); % fill in column 3 with ones
	a((pointsCollected + 1):(2 * pointsCollected), 4:5) = c1;
	a((pointsCollected + 1):(2 * pointsCollected), 6) = ones(pointsCollected, 1);
	a(:, 7) = -b .* [c1(:, 1); c1(:, 1)];
	a(:, 8) = -b .* [c1(:, 2); c1(:, 2)];

	% this stores the values of a, b, c, d, e, f, g, h.
	pre_h = a \ b;
	% form the 3x3 homography matrix by adding i = 1 (the scale factor).
	h = transpose(reshape([pre_h; 1], 3, 3));
end