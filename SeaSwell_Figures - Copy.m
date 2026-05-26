% Load organized data for polar histograms
organized_data_polar = readtable('organized_data_aligned.csv');

% Load organized data for heatmap
organized_data_heatmap = readtable('organized_data_aligned_DirectionalEnergy.csv');

% Load organized data for histograms
organized_data_histogram = readtable('organized_data_aligned_DirectionalEnergy.csv');

% Define locations and corresponding full names
locations = {'CdC', 'KI', 'Bri', 'Sem'};
full_names = {'Cape du Couedic', 'Kangaroo Island', 'Brighton', 'Semaphore'};

% Define seasons
seasons = {'22-12-2022 to 20-03-2023', '21-03-2023 to 21-06-2023', '22-06-2023 to 22-09-2023', '23-09-2023 to 21-12-2023'};
season_names = {'Summer', 'Autumn', 'Winter', 'Spring'};

% Define threshold for distinguishing between shorter and longer wave periods
threshold = 8;

% Initialize figure counter
fig_count = 1;

% Iterate over each location
for l = 1:length(locations)
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

    % Create a new figure for the current location
    figure(fig_count);
    
    % Subplot index
    subplot_index = 1;

    % Polar histograms for sea and swell waves
    for j = 1:length(seasons)
        % Parse start and end dates for the current season
        start_date = datetime(seasons{j}(1:10), 'InputFormat', 'dd-MM-yyyy');
        end_date = datetime(seasons{j}(15:end), 'InputFormat', 'dd-MM-yyyy');

        % Filter data for the current season and location
        season_data = organized_data_polar(organized_data_polar.Time >= start_date & organized_data_polar.Time <= end_date, :);
        wave_directions = season_data.([location '_Dp_deg']);
        wave_periods = season_data.([location '_Tp_s']);

        % Convert direction data to angles
        direction_angles = 2*pi - ((mod(round(wave_directions / 10), 35) * pi / 18)-0.5*pi); 

        % Split the data based on the threshold for the current season
        short_periods_directions = direction_angles(wave_periods <= threshold);
        long_periods_directions = direction_angles(wave_periods > threshold);

        % Calculate the subplot index
        subplot(2, 4, subplot_index);
        
        % Plot the polar histogram for the current season and location
        polarhistogram(short_periods_directions, 36, 'FaceColor', 'blue', 'EdgeColor', 'none', 'Normalization', 'probability', 'DisplayName', 'Sea waves (Tp ≤ 8 s)');
        hold on;
        polarhistogram(long_periods_directions, 36, 'FaceColor', 'red', 'EdgeColor', 'none', 'Normalization', 'probability', 'DisplayName', 'Swell waves (Tp > 8 s)');
        title([season_names{j}, ' wave directions']);
        thetaticks([0 45 90 135 180 225 270 315]);
        thetaticklabels({'E','NE','N','NW','W','SW','S','SE'});

        % Get the radial axis handle
        hAx = gca;
        % Get the current radial axis label
        radialLabel = hAx.RTickLabel;
        % Convert label values to numbers, multiply by 100, and append the percentage sign
        radialLabel = strcat(string(str2double(radialLabel) * 100), {' %'});
        hAx.RTickLabel = radialLabel;

        subplot_index = subplot_index + 1;
    end

    % Heatmap for wave counts
    subplot(2, 2, 3);
    wave_counts = zeros(2, length(seasons));
    for i = 1:length(seasons)
        start_date = datetime(seasons{i}(1:10), 'InputFormat', 'dd-MM-yyyy');
        end_date = datetime(seasons{i}(15:end), 'InputFormat', 'dd-MM-yyyy');
        season_data = organized_data_heatmap(organized_data_heatmap.Time >= start_date & organized_data_heatmap.Time <= end_date, :);
        season_data = season_data(~isnan(season_data.([location '_Tp_s'])), :);
        wave_counts(1, i) = sum(season_data.([location '_Tp_s']) <= threshold);
        wave_counts(2, i) = sum(season_data.([location '_Tp_s']) > threshold);
    end
    total_counts = sum(wave_counts(:));
    heatmap(season_names, {'Sea waves (Tp ≤ 8 s)', 'Swell waves (Tp > 8 s)'}, wave_counts, 'Colormap', cmap, 'ColorbarVisible', 'on');
    title(sprintf('Bin counts (Total Count: %d)', total_counts));
    xlabel('Season');

    % Histogram for percentage of sea and swell waves
    subplot(2, 2, 4);
    sea_counts = zeros(1, length(seasons));
    swell_counts = zeros(1, length(seasons));
    for i = 1:length(seasons)
        start_date = datetime(seasons{i}(1:10), 'InputFormat', 'dd-MM-yyyy');
        end_date = datetime(seasons{i}(15:end), 'InputFormat', 'dd-MM-yyyy');
        season_data = organized_data_histogram(organized_data_histogram.Time >= start_date & organized_data_histogram.Time <= end_date & ~isnan(organized_data_histogram.([location '_Tp_s'])), :);
        if ~isempty(season_data)
            sea_counts(i) = sum(season_data.([location '_Tp_s']) <= 8);
            swell_counts(i) = sum(season_data.([location '_Tp_s']) > 8);
        else
            sea_counts(i) = NaN;
            swell_counts(i) = NaN;
        end
    end
    total_counts = arrayfun(@(idx) sum(~isnan(organized_data_histogram.([location '_Tp_s'])) & organized_data_histogram.Time >= datetime(seasons{idx}(1:10), 'InputFormat', 'dd-MM-yyyy') & organized_data_histogram.Time <= datetime(seasons{idx}(15:end), 'InputFormat', 'dd-MM-yyyy')), 1:length(seasons));
    sea_percentage = (sea_counts ./ total_counts) * 100;
    swell_percentage = (swell_counts ./ total_counts) * 100;
    bar_data = [sea_percentage; swell_percentage]';
    h = bar(1:length(seasons), bar_data, 'grouped');
    h(1).FaceColor = 'b';
    h(2).FaceColor = 'r';
    title(sprintf('Sea-Swell Ratio'));
    xlabel('Season');
    ylabel('Percentage (%)');
    xticks(1:length(seasons));
    set(gca, 'XTickLabel', season_names);
    ylim([0 110]);

    % Define the legend
    legend('Sea waves (Tp ≤ 8 s)', 'Swell waves (Tp > 8 s)', 'Position', [0.8, 0.5, 0.2, 0.05]);

    % Set legend title separately
    legendTitle = 'Sea & Swell waves';
    hLegend = findobj(gcf, 'Type', 'Legend');
    hLegend.Title.String = legendTitle;
    
   %location for main title?

    for i = 1:length(seasons)
        x_pos = h(1).XData(i);
        y_pos_sea = sea_percentage(i);
        y_pos_swell = swell_percentage(i);
        text(x_pos -0.15, y_pos_sea, sprintf('%.1f%%', y_pos_sea), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
        text(x_pos +0.15, y_pos_swell, sprintf('%.1f%%', y_pos_swell), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
    end

    fig_count = fig_count + 1;

    % Add the figure title with manual adjustment for position
    mainTitle = sgtitle(['Sea & Swell statistics at ', full_name]);
end

