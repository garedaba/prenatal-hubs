function cmap = make_alpha_rgb(RGB,alpha)

cmap_adjust = 1-RGB;

cmap = (cmap_adjust.*alpha)+RGB;