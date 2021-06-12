function [time,lat,lon,alt] = func_get_lat_lon_alt(GPS)

GNRMC = textscan(GPS{1}{1},'%s','Delimiter',',');
GNGGA = textscan(GPS{1}{3},'%s','Delimiter',',');

d = GNRMC{1}{10};
t = GNRMC{1}{2};
time = ['20' d(5:6) '-' d(3:4) '-' d(1:2) 'T' t(1:2) ':' t(3:4) ':' t(5:end)];

lat0 = str2double(GNRMC{1}{4}) / 100;
lat = floor(lat0) + (lat0 - floor(lat0)) * 100 / 60;
if strcmp(GNRMC{1}{5}, 'S')
    lat = -lat;
end

lon0 = str2double(GNRMC{1}{6}) / 100;
lon = floor(lon0) + (lon0 - floor(lon0)) * 100 / 60;
if strcmp(GNRMC{1}{7}, 'W')
    lon = -lon;
end

alt = str2double(GNGGA{1}{10});

end

