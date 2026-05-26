% Load organized data
organized_data = readtable('organized_data_aligned.csv');

% Define locations
locations = {'CdC', 'KI', 'Bri', 'Sem'};
full_names = {'Cape du Couedic','Kangaroo Island','Brighton','Semaphore'};

% Define custom time range
custom_start_date = datetime(2022, 12, 22, 0, 0, 0);  % Custom start date, do NOT change hourly time
custom_end_date = datetime(2023, 03, 20, 23, 0, 0);    % Custom end date, do NOT change hourly time

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
    
    % Plot directional wave rose also inverse and correct for true north
    % within the polarhistogram code
    subplot(2, 2, 1);
    polarhistogram(direction_angles, 'BinLimits', [0 2*pi], 'Normalization', 'probability');
    title(['Directional Wave Rose - ', location]);
    thetaticks([0 45 90 135 180 225 270 315]);
    thetaticklabels({'E','NE','N','NW','W','SW','S','SE'});

     % Plot peak wave height distribution
    subplot(2, 2, 2);
    histogram(wave_directions, 'Normalization', 'probability');
    title(['Wave Direction - ', location]);
    xlabel('Wave direction (deg)');
    ylabel('Probability');

    % Plot peak wave height distribution
    subplot(2, 2, 3);
    histogram(peak_wave_heights, 'Normalization', 'probability');
    title(['Significant Wave Height - ', location]);
    xlabel('Significant Wave Height (m)');
    ylabel('Probability');
    
    % Plot wave period distribution
    subplot(2, 2, 4);
    histogram(wave_periods, 'Normalization', 'probability');
    title(['Wave Period - ', location]);
    xlabel('Wave Period (s)');
    ylabel('Probability');
    
    % Adjust subplot layout
    sgtitle([full_name, ' - Summer wave statistics']);
end
