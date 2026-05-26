% Load organized data
organized_data = readtable('organized_data_aligned.csv');

% Define locations
locations = {'CdC', 'KI', 'Bri', 'Sem'};
full_names = {'Cape du Couedic','Kangaroo Island','Brighton','Semaphore'};

% Define time range
start_date = datetime(2022, 12, 01, 0, 0, 0);
end_date = datetime(2024, 02, 22, 23, 0, 0);
time_range = start_date:hours(1):end_date;

% Define threshold
threshold = 8; % Threshold for distinguishing between shorter and longer wave periods

% Define seasons
seasons = {'22-12-2022 to 20-03-2023', '21-03-2023 to 21-06-2023', '22-06-2023 to 22-09-2023', '23-09-2023 to 21-12-2023'};
season_names = {'Summer', 'Autumn', 'Winter', 'Spring'};

% Iterate over each location
for i = 1:length(locations)
    % Create a new figure for the current location
    figure;
    
    location = locations{i};
    full_name = full_names{i};

    % Extract wave direction, peak wave height, and wave period
    wave_directions = organized_data.([location '_Dp_deg']);  % Replace 'Dp_deg' with appropriate column name
    wave_periods = organized_data.([location '_Tp_s']);  % Replace 'Tp_s' with appropriate column name
    
    % Convert direction data to angles
    % The first 2*pi - and the last -0.5*pi components align the figure
    % with true north
    direction_angles = 2*pi - ((mod(round(wave_directions / 10), 35) * pi / 18)-0.5*pi); 
    
    % Create subplots for each season
    for j = 1:length(seasons)
        % Parse start and end dates for the current season
        start_date_season = datetime(seasons{j}(1:10), 'InputFormat', 'dd-MM-yyyy');
        end_date_season = datetime(seasons{j}(15:end), 'InputFormat', 'dd-MM-yyyy');

        % Filter data for the current season and location
        season_data = organized_data(organized_data.Time >= start_date_season & organized_data.Time <= end_date_season, :);
        wave_directions_season = season_data.([location '_Dp_deg']);
        wave_periods_season = season_data.([location '_Tp_s']);

        % Convert direction data to angles for the current season
        direction_angles_season = 2*pi - ((mod(round(wave_directions_season / 10), 35) * pi / 18)-0.5*pi); 

        % Split the data based on the threshold for the current season
        short_periods_directions_season = direction_angles_season(wave_periods_season <= threshold);
        long_periods_directions_season = direction_angles_season(wave_periods_season > threshold);

        % Calculate the subplot index
        if j <= 2
            subplot(2, 2, j); % Top row for summer and autumn
        else
            subplot(2, 2, j - 2 + 2); % Bottom row for winter and spring
        end
        
        % Plot the polar histogram for the current season and location
        polarhistogram(short_periods_directions_season, 36, 'FaceColor', 'blue', 'EdgeColor', 'none', 'Normalization', 'probability', 'DisplayName', 'Sea waves (Tp ≤ 8 s)');
        hold on;
        polarhistogram(long_periods_directions_season, 36, 'FaceColor', 'red', 'EdgeColor', 'none', 'Normalization', 'probability', 'DisplayName', 'Swell waves (Tp > 8 s)');
        title([season_names{j}]);
        thetaticks([0 45 90 135 180 225 270 315]);
        thetaticklabels({'E','NE','N','NW','W','SW','S','SE'});

        % Get the radial axis handle
        hAx = gca;
        % Get the current radial axis label
        radialLabel = hAx.RTickLabel;
        % Convert label values to numbers, multiply by 100, and append the percentage sign
        radialLabel = strcat(string(str2double(radialLabel) * 100), {' %'});
        hAx.RTickLabel = radialLabel;
    end

    % Add common legend without title with custom position
    legend('Position', [0.405, 0.1, 0.2, 0.05]);

    % Set legend title separately
    legendTitle = 'Sea & Swell waves';
    hLegend = findobj(gcf, 'Type', 'Legend');
    hLegend.Title.String = legendTitle;

    % Add the figure title with manual adjustment for position
    mainTitle = sgtitle(['Sea & Swell wave statistics at ', full_name]);
end

