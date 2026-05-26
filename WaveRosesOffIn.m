clear all
close all
clc
addpath ('R:\CSE-BEADS Lab\TOOLS\MATLAB ROUTINES\Downloads')

%load data manually -in this case called CombinedAveWind

% Read in offshore wave data and interpolate it the full half hour time
% steps 

off_data = readmatrix('C:\Users\uphu0001\OneDrive - Flinders\Documents\03_Measurement_data\WaveBuoyData\Offshore\SPOT-30849C_start to-2023-12-24_download.csv');

%Only use columns that are interesting 4 is epoch time, 5 is Hs, 6 is Tp, 8
%is peak dir and 9 is speak dir spread
%Patrition 0(swell): Hs 730, Tm 731, dirm 732 dirmspreas 733
%Patrition 1(wind): Hs 736, Tm 737, dirm 738 dirmspreas 739

%Have directions at the end because we need different linear interpolation
%for them 
off_data=off_data(:,[4, 5, 6, 9,730,731,733,736,737,739,10,732,738]);

% Find rows containing NaN values
off_rows_with_nan = any(isnan(off_data), 2);

% Remove rows containing NaN values
off_data = off_data(~off_rows_with_nan, :);

%Sort rows and remove identical ones
off_data = unique(sortrows(off_data, 1),'rows');

%Remove rows that are identical

% Convert epoch time to datetime format
off_epoch_time = datetime(off_data(:, 1), 'ConvertFrom', 'posixtime');

% Create datetime array with half-hour intervals starting 
half_hour_intervals = datetime(2022, 12, 19,16,0,0,0):minutes(30):datetime(2023,12,24,16,0,0,0);

% Initialize interpolated data matrix
off_interpolated_data = NaN(numel(half_hour_intervals), size(off_data, 2));

% Perform linear interpolation for each column (2 to 5) except of the
% directional column because we cannot do linear interpolation here
for i = 2:(size(off_data, 2)-3)
    % Perform interpolation for each half-hour interval
    for j = 1:numel(half_hour_intervals)
        % Find closest measured time steps within 30 minutes
        idx = find(abs(off_epoch_time - half_hour_intervals(j)) <= minutes(30));
        if ~isempty(idx)&& length(idx)>1
            % Perform linear interpolation
            off_interpolated_data(j, i) = interp1(off_epoch_time(idx), off_data(idx, i), half_hour_intervals(j), 'linear');
        end
    end
end

%Do linear interpolation for direction which is given in degrees 
%Create an additional vector with converted angles
off_unit_vector=[cosd(off_data(:,11)), sind(off_data(:,11))];
off_interpolated_unit_vector=NaN(numel(half_hour_intervals), 2);

off_unit_vector0=[cosd(off_data(:,12)), sind(off_data(:,12))];
off_interpolated_unit_vector0=NaN(numel(half_hour_intervals), 2);

off_unit_vector1=[cosd(off_data(:,13)), sind(off_data(:,13))];
off_interpolated_unit_vector1=NaN(numel(half_hour_intervals), 2);

for j = 1:numel(half_hour_intervals)
        % Find closest measured time steps within 30 minutes
        idx = find(abs(off_epoch_time - half_hour_intervals(j)) <= minutes(30));
        if ~isempty(idx)&& length(idx)>1
            % Perform linear interpolation for cos and sin component
            off_interpolated_unit_vector(j,1)=interp1(off_epoch_time(idx), off_unit_vector(idx, 1), half_hour_intervals(j), 'linear');
            off_interpolated_unit_vector(j,2)=interp1(off_epoch_time(idx), off_unit_vector(idx, 2), half_hour_intervals(j), 'linear');

            off_interpolated_data(j, 11)= mod(atan2d(off_interpolated_unit_vector(j, 2), off_interpolated_unit_vector(j, 1)),360);

            off_interpolated_unit_vector0(j,1)=interp1(off_epoch_time(idx), off_unit_vector0(idx, 1), half_hour_intervals(j), 'linear');
            off_interpolated_unit_vector0(j,2)=interp1(off_epoch_time(idx), off_unit_vector0(idx, 2), half_hour_intervals(j), 'linear');

            off_interpolated_data(j, 12)= mod(atan2d(off_interpolated_unit_vector0(j, 2), off_interpolated_unit_vector0(j, 1)),360);

            off_interpolated_unit_vector1(j,1)=interp1(off_epoch_time(idx), off_unit_vector1(idx, 1), half_hour_intervals(j), 'linear');
            off_interpolated_unit_vector1(j,2)=interp1(off_epoch_time(idx), off_unit_vector1(idx, 2), half_hour_intervals(j), 'linear');

            off_interpolated_data(j, 13)= mod(atan2d(off_interpolated_unit_vector1(j, 2), off_interpolated_unit_vector1(j, 1)),360);
        end
 end

% Assign half-hour intervals to the first column
off_interpolated_data(:, 1) =posixtime(half_hour_intervals);

% Remove rows with NaN values
off_interpolated_data = off_interpolated_data(~any(isnan(off_interpolated_data(:, 2:end)), 2), :);

%---------------------------------------------------------------------------------------------------------------------

% Read in inshore wave data and interpolate it the full half hour time
% steps 

in_data = readmatrix('C:\Users\uphu0001\OneDrive - Flinders\Documents\03_Measurement_data\WaveBuoyData\Inshore\SPOT-30852C_start_to_2024-01-18_download.csv');

%Only use columns that are interesting 4 is epoch time, 5 is Hs, 6 is Tp, 8
%is peak dir and 9 is speak dir spread
in_data=in_data(:,[4, 5, 6, 9,730,731,733,736,737,739,10,732,738]);

% Find rows containing NaN values
in_rows_with_nan = any(isnan(in_data), 2);

% Remove rows containing NaN values
in_data = in_data(~in_rows_with_nan, :);

%Sort rows and remove identical ones
in_data = unique(sortrows(in_data, 1),'rows');

%Remove rows that are identical

% Convert epoch time to datetime format
in_epoch_time = datetime(in_data(:, 1), 'ConvertFrom', 'posixtime');

% Initialize interpolated data matrix
in_interpolated_data = NaN(numel(half_hour_intervals), size(in_data, 2));

% Perform linear interpolation for each column (2 to 5) except of the
% directional column because we cannot do linear interpolation here
for i = 2:(size(in_data, 2)-3)
    % Perform interpolation for each half-hour interval
    for j = 1:numel(half_hour_intervals)
        % Find closest measured time steps within 30 minutes
        idx = find(abs(in_epoch_time - half_hour_intervals(j)) <= minutes(30));
        if ~isempty(idx)&& length(idx)>1
            % Perform linear interpolation
            in_interpolated_data(j, i) = interp1(in_epoch_time(idx), in_data(idx, i), half_hour_intervals(j), 'linear');
        end
    end
end

%Do linear interpolation for direction which is given in degrees 
%Create an additional vector with converted angles
in_unit_vector=[cosd(in_data(:,11)), sind(in_data(:,11))];
in_interpolated_unit_vector=NaN(numel(half_hour_intervals), 2);

in_unit_vector0=[cosd(in_data(:,12)), sind(in_data(:,12))];
in_interpolated_unit_vector0=NaN(numel(half_hour_intervals), 2);

in_unit_vector1=[cosd(in_data(:,13)), sind(in_data(:,13))];
in_interpolated_unit_vector1=NaN(numel(half_hour_intervals), 2);

for j = 1:numel(half_hour_intervals)
        % Find closest measured time steps within 30 minutes
        idx = find(abs(in_epoch_time - half_hour_intervals(j)) <= minutes(30));
        if ~isempty(idx)&& length(idx)>1
            % Perform linear interpolation for cos and sin component
            in_interpolated_unit_vector(j,1)=interp1(in_epoch_time(idx), in_unit_vector(idx, 1), half_hour_intervals(j), 'linear');
            in_interpolated_unit_vector(j,2)=interp1(in_epoch_time(idx), in_unit_vector(idx, 2), half_hour_intervals(j), 'linear');

            in_interpolated_data(j, 11)= mod(atan2d(in_interpolated_unit_vector(j, 2), in_interpolated_unit_vector(j, 1)),360);

            in_interpolated_unit_vector0(j,1)=interp1(in_epoch_time(idx), in_unit_vector0(idx, 1), half_hour_intervals(j), 'linear');
            in_interpolated_unit_vector0(j,2)=interp1(in_epoch_time(idx), in_unit_vector0(idx, 2), half_hour_intervals(j), 'linear');

            in_interpolated_data(j, 12)= mod(atan2d(in_interpolated_unit_vector0(j, 2), in_interpolated_unit_vector0(j, 1)),360);

            in_interpolated_unit_vector1(j,1)=interp1(in_epoch_time(idx), in_unit_vector1(idx, 1), half_hour_intervals(j), 'linear');
            in_interpolated_unit_vector1(j,2)=interp1(in_epoch_time(idx), in_unit_vector1(idx, 2), half_hour_intervals(j), 'linear');

            in_interpolated_data(j, 13)= mod(atan2d(in_interpolated_unit_vector1(j, 2), in_interpolated_unit_vector1(j, 1)),360);
        end
 end

% Assign half-hour intervals to the first column
in_interpolated_data(:, 1) =posixtime(half_hour_intervals);

% Remove rows with NaN values
in_interpolated_data = in_interpolated_data(~any(isnan(in_interpolated_data(:, 2:end)), 2), :);

off_time=datetime(off_interpolated_data(:, 1), 'ConvertFrom', 'posixtime');
in_time=datetime(in_interpolated_data(:, 1), 'ConvertFrom', 'posixtime');


% 
off_mo=month(off_time);
in_mo=month(in_time);
% 
% 
% 
off_isWinter = ismember(off_mo, [6,7,8]);   %here you define the seasons by month
off_isSpring = ismember(off_mo, [9,10,11]); 
off_isSummer = ismember(off_mo, [12,1,2]);
off_isAutumn = ismember(off_mo, [3,4,5]); 

in_isWinter = ismember(in_mo, [6,7,8]);   %here you define the seasons by month
in_isSpring = ismember(in_mo, [9,10,11]); 
in_isSummer = ismember(in_mo, [12,1,2]);
in_isAutumn = ismember(in_mo, [3,4,5]); 
% 
off_SummerData=off_interpolated_data(off_isSummer,:);
off_SpringData=off_interpolated_data(off_isSpring,:);
off_WinterData=off_interpolated_data(off_isWinter,:);
off_AutumnData=off_interpolated_data(off_isAutumn,:);

in_SummerData=in_interpolated_data(in_isSummer,:);
in_SpringData=in_interpolated_data(in_isSpring,:);
in_WinterData=in_interpolated_data(in_isWinter,:);
in_AutumnData=in_interpolated_data(in_isAutumn,:);



%plotting
% figure1 = figure;
% t=tiledlayout(1,5);
% t.TileSpacing='normal';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Offshore
%Total wave rose
WindRose(off_interpolated_data(:,11),off_interpolated_data(:,2),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Offshore waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',75)
%Swell wave rose
WindRose(off_interpolated_data(:,12),off_interpolated_data(:,5),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Offshore swell waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',75)
%Wind wave rose
WindRose(off_interpolated_data(:,13),off_interpolated_data(:,8),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Offshore sea waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',40)


%Inshore
%Total wave rose
WindRose(in_interpolated_data(:,11),in_interpolated_data(:,2),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Inshore waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',90)
%Swell wave rose
WindRose(in_interpolated_data(:,12),in_interpolated_data(:,5),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Inshore swell waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',100)
%Wind wave rose
WindRose(in_interpolated_data(:,13),in_interpolated_data(:,8),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Inshore sea waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',60)

%Total wave rose
WindRose(off_WinterData(:,11),off_WinterData(:,2),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Winter offshore waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',40)
%Swell wave rose
WindRose(off_WinterData(:,12),off_WinterData(:,5),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Winter offshore swell waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',50)
%Wind wave rose
WindRose(off_WinterData(:,13),off_WinterData(:,8),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Winter offshore sea waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',40)

%Total wave rose
WindRose(off_SummerData(:,11),off_SummerData(:,2),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Summer offshore waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',40)
%Swell wave rose
WindRose(off_SummerData(:,12),off_SummerData(:,5),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Summer offshore swell waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',50)
%Wind wave rose
WindRose(off_SummerData(:,13),off_SummerData(:,8),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Summer offshore sea waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',40)

%Total wave rose
WindRose(off_SpringData(:,11),off_SpringData(:,2),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Spring offshore waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',75)
%Swell wave rose
WindRose(off_SpringData(:,12),off_SpringData(:,5),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Spring offshore swell waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',75)
%Wind wave rose
WindRose(off_SpringData(:,13),off_SpringData(:,8),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Spring offshore sea waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',40)

%Total wave rose
WindRose(off_AutumnData(:,11),off_AutumnData(:,2),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Autumn offshore waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',75)
%Swell wave rose
WindRose(off_AutumnData(:,12),off_AutumnData(:,5),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Autumn offshore swell waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',75)
%Wind wave rose
WindRose(off_AutumnData(:,13),off_AutumnData(:,8),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Autumn offshore sea waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',40)


%Total wave rose
WindRose(in_WinterData(:,11),in_WinterData(:,2),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Winter inshore waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',90)
%Swell wave rose
WindRose(in_WinterData(:,12),in_WinterData(:,5),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Winter inshore swell waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',100)
%Wind wave rose
WindRose(in_WinterData(:,13),in_WinterData(:,8),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Winter inshore sea waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',80)

%Total wave rose
WindRose(in_SummerData(:,11),in_SummerData(:,2),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Summer inshore waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',90)
%Swell wave rose
WindRose(in_SummerData(:,12),in_SummerData(:,5),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Summer inshore swell waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',100)
%Wind wave rose
WindRose(in_SummerData(:,13),in_SummerData(:,8),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Summer inshore sea waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',80)

%Total wave rose
WindRose(in_SpringData(:,11),in_SpringData(:,2),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Spring inshore waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',90)
%Swell wave rose
WindRose(in_SpringData(:,12),in_SpringData(:,5),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Spring inshore swell waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',100)
%Wind wave rose
WindRose(in_SpringData(:,13),in_SpringData(:,8),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Spring inshore sea waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',80)

%Total wave rose
WindRose(in_AutumnData(:,11),in_AutumnData(:,2),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Autumn inshore waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',90)
%Swell wave rose
WindRose(in_AutumnData(:,12),in_AutumnData(:,5),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Autumn inshore swell waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',100)
%Wind wave rose
WindRose(in_AutumnData(:,13),in_AutumnData(:,8),'ndirections',24,'vwinds',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5],'titlestring','Autumn inshore sea waves','lablegend','Wave height (m)','cmap',hsv,'anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',80)





%WindRose(data.dir,data.hs,'ndirections',16,'vwinds',[1 2 3 4 5 6],'titlestring','Offshore waves','lablegend','Wave height (m)','anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',100)

%WindRose(SummerData.speed_dir2,SummerData.speed_dir1,'ndirections',16,'vwinds',[0 10 20 30 40],'titlestring','Summer','lablegend','Wind Speed (km/h)','anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',25)

%WindRose(AutumnData.speed_dir2,AutumnData.speed_dir1,'ndirections',16,'vwinds',[0 10 20 30 40],'titlestring','Autumn','lablegend','Wind Speed (km/h)','anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',25)

%WindRose(WinterData.speed_dir2,WinterData.speed_dir1,'ndirections',16,'vwinds',[0 10 20 30 40],'titlestring','Winter','lablegend','Wind Speed (km/h)','anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',25)

%WindRose(SpringData.speed_dir2,SpringData.speed_dir1,'ndirections',16,'vwinds',[0 10 20 30 40],'titlestring','Spring','lablegend','Wind Speed (km/h)','anglenorth',0,'angleeast',90,'freqlabelangle',30,'maxfrequency',25)
