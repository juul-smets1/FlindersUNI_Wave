%wave rose function

function[fig]=waverose(~)
%Allow user to input a station and a year, code will not work if no
%data/incorrect location or file type
front='http://www.ndbc.noaa.gov/view_text_file.php?filename=';
last='.txt.gz&dir=data/historical/stdmet/';
buoy=input('Enter Station Number\nEnter Alphabetic Characters as Lowercase\n','s');
year=input('Enter Requested Year\n');
year2=num2str(year);
url=strcat(front,buoy,'h',year2,last);
options=weboptions('ContentReader',@readtable);


for fails=1:10 %set up number of times loop will try to pull data before ending
try
data=webread(url,options);


%%

%2005 and earlier has different formatting requirements
if year < 2005 || year ==2005
    WD=data(1:height(data),5); %pulls  the wind direction values
    WD=table2array(WD); %converts file to array format
    WDIR=WD;
    
    WVHT=data(1:height(data),8); %pulls the wave height values
    WVHT=table2array(WVHT); %converts file to array format

    
else
WDIR=data(2:height(data),{'WDIR'}); %pulls  the wind direction values
WDIR=table2array(WDIR); %converts file to array format
WDIR=str2double(WDIR); % converts to double 


WVHT=data(2:height(data),{'WVHT'}); %pulls the wave height values
WVHT=table2array(WVHT); %converts file to array format
WVHT=str2double(WVHT); % converts to double 
end

if WVHT(1:end)==99 %checks for waveheight data 
    disp('No Wave Data at this Location') %end code if data doesnt exist
elseif  WDIR(1:end)>360
    disp('No Wind Data at this Location')
else
dir = WDIR*pi/180; %convert to radians
dat=[WVHT dir];
dat2=sortrows(dat);
%%
%removes data containing 99 values
indices = dat2(:,1)==99;
dat2(indices,:) = [];

heights=dat2(:,1);
dirs=dat2(:,2);

%create categorial values of waveheight
xn=8; % number of bins for wave heights
yn=20; %number of bins for direction
[N,Xedges,Yedges] = histcounts2(heights,dirs,[xn yn]);
%N=number of occurances at specific wave height and direction
%xedges= bin edges of wave heights
%yedges=bin edges of directions

%turn N into a probability 
ocur=sum(sum(N)); %number of occurances
probs=(N/ocur)*100; %probability of occurance as a percentage

polarhistogram('BinEdges',Yedges,'BinCounts',probs(2,:));
%ignore first row since it is 0 values
hold on
for i=3:size(probs,1)
fig=polarhistogram('BinEdges',Yedges,'BinCounts',probs(i,:));
end

% get the location of the buoy

link='http://www.ndbc.noaa.gov/data_availability/data_avail.php?station=';
url2=strcat(link,buoy);

html=urlread(url2);
s=' ';
search=['<title>'];
idx1 = strfind(html,search);
search2=['</title>'];
idx2=strfind(html,search2);
txt=html((idx1+7):(idx2-1));
loc=strsplit(txt);
location=loc(6:end);
location=strjoin(location);

% put the station name and location on the figure
title({[location],'Significant Wave Height and Wind Direction',[year]});
thetaticks([0 90 180 270]);
thetaticklabels({'East','North','West','South'});
rtickformat('percentage');
legendCell = cellstr(num2str(Xedges(3:length(Xedges))', '%1.1f'));
lgd=legend(legendCell);
title(lgd,'Wave Height [meters]');
end
break;

catch
    if fails==10
    disp('Historical Data From This Station or Year Does Not Exist')
    disp('Or Some Webpage Error Exists')
    end 
end
end
end
