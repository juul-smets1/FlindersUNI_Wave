% Load organized data
organized_data = readtable('organized_data_aligned_DirectionalEnergy.csv');

% Define locations
locations = {'CdC', 'KI', 'Bri', 'Sem'};
full_names = {'Cape du Couedic','Kangaroo Island','Brighton','Semaphore'};

% Define direction bins
direction_bins = [-Inf, 210:3:300, Inf];

% Define custom period bins for each location
period_bins_custom = {
    [0:40:800, Inf],   % CdC
    [0:12.5:250, Inf], % KI
    [0:1:20, Inf],     % Bri
    [0:1:20, Inf]      % Sem
};

% Define a custom colormap starting from white (or any other color you prefer)
cmap = jet(10527); % Use the entire rainbow spectrum colormap Use number od max bin counts to adjust jet
cmap(1,:) = [1,1,1]; % Set the color for 0 bin counts to white

% Iterate over each location
for i = 1:length(locations)
    if strcmp(locations{i}, 'KI') % Check if the location is Kangaroo Island (KI)
        % Initialize a matrix to store the counts for each bin combination
        bin_counts = zeros(length(direction_bins)-1, length(period_bins_custom{i})-1);

        location = locations{i};
        full_name = full_names{i};

        % Extract wave direction, peak wave height, wave period, and directional energy
        wave_directions = organized_data.([location '_Dp_deg']);  
        wave_energy = organized_data.([location '_P_kW_m']);  

        % Remove NaN values
        valid_indices = ~isnan(wave_directions) & ~isnan(wave_energy);
        wave_directions = wave_directions(valid_indices);
        wave_energy = wave_energy(valid_indices);

        % Bin wave periods and directions
        period_index = discretize(wave_energy, period_bins_custom{i});
        direction_index = discretize(wave_directions, direction_bins);

        % Iterate through each row of the indices
        for j = 1:length(period_index)
            % Determine the bin indices for period and direction
            d_index = round(direction_index(j));
            p_index = round(period_index(j));

            % Increment the corresponding bin count
            if ~isnan(d_index) && ~isnan(p_index)
                bin_counts(d_index, p_index) = bin_counts(d_index, p_index) + 1;
            end
        end

        % Transpose bin_counts
        bin_counts = bin_counts';

        % Compute total count
        total_count = sum(bin_counts, 'all');

        % Create a heatmap for directional energy distribution
        figure;
        h = heatmap(direction_bins(1:end-1), period_bins_custom{i}(1:end-1), bin_counts, ...
            'XLabel', 'Wave Direction (°N)', 'YLabel', 'Wave Energy Flux (kW/m)', ...
            'Colormap', cmap);
        title(h, sprintf('Directional Wave Energy Flux Distribution at %s (Total Count: %d)', full_name, total_count));

        % Set x and y axis tick locations and labels
        h.XData = direction_bins(1:end-1);
        h.YData = period_bins_custom{i}(1:end-1);

        % Customize x axis tick labels for direction bins
        xticklabels = cell(length(direction_bins)-1, 1);
        for k = 1:length(direction_bins)-1
            if direction_bins(k) == -Inf
                xticklabels{k} = '< 210';
            elseif direction_bins(k+1) == Inf
                xticklabels{k} = '> 300';
            else
                xticklabels{k} = sprintf('%d - %d', direction_bins(k), direction_bins(k+1));
            end
        end
        h.XDisplayLabels = xticklabels;

       % Customize y axis tick labels for period bins
       yticklabels = cell(length(period_bins_custom{i})-1, 1);
       for l = 1:length(period_bins_custom{i})-1
           if l < length(period_bins_custom{i})-1
               yticklabels{l} = sprintf('%.1f - %.1f', period_bins_custom{i}(l), period_bins_custom{i}(l+1));
           else
               % For the last bin, include the ">" symbol
               yticklabels{l} = sprintf('> %.1f', period_bins_custom{i}(l));
           end
       end 
       h.YDisplayLabels = yticklabels;


        % Show grid lines between bins
        h.GridVisible = 'on';
    end
end

