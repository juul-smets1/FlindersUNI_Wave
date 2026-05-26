% Load organized data
organized_data = readtable('organized_data_aligned.csv');

% Define locations
locations = {'CdC', 'KI', 'Bri', 'Sem'};
full_names = {'Cape du Couedic','Kangaroo Island','Brighton','Semaphore'};

% Iterate over each location
for i = 1:length(locations)
    % Create a new figure for the current location
    location = locations{i};
    full_name = full_names{i};

    % Extract wave direction, peak wave height, and wave period
    wave_directions = organized_data.([location '_Dp_deg']);  % Replace 'Dp_deg' with appropriate column name
    peak_wave_heights = organized_data.([location '_Hsig_m']);  % Replace 'Hsig_m' with appropriate column name
   
    WindRose(wave_directions,peak_wave_heights,'ndirections',32,'vwinds',[0 1 2 3 4 5 6 7 8],'titlestring',...
        ['Wave Rose - ', full_name],'lablegend','Significant Wave Height (m)','anglenorth',0,'angleeast',90, ...
        'labels',{'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'},'freqlabelangle', 22.5, 'cmap',jet);
    legend('Position',[0.85 0.35 0.01 0.01])
end

