function colors = map_values_to_colormap(values, cmap, climits,DoReshape)
    % Assign colors to each value in 'values' based on the given colormap 'cmap'
    % with a specified minimum and maximum value.
    %
    % Inputs:
    %   values - a numeric matrix of values to be mapped
    %   cmap - an Nx3 colormap (N rows, 3 columns for RGB values)
    %   minVal - the minimum value for normalization
    %   maxVal - the maximum value for normalization
    %
    % Output:
    %   colors - a 3D array of size [size(values,1), size(values,2), 3] containing RGB colors
    
    if nargin < 3
        climits = [min(values,[],'All') max(values,[],'All')];
    end

    if nargin < 4
        if isvector(values)
            DoReshape = 0;
        else
            DoReshape = 1;
        end
    end

    minVal = climits(1);
    maxVal = climits(2);
    % Normalize values using the provided minVal and maxVal
    normValues = (values - minVal) / (maxVal - minVal);
    
    % Clip values to the range [0,1]
    normValues = max(0, min(1, normValues));

    % Map values to colormap indices
    cmapSize = size(cmap, 1);
    indices = round(normValues * (cmapSize - 1)) + 1; % Scale and shift to 1-based index
    
    if ~isvector(values) || DoReshape

    % Assign RGB colors
    colors = reshape(cmap(indices, :), [size(values, 1), size(values, 2), 3]);

    else
        colors = cmap(indices,:);
    end

end