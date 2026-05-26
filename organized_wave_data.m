% Read data from existing CSV files
CdC_data = readtable('C:\Users\smet0008\OneDrive - Flinders\Wave data\Raw Wave Data\Cape-du-Couedic-wave-data.csv');
KI_data = readtable('C:\Users\smet0008\OneDrive - Flinders\Wave data\Raw Wave Data\KI_buoy-867-wave-data-1669888800-1708585200.csv');
Bri_data = readtable('C:\Users\smet0008\OneDrive - Flinders\Wave data\Raw Wave Data\Brighton_buoy-940-wave-data-1669885200-1709190000.csv');
Sem_data = readtable('C:\Users\smet0008\OneDrive - Flinders\Wave data\Raw Wave Data\Semaphore_buoy-8000000-wave-data-1669863600-1694221200.csv');

% Define time range
start_date = datetime(2022, 12, 01, 0, 0, 0);
end_date = datetime(2024, 02, 22, 23, 0, 0);
time_range = start_date:hours(1):end_date;

% Create empty table to store organized data
output_data = table(time_range', 'VariableNames', {'Time'});

% Initialize columns for each data type
for loc = {'CdC', 'KI', 'Bri', 'Sem'}
    direction = [];
    peak_wave_height = [];
    wave_period = [];
    
    % Extract data from each location
    location = loc{1};
    loc_data = eval([location '_data']); % Evaluate variable name dynamically
    
    % Match timestamps and fill data
    for i = 1:numel(time_range)
        timestamp = time_range(i);
        idx = find(loc_data.Timestamp == timestamp, 1);
        
        if isempty(idx)
            % Fill missing data with NaNs or blanks
            direction(i, 1) = NaN;
            peak_wave_height(i, 1) = NaN;
            wave_period(i, 1) = NaN;
        else
            % Fill data if timestamp exists
            direction(i, 1) = loc_data.Dp_deg(idx);
            peak_wave_height(i, 1) = loc_data.Hsig_m(idx);
            wave_period(i, 1) = loc_data.Tp_s(idx);
        end
    end
    
    % Add data to the output table
    output_data.([location '_direction']) = direction;
    output_data.([location '_peak_wave_height']) = peak_wave_height;
    output_data.([location '_wave_period']) = wave_period;
end

% Write output to CSV file
writetable(output_data, 'organized_data.csv');
