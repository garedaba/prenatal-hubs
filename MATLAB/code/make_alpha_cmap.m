function cmap = make_alpha_cmap(RGB,N)

s = linspace(1,0,N)';

rgb_map = repmat(RGB,N,1);

cmap_adjust = 1-rgb_map;

spacing = [s s s];

cmap = (cmap_adjust.*spacing)+rgb_map;