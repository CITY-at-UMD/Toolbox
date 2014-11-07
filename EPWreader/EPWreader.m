function [design_cooling_temp, design_heating_temp, daily_cooling_range, average_dry_bulb_temperature_jan, dry_bulb_temperature, diffuse_peak, direct_peak, E_total] = EPWreader(TMY_filename)
%----------------------------------------------------%
% EPWreader.m
%----------------------------------------------------%
%***Description:***
% Reads in an EPW file for key data
%
% Matthew Dahlhausen
% October 2014
%
%***Inputs:***
% -TMYfile
%
%***Outputs:***
% HeatingDegreeDays
% CoolingDegreeDays
% Average monthly/annual DB Temperatures
% Average monthly/annual windspeed
%
%
%%***************************************************%

%% READ IN WEATHER FILE
%addpath('D:\DESKTOP\Courses\UMD\ENME610 - Optimization\Project\weather')
%TMY_filename = '722190TY.csv'; %'724060TY.csv';
fid=fopen(TMY_filename,'r'); % Open TMY file
if fid == -1
  disp(['file not found: ',TMY_filename]);
else
  tmy = read_mixed_csv(TMY_filename,',');      %read the file 
  
  % file header information
  station_name = tmy(1,2); 
  station_state = tmy(1,3); 
  station_time_zone = tmy(1,4);
  site_latitude = str2double(tmy(1,5));
  site_longitude = str2double(tmy(1,6));
  site_elevation = tmy(1,7); 
  
  date = cell(8760,1); % field 1
  time = cell(8760,1); % field 2
  extraterrestrial_horizontal_radiation = ones(8760,1); % field 3, Wh/m^2 
  extraterrestrial_normal_radiation = ones(8760,1); % field 4, Wh/m^2
  global_horizontal_irradiance = ones(8760,1); % field 5, Wh/m^2
  direct_normal_irradiance = ones(8760,1); % field 8, Wh/m^2
  diffuse_horizontal_irradiance = ones(8760,1); % field 11, Wh/m^2
  dry_bulb_temperature = ones(8760,1); % field 32, degC
  dew_point_temperature = ones(8760,1); % field 35, degC
  relative_humidity = ones(8760,1); % field 38
  wind_direction = ones(8760,1); % field 44, deg
  windspeed = ones(8760,1); % field 47, m/s
  
  for i=3:8762 %EOF
    date(i-2) = tmy(i,1);
    time(i-2) = tmy(i,2);
    extraterrestrial_horizontal_radiation(i-2) = str2double(tmy(i,3));
    extraterrestrial_normal_radiation(i-2) = str2double(tmy(i,4));
    global_horizontal_irradiance(i-2) = str2double(tmy(i,5));
    direct_normal_irradiance(i-2) = str2double(tmy(i,8));
    diffuse_horizontal_irradiance(i-2) = str2double(tmy(i,11));
    dry_bulb_temperature(i-2) = str2double(tmy(i,32));
    dew_point_temperature(i-2) = str2double(tmy(i,35));
    relative_humidity(i-2) = str2double(tmy(i,38));
    wind_direction(i-2) = str2double(tmy(i,44));
    windspeed(i-2) = str2double(tmy(i,47));
  end  
end

if fid ~= -1
  fclose(fid); % Close TMY file 
end
clear TM_filename fid tmy i

month = cell(8760,1);
day = cell(8760,1);
for i=1:8760
  foo = strsplit(char(date(i)),'/');
  month(i) = foo(1,1);
  day(i) = foo(1,2);
end

%% CALCULATE WEATHER INFORMATION

order_dry_bulb_temperature = sort(dry_bulb_temperature);
design_cooling_temp = order_dry_bulb_temperature(round(8760*0.99));
design_heating_temp = order_dry_bulb_temperature(round(8760*0.01));

% calculate outdoor air mean dry bulb temperature in january 
count = 0;
average_dry_bulb_temperature_jan = 0;
for i=1:8760
  if strcmp(month(i),'01')
    average_dry_bulb_temperature_jan = average_dry_bulb_temperature_jan + dry_bulb_temperature(i);  
    count = count + 1;    
  end    
end
average_dry_bulb_temperature_jan = average_dry_bulb_temperature_jan/count;

% calculate average daily cooling range in July
daily_cooling_ranges = 0;
july_start = 0;
for i=1:8760
  if strcmp(month(i),'07')
    if july_start == 0 
      july_start = i;
    end
    daily_cooling_ranges(i-july_start+1) = max(dry_bulb_temperature((i-24):(i-1))) - min(dry_bulb_temperature((i-24):(i-1))); 
  end    
end
daily_cooling_range = mean(daily_cooling_ranges);
max_daily_cooling_range = max(daily_cooling_ranges);

%%
% IRRADIANCE CALCULATIONS BASED ON 
% ASHRAE HANDBOOK OF FUNDAMENTALS 2005 - SI
% CHAPTER 30 - NONRESIDENTIAL COOLING AND HEATING LOAD CALCULATIONS
% CHAPTER 31 - FENESTRATION

for i=1:8760
  time_string = strsplit(char(time(i)),':');
  LST(i) = str2double(time_string(1)); % (decimal hours), local solar time
end
LST = LST';

day = (1:8760)*(365/8760); day=day';
ET = -7.655*sind(day) + 9.873*sind(2*day + 3.588); % (decimal minutes), equation of time
LSM = 75; % (decimal ° of arc), local standard time meridian for Eastern Standard Time
LON = -site_longitude; % (decimal ° of arc), local longitude
L = site_latitude; % (decimal ° of arc), local latitude
AST = LST + ET/60 + (LSM - LON)/15; % (decimal hours), apparent solar time 

epsilon = 23.45*sind(((360*(284 + day))/365)); % solar declination 
H = 15*(AST - 12); % (degrees), hour angle 
beta = asind( cosd(L).*cosd(epsilon).*cosd(H) + sind(L).*sind(epsilon) ); % solar alitude
phi = acosd( (sind(beta).*sind(L) - sind(epsilon)) ./ (cosd(beta).*cosd(L)) ); % solar azimuth

psi = 0; % surface azimuth, 0 for due south
gamma = phi - psi; % surface solar azimuth
sigma = 90; % (decimal ° of arc), tilt angle, 90 is vertical
theta = acosd( cosd(beta).*cosd(gamma).*sind(sigma) + sind(beta).*cosd(sigma) ); % (decimal ° of arc), incident angle
Y = 0.45*ones(8760,1); % ratio of sky diffuse radiation on avertical surface to sky diffuse radiation on a horizontal surface
for i=1:length(theta)
  if cosd(theta(i)) > -0.2
    Y(i) = 0.55 + 0.437*cosd(theta(i)) + 0.313*(cosd(theta(i)).^2);
  end
end
rho_g = 0.2; % ground relectivity
theta_horizontal = acosd(sind(beta)); % (decimal ° of arc), incident angle on a horizontal surface

%% PEAK IRRADIANCE
[direct_peak, diffuse_peak, total_peak] = peakIrradiance(site_latitude, psi, 'vertical');

%% ASHRAE CLEAR SKY SOLAR MODEL
A = zeros(8760,1);
B = zeros(8760,1);
C = zeros(8760,1);
for i=1:8760
  switch str2double(month(i))
      case 1
          A(i) = 1202; % (W/m^2)
          B(i) = 0.141;
          C(i) = 0.103;
      case 2
          A(i) = 1187; % (W/m^2)
          B(i) = 0.142;
          C(i) = 0.104;
      case 3
          A(i) = 1164; % (W/m^2)
          B(i) = 0.149;
          C(i) = 0.109;
      case 4
          A(i) = 1130; % (W/m^2)
          B(i) = 0.164;
          C(i) = 0.120;
      case 5
          A(i) = 1106; % (W/m^2)
          B(i) = 0.177;
          C(i) = 0.130;
      case 6
          A(i) = 1092; % (W/m^2)
          B(i) = 0.185;
          C(i) = 0.137;
      case 7 
          A(i) = 1093; % (W/m^2)
          B(i) = 0.186;
          C(i) = 0.138;
      case 8
          A(i) = 1107; % (W/m^2)
          B(i) = 0.182;
          C(i) = 0.134;
      case 9
          A(i) = 1136; % (W/m^2)
          B(i) = 0.165;
          C(i) = 0.121;
      case 10
          A(i) = 1166; % (W/m^2)
          B(i) = 0.152;
          C(i) = 0.111;
      case 11
          A(i) = 1190; % (W/m^2)
          B(i) = 0.144;
          C(i) = 0.106;
      case 12
          A(i) = 1204; % (W/m^2)
          B(i) = 0.141;
          C(i) = 0.103;
  end        
end

beta_valid = beta;
beta_valid(beta_valid < 0) = 0;
E_direct_normal_clrsky = A./exp(B./sind(beta_valid)); % (W/m^2), direct normal irradiation

% calculation for horizontal surface
E_total_clrsky_horizontal = E_direct_normal_clrsky.*cosd(theta_horizontal);
E_total_clrsky_horizontal(E_total_clrsky_horizontal < 0) = 0;
E_total_clrsky_horizontal = E_total_clrsky_horizontal + C.*E_direct_normal_clrsky;

% calculate for south facing window
E_diffuse_clrsky = C.*Y.*E_direct_normal_clrsky;  % (W/m^2), diffuse irradiation  
E_reflected_clrsky = E_direct_normal_clrsky.*(C + sind(beta_valid))*rho_g.*((1 - cosd(sigma))./2);  % (W/m^2), ground-reflected irradiation  
E_direct_normal_clrsky_component = E_direct_normal_clrsky.*cosd(theta); % (W/m^2), direct irradiation in incident direction  
E_direct_normal_clrsky_component(E_direct_normal_clrsky_component < 0) = 0; % ignore negative values  
E_total_clrsky = E_direct_normal_clrsky_component + E_diffuse_clrsky + E_reflected_clrsky; % (W/m^2), total irradiation on a south-facing window

%% CALCULATE IRRADIANCE FROM DATA

% calculation for horizontal surface
E_total_calc_horizontal = direct_normal_irradiance.*cosd(theta_horizontal);
E_total_calc_horizontal(E_total_calc_horizontal < 0) = 0;
E_total_calc_horizontal = E_total_calc_horizontal + C.*direct_normal_irradiance;

% calculation for a south facing window
E_direct_normal_component  = direct_normal_irradiance.*cosd(theta); % (W/m^2), direct irradiation in incident direction  
E_direct_normal_component(E_direct_normal_component < 0) = 0; % ignore negative values  
E_diffuse = C.*Y.*direct_normal_irradiance;  % (W/m^2), diffuse irradiation  
E_reflected = direct_normal_irradiance.*(C + sind(beta_valid))*rho_g.*((1 - cosd(sigma))./2);  % (W/m^2), ground-reflected irradiation  
E_reflected(beta_valid == 0) = 0;
E_total = E_direct_normal_component + E_diffuse + E_reflected; % (W/m^2), total irradiation on a south-facing window

%% PLOT IRRADIATION COMPARISON
%{
strt = 4800; 
endt = 4900;

figure(1)
hold on
plot(strt:endt,direct_normal_irradiance(strt:endt),'k','LineWidth',1)
plot(strt:endt,E_direct_normal_clrsky(strt:endt),':r','LineWidth',1)
title('ASHRAE Clear Sky Model (red) vs. EPW Data (black) direct normal')
xlabel('Hour')
ylabel('W/m^2')
hold off

figure(2)
hold on
plot(strt:endt,global_horizontal_irradiance(strt:endt),'k','LineWidth',1)
plot(strt:endt,E_total_clrsky_horizontal(strt:endt),':r','LineWidth',1)
title('ASHRAE Clear Sky Model (red) vs. EPW Data (black) on a horizontal surface')
xlabel('Hour')
ylabel('W/m^2')
hold off

figure(3)
hold on
plot(strt:endt,E_total(strt:endt),'k','LineWidth',1)
plot(strt:endt,E_total_clrsky(strt:endt),':r','LineWidth',1)
title('ASHRAE Clear Sky Model (red) vs. EPW Data (black) south window')
xlabel('Hour')
ylabel('W/m^2')
hold off
%}

end



