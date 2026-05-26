% Load organized data
organized_data = readtable('organized_data_aligned_DirectionalEnergy.csv');

% Define locations and corresponding full names
locations = {'CdC', 'KI', 'Bri', 'Sem'};
full_names = {'Cape du Couedic', 'Kangaroo Island', 'Brighton', 'Semaphore'};

% Define seasons
seasons = {'22-12-2022 to 20-03-2023', '21-03-2023 to 21-06-2023', '22-06-2023 to 22-09-2023', '23-09-2023 to 21-12-2023'};
season_names = {'Summer', 'Autumn', 'Winter', 'Spring'};

% Initialize figure counter
fig_count = 1;

% Iterate over each location
for l = 1:length(locations)
    % Extract location-specific data
    location = locations{l};
    full_name = full_names{l};
    
    % Initialize arrays to store sea and swell wave counts for each season
    sea_counts = zeros(1, length(seasons));
    swell_counts = zeros(1, length(seasons));
    
    % Iterate over each season
    for i = 1:length(seasons)
        % Parse start and end dates for the current season
        start_date = datetime(seasons{i}(1:10), 'InputFormat', 'dd-MM-yyyy');
        end_date = datetime(seasons{i}(15:end), 'InputFormat', 'dd-MM-yyyy');

        % Filter data for the current season and location
        season_data = organized_data(organized_data.Time >= start_date & organized_data.Time <= end_date & ~isnan(organized_data.([location '_Tp_s'])), :);

        % Count sea and swell waves for the current season if data exists
        if ~isempty(season_data)
            sea_counts(i) = sum(season_data.([location '_Tp_s']) <= 8);
            swell_counts(i) = sum(season_data.([location '_Tp_s']) > 8);
        else
            % If no data for this season, set counts to NaN
            sea_counts(i) = NaN;
            swell_counts(i) = NaN;
        end
    end

    % Calculate total data observations for each season
    total_counts = arrayfun(@(idx) sum(~isnan(organized_data.([location '_Tp_s'])) & organized_data.Time >= datetime(seasons{idx}(1:10), 'InputFormat', 'dd-MM-yyyy') & organized_data.Time <= datetime(seasons{idx}(15:end), 'InputFormat', 'dd-MM-yyyy')), 1:length(seasons));

    % Calculate relative amount of sea and swell waves as percentage
    sea_percentage = (sea_counts ./ total_counts) * 100;
    swell_percentage = (swell_counts ./ total_counts) * 100;

    % Create a new figure
    figure(fig_count);
    fig_count = fig_count + 1;

    % Plot histograms for sea and swell waves
    h = bar(1:length(seasons), [sea_percentage; swell_percentage]', 'grouped');

    % Set the color of sea waves (Tp <= 8 s) to blue
    h(1).FaceColor = 'b';

    % Set the color of swell waves (Tp > 8 s) to red
    h(2).FaceColor = 'r';

    title(sprintf('Sea & Swell waves at %s', full_name));
    xlabel('Season');
    ylabel('Percentage (%)');
    xticks(1:length(seasons));
    set(gca, 'XTickLabel', season_names);
    legend('Sea waves (Tp ≤ 8 s)', 'Swell waves (Tp > 8 s)', 'Location', 'southeast');
    ylim([0 100]);

    % Add percentage values on top of each bar for sea and swell waves
    for i = 1:length(seasons)
        % Calculate the position for the text label
        x_pos = h(1).XData(i);
        y_pos_sea = sea_percentage(i);
        y_pos_swell = swell_percentage(i);
 
        % Add text label for sea waves
        text(x_pos -0.15, y_pos_sea, sprintf('%.1f%%', y_pos_sea), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
 
        % Add text label for swell waves
        text(x_pos +0.15, y_pos_swell, sprintf('%.1f%%', y_pos_swell), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
    end
end



