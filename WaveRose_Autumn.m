% Load organized data
organized_data = readtable('organized_data_aligned.csv');

% Define locations
locations = {'CdC', 'KI', 'Bri', 'Sem'};
full_names = {'Cape du Couedic','Kangaroo Island','Brighton','Semaphore'};

% Define custom time range
custom_start_date = datetime(2023, 03, 21, 0, 0, 0);  % Custom start date, do NOT change hourly time
custom_end_date = datetime(2023, 06, 21, 23, 0, 0);    % Custom end date, do NOT change hourly time

% Iterate over each location
for i = 1:length(locations)
    % Create a new figure for the current location
    location = locations{i};
    full_name = full_names{i};

    % Filter data within custom time range
    custom_data_indices = organized_data.Time >= custom_start_date & ...
                          organized_data.Time <= custom_end_date;
    custom_data = organized_data(custom_data_indices, :);

    % Extract wave direction, peak wave height, and wave period
    wave_directions = custom_data.([location '_Dp_deg']);  % Replace 'Dp_deg' with appropriate column name
    peak_wave_heights = custom_data.([location '_Hsig_m']);  % Replace 'Hsig_m' with appropriate column name
   
    WindRose(wave_directions,peak_wave_heights,'ndirections',32,'vwinds',[0 1 2 3 4 5 6 7 8],'titlestring',...
        ['Autumn Wave Rose - ', full_name],'lablegend','Significant Wave Height (m)','anglenorth',0,'angleeast',90, ...
        'labels',{'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'},'freqlabelangle', 22.5, 'cmap',jet);
    legend('Position',[0.85 0.35 0.01 0.01])
end
