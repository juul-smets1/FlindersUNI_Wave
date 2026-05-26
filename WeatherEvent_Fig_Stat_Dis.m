% Load organized data
organized_data = readtable('organized_data_aligned.csv');

% Define locations
locations = {'CdC', 'KI', 'Bri', 'Sem'};
full_names = {'Cape du Couedic','Kangaroo Island','Brighton','Semaphore'};

% Define time range
start_date = datetime(2022, 12, 01, 0, 0, 0);
end_date = datetime(2024, 02, 22, 23, 0, 0);
time_range = start_date:hours(1):end_date;

% Define custom time range
custom_start_date = datetime(2023, 11, 28, 0, 0, 0);  % Custom start date, do NOT change hourly time
custom_end_date = datetime(2023, 11, 28, 23, 0, 0);    % Custom end date, do NOT change hourly time

% Iterate over each location
for i = 1:length(locations)
    % Create a new figure for the current location
    figure;
    
    location = locations{i};
    full_name = full_names{i};

    % Filter data within custom time range
    custom_data_indices = organized_data.Time >= custom_start_date & ...
                          organized_data.Time <= custom_end_date;
    custom_data = organized_data(custom_data_indices, :);

    % Extract wave direction, peak wave height, and wave period from filtered data
    wave_directions = custom_data.([location '_Dp_deg']);      % Replace 'Dp_deg' with appropriate column name
    peak_wave_heights = custom_data.([location '_Hsig_m']);    % Replace 'Hsig_m' with appropriate column name
    wave_periods = custom_data.([location '_Tp_s']);          % Replace 'Tp_s' with appropriate column name
    
    % Convert direction data to angles
    % The first 2*pi - and the last -0.5*pi components align the figure
    % with true north
    direction_angles = 2*pi - ((mod(round(wave_directions / 10), 35) * pi / 18)-0.5*pi); 
    
    %Bins now equal the total amount of hours in custom timeframe
    % Calculate the difference in hours
    num_hours = hours(custom_end_date - custom_start_date);
    num_bins_direction = num_hours*2;
    num_bins_period = num_hours*2;
    num_bins_height = num_hours*2; 

    % Plot directional wave rose also inverse and correct for true north
    % within the polarhistogram code
    subplot(2, 2, 1);
    polarhistogram(direction_angles, num_bins_direction, 'BinLimits', [0 2*pi], 'Normalization', 'probability');
    title(['Directional Wave Rose - ', location]);
    thetaticks([0 45 90 135 180 225 270 315]);
    thetaticklabels({'E','NE','N','NW','W','SW','S','SE'});

     % Plot peak wave height distribution
    subplot(2, 2, 2);
    histogram(wave_directions, 'Normalization', 'probability', 'NumBins', num_bins_height);
    title(['Wave Direction - ', location]);
    xlabel('Wave direction (deg)');
    ylabel('Probability');

    % Plot peak wave height distribution
    subplot(2, 2, 3);
    histogram(peak_wave_heights, 'Normalization', 'probability', 'NumBins', num_bins_height);
    title(['Significant Wave Height - ', location]);
    xlabel('Significant Wave Height (m)');
    ylabel('Probability');
    
    % Plot wave period distribution
    subplot(2, 2, 4);
    histogram(wave_periods, 'Normalization', 'probability', 'NumBins', num_bins_period);
    title(['Wave Period - ', location]);
    xlabel('Wave Period (s)');
    ylabel('Probability');
    
    % Adjust subplot layout
    sgtitle(['Weather event: ', full_name, ' (', datestr(custom_start_date), ' 00:00:00', ' - ', datestr(custom_end_date), ')']);
end
