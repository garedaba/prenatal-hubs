load('DemographicData.mat')

% --- Age range in weeks/days ---
minAge = min(DemographicData.ScanAge);
maxAge = max(DemographicData.ScanAge);

% Convert fractional weeks to [weeks, days]
ScanAgerangeStr = sprintf('%.0f weeks %.0f days – %.0f weeks %.0f days', ...
    floor(minAge), round((minAge - floor(minAge))*7), ...
    floor(maxAge), round((maxAge - floor(maxAge))*7));

% --- Median scan age ---
medAge = median(DemographicData.ScanAge);
ScanAgemedStr = sprintf('%.0f weeks %.0f days', ...
    floor(medAge), round((medAge - floor(medAge))*7));

% --- Age range in weeks/days ---
minAge = min(DemographicData.BirthAge);
maxAge = max(DemographicData.BirthAge);

% Convert fractional weeks to [weeks, days]
BirthAgerangeStr = sprintf('%.0f weeks %.0f days – %.0f weeks %.0f days', ...
    floor(minAge), round((minAge - floor(minAge))*7), ...
    floor(maxAge), round((maxAge - floor(maxAge))*7));

% --- Median scan age ---
medAge = median(DemographicData.BirthAge);
BirthAgemedStr = sprintf('%.0f weeks %.0f days', ...
    floor(medAge), round((medAge - floor(medAge))*7));

% --- Count females ---
if iscellstr(DemographicData.sex) || isstring(DemographicData.sex)
    nFemales = sum(strcmpi(DemographicData.sex,'female'));
elseif iscategorical(DemographicData.sex)
    nFemales = sum(DemographicData.sex == 'female');
else
    error('Sex variable should be string or categorical');
end

% --- Print results ---

fprintf('Birth age range: %s\n', ScanAgerangeStr);
fprintf('Median birth age: %s\n', ScanAgemedStr);

fprintf('Scan age range: %s\n', BirthAgerangeStr);
fprintf('Median scan age: %s\n', BirthAgemedStr);
fprintf('Total number of females: %d\n', nFemales);