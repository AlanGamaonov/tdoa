clear

fc = 3e9; % Несущая частота
band = 25e6; % Полоса сигнала
path_recs = 'records_6_ok\'; % папка с записями
Records = 10; % Количество записей
path_json = [path_recs(1:end-1) '_json\'];
if ~mkdir(path_json)
    error('Path for json does not exist');
end
% Координаты источника
lat0 = 60.0463007;
lon0 = 30.2079432; 

dfA = 0;
dfB = 0;
dfC = 0;
ff = 1;
for f = 1:Records
    str0 = sprintf('%03d', f-1);
    disp(str0);
    
    strA = sprintf('%03d', f-1+dfA);
    strB = sprintf('%03d', f-1+dfB);
    strC = sprintf('%03d', f-1+dfC);
    
    Name1 = [path_recs 'QPSK_25Msps_ChannelA_' strA '.txt'];
    Name2 = [path_recs 'QPSK_25Msps_ChannelB_' strB '.txt'];
    Name3 = [path_recs 'QPSK_25Msps_ChannelC_' strC '.txt'];
    
    [GPS1, X1] = func_read_file(Name1);
    [GPS2, X2] = func_read_file(Name2);
    [GPS3, X3] = func_read_file(Name3);
    
    [time1(ff,:),lat1(ff),lon1(ff),alt1(ff)] = func_get_lat_lon_alt(GPS1);
    [time2(ff,:),lat2(ff),lon2(ff),alt2(ff)] = func_get_lat_lon_alt(GPS2);
    [time3(ff,:),lat3(ff),lon3(ff),alt3(ff)] = func_get_lat_lon_alt(GPS3);
    
    if ( ~strcmp(time1(ff,:), time2(ff,:)) )
        disp('Time A is not equal to time B');
        if ( datenum(time1(ff,:), 'yyyy-mm-ddTHH:MM:SS') > datenum(time2(ff,:), 'yyyy-mm-ddTHH:MM:SS') )
            dfA = dfA - 1;
        else
            dfB = dfB - 1;
        end
        continue;
    elseif ( ~strcmp(time1(ff,:), time3(ff,:)) )
        disp('Time A is not equal to time C');
        if ( datenum(time1(ff,:), 'yyyy-mm-ddTHH:MM:SS') > datenum(time3(ff,:), 'yyyy-mm-ddTHH:MM:SS') )
            dfA = dfA - 1;
            dfB = dfB - 1;
        else
            dfC = dfC - 1;
        end
        continue;
    end
    
    [tau12(ff), val12(ff)] = func_calc_delay(X2, X1, fc);
    [tau13(ff), val13(ff)] = func_calc_delay(X3, X1, fc);
    [tau23(ff), val23(ff)] = func_calc_delay(X3, X2, fc);
    
    NameJson = [path_json 'GPS_' str0 '.json'];
    status_json = func_save_json(NameJson, time1(ff,:), ...
        lat1(ff),lon1(ff),alt1(ff), lat2(ff),lon2(ff),alt2(ff), lat3(ff),lon3(ff),alt3(ff), ...
        tau12(ff),tau13(ff),tau23(ff), fc, band);
    ff = ff + 1;
end
                                                                             
NameJson = [path_json 'GPS_mean.json'];
status_json = func_save_json(NameJson, time1(ff-1,:), ...
        mean(lat1),mean(lon1),mean(alt1), mean(lat2),mean(lon2),mean(alt2), mean(lat3),mean(lon3),mean(alt3), ...
        mean(tau12),mean(tau13),mean(tau23), fc, band);

func_hyp_on_maps(lat1, lon1, lat2, lon2, lat3, lon3, tau12, tau13, tau23);

