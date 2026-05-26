% Load organized data
organized_data = readtable('organized_data_aligned.csv');

% Define locations
locations = {'CdC', 'KI', 'Bri', 'Sem'};
full_names = {'Cape du Couedic','Kangaroo Island','Brighton','Semaphore'};

% Define time range
start_date = datetime(2022, 12, 01, 0, 0, 0);
end_date = datetime(2024, 02, 22, 23, 0, 0);
time_range = start_date:hours(1):end_date;

% Define custom colors for bins
custom_colors = [
    1, 0, 0;     % Red
    1, 0.5, 0;   % Orange
    1, 1, 0;     % Yellow
    0, 1, 0;     % Green
    0, 1, 1;     % Cyan
    0, 0.5, 1;   % Light Blue
    0, 0, 1;     % Blue
    0.5, 0, 1;   % Purple
    ];  % You can add more colors as needed

% Iterate over each location
for i = 1:length(locations)
    % Create a new figure for the current location
    figure;
    
    location = locations{i};
    full_name = full_names{i};

    % Extract wave direction, peak wave height, and wave period
    wave_directions = organized_data.([location '_Dp_deg']);  % Replace 'Dp_deg' with appropriate column name
    peak_wave_heights = organized_data.([location '_Hsig_m']);  % Replace 'Hsig_m' with appropriate column name
    wave_periods = organized_data.([location '_Tp_s']);  % Replace 'Tp_s' with appropriate column name
    
    dir = 2*pi - ((wave_directions*pi/180)-0.5*pi); %convert to radians
    dat=[peak_wave_heights dir];
    dat2=sortrows(dat);
    
    heights=dat2(:,1);
    dirs=dat2(:,2);

    %create categorical values of wave height
    xn=9; % number of bins for wave heights
    yn=36; %number of bins for direction
    [N,Xedges,Yedges] = histcounts2(heights,dirs,[xn yn]);
    %N=number of occurrences at specific wave height and direction
    %xedges= bin edges of wave heights
    %yedges=bin edges of directions
    
    %turn N into a probability 
    ocur=sum(sum(N)); %number of occurrences
    probs=(N/ocur)*100; %probability of occurrence as a percentage

    % Plot the polar histogram with custom colors
    for j = 1:size(custom_colors, 1)
        fig = polarhistogram('BinEdges', Yedges, 'BinCounts', probs(j,:));
        fig.FaceColor = custom_colors(j, :);
        hold on;
    end

    % Plot directional wave rose also inverse and correct for true north
    % within the polarhistogram code
    title(['Wave Rose - ', full_name]);
    thetaticks([0 45 90 135 180 225 270 315]);
    thetaticklabels({'E','NE','N','NW','W','SW','S','SE'});
    rtickformat('percentage');
    legendCell = cellstr(num2str(Xedges(3:length(Xedges))', '%1.1f'));
    lgd = legend(legendCell);
    title(lgd,'Hs(m)');
end

