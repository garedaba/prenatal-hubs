%% The smoothing code reorders the parcel labels in alphabetical order. This is very annoying. This code reorders it in numerical order

vertSizes = [60 90 120];

for i = 1:3

% Step 1: Read the file. This file is generated as part of the 

vertSize = vertSizes(i);

filename = ['.\data\raw\ubrain_subdiv\',num2str(vertSize),'\parc_labels\CC00063AN06_15102_subdiv_',num2str(vertSize),'.txt'];
fileID = fopen(filename, 'r');
data = textscan(fileID, '%s');
fclose(fileID);
strings = data{1};

% Store the original indices
original_indices = (1:length(strings))';

% Step 2: Separate 'L' and 'R' strings and their indices
L_mask = startsWith(strings, 'L_');
R_mask = startsWith(strings, 'R_');

L_strings = strings(L_mask);
R_strings = strings(R_mask);

L_indices = original_indices(L_mask);
R_indices = original_indices(R_mask);

% Step 3: Extract numbers and sort them
L_numbers = cellfun(@(x) str2double(x(3:end)), L_strings);
R_numbers = cellfun(@(x) str2double(x(3:end)), R_strings);

[L_sorted_numbers, L_sortIdx] = sort(L_numbers);
[R_sorted_numbers, R_sortIdx] = sort(R_numbers);

L_sorted = L_strings(L_sortIdx);
R_sorted = R_strings(R_sortIdx);

L_sorted_indices = L_indices(L_sortIdx);
R_sorted_indices = R_indices(R_sortIdx);

% Step 4: Combine sorted lists and their indices
sorted_strings = [L_sorted; R_sorted];
sorted_indices = [L_sorted_indices; R_sorted_indices];

ParcOrder.(['vert',num2str(vertSize)]) = sorted_indices;

end

save("./data/uBrain_ParcOrder.mat","ParcOrder")