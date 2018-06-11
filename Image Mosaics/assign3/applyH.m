function [x, y] = applyH(h, x_val, y_val)
	applied = h * [x_val; y_val; 1];
	x = applied(1, 1) / applied(3, 1);
	y = applied(2, 1) / applied(3, 1);
end