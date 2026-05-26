% Load organized data
organized_data = readtable('organized_data_aligned_DirectionalEnergy.csv');

% Define locations and corresponding full names
locations = {'CdC', 'KI', 'Bri', 'Sem'};
full_names = {'Cape du Couedic', 'Kangaroo Island', 'Brighton', 'Semaphore'};

% Define seasons
seasons = {'22-12-2022 to 20-03-2023', '21-03-2023 to 21-06-2023', '22-06-2023 to 22-09-2023', '23-09-2023 to 21-12-2023'};
season_names = {'Summer', 'Autumn', 'Winter', 'Spring'};

% Define wave periods threshold
threshold = 8; % Threshold for distinguishing between shorter and longer wave periods

% Define a custom colormap starting from white (or any other color you prefer)
cmap = parula(8600); % Use the entire rainbow spectrum colormap Use number od max bin counts to adjust jet
cmap(1,:) = [1,1,1]; % Set the color for 0 bin counts to white

% Iterate over each location
for l = 1:length(locations)
    % Initialize matrices to store counts for the current location
    wave_counts = zeros(2, length(seasons)); % [Short/Long x Seasons]
   
    % Extract location-specific data
    location = locations{l};
    full_name = full_names{l};
    
    % Apply custom colormap only for Semaphore
    if strcmp(location, 'Sem')
        % Define custom colormap starting from white
        cmap = parula(8600); % Use the entire rainbow spectrum colormap Use number of max bin counts to adjust jet
        cmap(1,:) = [1,1,1]; % Set the color for 0 bin counts to white
    else
        % Use default colormap for other locations
        cmap = parula;
    end

    % Iterate over each season
    for i = 1:length(seasons)
        % Parse start and end dates for the current season
        start_date = datetime(seasons{i}(1:10), 'InputFormat', 'dd-MM-yyyy');
        end_date = datetime(seasons{i}(15:end), 'InputFormat', 'dd-MM-yyyy');

        % Filter data for the current season and location
        season_data = organized_data(organized_data.Time >= start_date & organized_data.Time <= end_date, :);

        % Exclude NaN values
        season_data = season_data(~isnan(season_data.([location '_Tp_s'])), :);

        % Count shorter and longer wave periods for the current season
        wave_counts(1, i) = sum(season_data.([location '_Tp_s']) <= threshold); % Shorter wave periods
        wave_counts(2, i) = sum(season_data.([location '_Tp_s']) > threshold);  % Longer wave periods
    end

    % Define labels for the y-axis
    y_labels = {'Sea waves (Tp ≤ 8 s)', 'Swell waves (Tp > 8 s)'};

    % Calculate total counts
    total_counts = sum(wave_counts(:));

    % Create a figure for the current location
    figure;

    % Create a heatmap for shorter wave period counts
    heatmap(season_names, y_labels, wave_counts, 'Colormap', cmap, 'ColorbarVisible', 'on');
    title(sprintf('Sea & Swell wave bin counts at %s (Total Count: %d)', full_name, total_counts));
    xlabel('Season');
end