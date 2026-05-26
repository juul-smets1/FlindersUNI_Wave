% Load organized data
organized_data = readtable('organized_data_aligned_DirectionalEnergy.csv');

% Define seasons
seasons = {'summer', 'autumn', 'winter', 'spring'};
season_dates = {'22-12-22', '20-03-23'; '21-03-23', '21-06-23'; '22-06-23', '22-09-23'; '23-09-23', '21-12-23'};

% Convert season dates to datetime format
season_dates = datetime(season_dates, 'InputFormat', 'dd-MM-yy');

% Define locations
locations = {'CdC', 'KI', 'Bri', 'Sem'};

% Initialize a structure to store average energy flux and standard deviation for each season and location
stats_season_location = struct();

% Iterate over each season
for s = 1:length(seasons)
    start_date = season_dates(s, 1);
    end_date = season_dates(s, 2);
    
    % Filter data for the current season
    season_data = organized_data(organized_data.Time >= start_date & organized_data.Time <= end_date, :);
    
    % Initialize array to store energy flux for each location
    energy_flux = zeros(height(season_data), length(locations));
    
    % Iterate over each location
    for l = 1:length(locations)
        location = locations{l};
        
        % Extract energy data for the current location and season
        energy_data = season_data.([location '_P_kW_m']);
        
        % Store energy flux for the current location
        energy_flux(:, l) = energy_data;
    end
    
    % Calculate average energy flux and standard deviation for each location during the current season
    average_energy_flux = mean(energy_flux, 'omitnan');
    std_energy_flux = std(energy_flux, 'omitnan');
    
    % Store average energy flux and standard deviation in the structure
    for l = 1:length(locations)
        location = locations{l};
        stats_season_location(s).(location).average_energy_flux = average_energy_flux(l);
        stats_season_location(s).(location).std_energy_flux = std_energy_flux(l);
    end
end

% Display average energy flux and standard deviation for each season and location
for s = 1:length(seasons)
    fprintf('Season: %s\n', seasons{s});
    for l = 1:length(locations)
        location = locations{l};
        average_energy_flux = stats_season_location(s).(location).average_energy_flux;
        std_energy_flux = stats_season_location(s).(location).std_energy_flux;
        fprintf('%s: Average Energy Flux = %.2f kW/m, Standard Deviation = %.2f kW/m\n', location, average_energy_flux, std_energy_flux);
    end
    fprintf('\n');
end


