function [direct, diffuse, total] = peakIrradiance(site_latitude, azimuth, face)
%% PEAK IRRADIANCE EQUATIONS
% ASHRAE HOF 29, TABLE 10
phi = abs((azimuth-180)/180); % normalized exposure
% NOTE THAT THIS NORMALIZATION IS EDITING, BECAUSE THE EQUATION PRODUCES
% THE TABLE IN REVERSE, IT IS AN ERROR in ASHRAE HOF?
L = site_latitude; 

if strcmp(face, 'horizontal')
    total = 970 + 6.2*L - 0.16*(L^2); % (W/m^2), peak total irradiance 
    diffuse = min(total, 124); % (W/m^2), peak diffuse irradiance 
    direct = total - diffuse; % (W/m^2), peak direct irradiance 
elseif strcmp(face, 'vertical')
    total = 462.2 + 1625*phi - 6183*phi^3 + 3869*phi^4 + 32.38*phi*L + 0.3237*phi*(L^2) - (12.56*L) - 0.8959*(L^2) + (1.040*(L^2))/(phi + 1); % (W/m^2), peak total irradiance 
    diffuse = min(total, 392.1 - 138.6*phi + 2.107*phi*L - (121*(L^(1/4)))/(phi + 1)); % (W/m^2), peak diffuse irradiance
    direct = total - diffuse ; % (W/m^2), peak direct irradiance 
else
    diffuse = 0;
    direct = 0; 
    disp('error, please select face as vertical or horizontal')
end    

end    

%% COMPARISON ASHRAE HOF CHP.29 TABLE 9
% copy and paste into separate script to avoid recursion error
%{
Table = zeros(18,9);
n = 1;
for L = linspace(20,60,9)
    m = 1;
    i = 1;
    for azimuth = linspace(180,0,5)
    	[direct, diffuse, total] = peakIrradiance(L,azimuth,'vertical');
        Table(i,n) = round(direct);
        Table(i+1,n) = round(diffuse);
        Table(i+2,n) = round(total);
        i = i+3;
    end
    [direct, diffuse, total] = peakIrradiance(L,0,'horizontal');
    Table(i,n) = round(direct);
    Table(i+1,n) = round(diffuse);
    Table(i+2,n) = round(total);    
    n = n + 1;
end    
%}