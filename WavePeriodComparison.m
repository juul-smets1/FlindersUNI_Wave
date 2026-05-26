% Load organized data
organized_data = readtable('organized_data_aligned_DirectionalEnergy.csv');

% Define locations
locations = {'KI', 'Sem', 'Bri'};
full_names = {'Kangaroo Island', 'Semaphore', 'Brighton'};

% Define a custom colormap starting from white
cmap = jet(10527); % Use the entire rainbow spectrum colormap
cmap(1,:) = [1,1,1]; % Set the color for 0 bin counts to white

% Define the bin edges for the wave periods
bin_edges = [0:1:25, Inf];

% Iterate over each location pair
for i = 1:length(locations)
    for j = i+1:length(locations)
        % Extract wave periods for both locations
        wave_periods_i = organized_data.([locations{i} '_Tp_s']);  
        wave_periods_j = organized_data.([locations{j} '_Tp_s']);  

        % Remove NaN values
        valid_indices = ~isnan(wave_periods_i) & ~isnan(wave_periods_j);
        wave_periods_i = wave_periods_i(valid_indices);
        wave_periods_j = wave_periods_j(valid_indices);

        % Initialize matrix to store counts
        counts = zeros(length(bin_edges)-1);

        % Assign observations to bins
        for k = 1:length(wave_periods_i)
            bin_i = find(wave_periods_i(k) >= bin_edges, 1, 'last');
            bin_j = find(wave_periods_j(k) >= bin_edges, 1, 'last');
            counts(bin_i, bin_j) = counts(bin_i, bin_j) + 1;
        end

        % Create a heatmap for wave period distribution
        figure;
        h = heatmap(bin_edges(1:end-1), bin_edges(1:end-1), counts', 'Colormap', cmap);
        h.XDisplayLabels = cellstr(string(bin_edges(1:end-1)));
        h.YDisplayLabels = cellstr(string(bin_edges(1:end-1)));
        xlabel(sprintf('Wave Period (s) - %s', full_names{i}));
        ylabel(sprintf('Wave Period (s) - %s', full_names{j}));
        title(sprintf('Wave Period Distribution between %s and %s', full_names{i}, full_names{j}));
    end
end

