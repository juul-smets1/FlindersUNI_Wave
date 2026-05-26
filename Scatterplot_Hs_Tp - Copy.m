% Load organized data
organized_data = readtable('organized_data_aligned_DirectionalEnergy.csv');

% Define locations
locations = {'CdC', 'KI', 'Bri', 'Sem'};
full_names = {'Cape du Couedic','Kangaroo Island','Brighton','Semaphore'};

% Define time range
start_date = datetime(2022, 12, 01, 0, 0, 0);
end_date = datetime(2024, 02, 22, 23, 0, 0);
time_range = start_date:hours(1):end_date;

% Iterate over each location
for i = 1:length(locations)
    % Create a new figure for the current location
    figure;
    
    location = locations{i};
    full_name = full_names{i};

    % Extract wave direction, peak wave height, and wave period
    wave_heights = organized_data.([location '_Hsig_m']);  % Replace 'Hsig_m' with appropriate column name
    wave_periods = organized_data.([location '_Tp_s']);  % Replace 'Tp_s' with appropriate column name 
    wave_direction = organized_data.([location '_Dp_deg']); % Replace 'Dp_deg' with appropriate column name
    wave_energy = organized_data.([location '_P_kW_m']); % Replace P_kW_m with appropriate column name

    % Plotting wave heights against wave periods
    scatter(wave_periods, wave_heights, 'filled');
    
    % Adding labels and title
    xlabel('Wave Period (s)');
    ylabel('Significant Wave Height (m)');
    title(['Wave Height vs. Period at ', full_name]);
    
    % Adding grid
    grid on;
end

