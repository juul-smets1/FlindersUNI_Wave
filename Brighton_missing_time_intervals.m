% Define the file path to the CSV file
file_path = 'C:\Users\smet0008\OneDrive - Flinders\Wave data\Raw Wave Data\Brighton_buoy-940-wave-data-1669885200-1709190000.csv';

% Read the CSV file into a table
data_table = readtable(file_path);

% Extract the time column from the table
time_column = data_table.Timestamp; % Assuming the time column in the table is named 'Timestamp'

% Convert the time column to datetime format
time_column_datetime = datetime(time_column, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:sss', 'TimeZone', '');

% Check for missing hours within the continuing dataset of timestamps
expected_time_vector = min(time_column_datetime):hours(1):max(time_column_datetime);
missing_hours = setdiff(expected_time_vector, time_column_datetime);

% Display missing hours
if isempty(missing_hours)
    disp('No missing hours found.');
else
    disp('Missing hours:');
    disp(missing_hours);
end