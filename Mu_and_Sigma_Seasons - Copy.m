% Load organized data
organized_data = readtable('organized_data_aligned.csv');

% Define seasons and their corresponding custom start and end dates
seasons = {'Summer', 'Spring', 'Winter', 'Autumn'};
season_dates = {
    datetime(2022, 12, 22, 0, 0, 0), datetime(2023, 03, 20, 23, 0, 0);  % Summer
    datetime(2023, 09, 23, 0, 0, 0), datetime(2023, 12, 21, 23, 0, 0);  % Spring
    datetime(2023, 06, 22, 0, 0, 0), datetime(2023, 09, 22, 23, 0, 0);  % Winter
    datetime(2023, 03, 21, 0, 0, 0), datetime(2023, 06, 21, 23, 0, 0)   % Autumn
};

% Define locations
locations = {'CdC', 'KI', 'Bri', 'Sem'};
full_names = {'Cape du Couedic','Kangaroo Island','Brighton','Semaphore'}; 

% Iterate over each season
for s = 1:length(seasons)
    season = seasons{s};
    start_date = season_dates{s, 1};
    end_date = season_dates{s, 2};
    
    fprintf('Season: %s\n', season);
    
    % Initialize arrays to store parameters for this season
    mu_dp = zeros(1, length(locations));
    sigma_dp = zeros(1, length(locations));
    mu_hs = zeros(1, length(locations));
    sigma_hs = zeros(1, length(locations));
    mu_tp = zeros(1, length(locations));
    sigma_tp = zeros(1, length(locations));

    % Iterate over each location
    for i = 1:length(locations)
        location = locations{i};
        full_name = full_names{i};

        % Extract wave direction, peak wave height, and wave period from filtered data for this season and location
        wave_directions = organized_data.(sprintf('%s_Dp_deg', location));  
        peak_wave_heights = organized_data.(sprintf('%s_Hsig_m', location));  
        wave_periods = organized_data.(sprintf('%s_Tp_s', location));  

        % Filter data for this season
        season_indices = organized_data.Time >= start_date & organized_data.Time <= end_date;
        wave_directions = wave_directions(season_indices);
        peak_wave_heights = peak_wave_heights(season_indices);
        wave_periods = wave_periods(season_indices);

        % Remove NaN values
        valid_indices = ~isnan(wave_directions) & ~isnan(peak_wave_heights) & ~isnan(wave_periods);
        wave_directions = wave_directions(valid_indices);
        peak_wave_heights = peak_wave_heights(valid_indices);
        wave_periods = wave_periods(valid_indices);

        % Compute parameters for wave direction
        mu_dp(i) = mean(wave_directions);
        sigma_dp(i) = std(wave_directions);

        % Compute parameters for peak wave height
        mu_hs(i) = mean(peak_wave_heights);
        sigma_hs(i) = std(peak_wave_heights);

        % Compute parameters for wave period
        mu_tp(i) = mean(wave_periods);
        sigma_tp(i) = std(wave_periods);
    end

    % Display results for this season
    disp('Wave Direction (Dp) Parameters:');
    disp('Location    |   Mu    |   Sigma');
    for i = 1:length(locations)
        fprintf('%s    |   %f    |   %f\n', full_names{i}, mu_dp(i), sigma_dp(i));
    end

    disp('Peak Wave Height (Hs) Parameters:');
    disp('Location    |   Mu    |   Sigma');
    for i = 1:length(locations)
        fprintf('%s    |   %f    |   %f\n', full_names{i}, mu_hs(i), sigma_hs(i));
    end

    disp('Wave Period (Tp) Parameters:');
    disp('Location    |   Mu    |   Sigma');
    for i = 1:length(locations)
        fprintf('%s    |   %f    |   %f\n', full_names{i}, mu_tp(i), sigma_tp(i));
    end
    
    disp('-----------------------');
end




