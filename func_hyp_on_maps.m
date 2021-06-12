function func_hyp_on_maps(latA, lonA, latB, lonB, latC, lonC, dtAB, dtAC, dtBC)
    
    mLatA = mean(latA); mLonA = mean(lonA);
    mLatB = mean(latB); mLonB = mean(lonB);
    mLatC = mean(latC); mLonC = mean(lonC);

    % Координаты источника
    transmitter_lat = 60.0463007;
    transmitter_lon = 30.2079432;

    recievers_lat = [mLatA mLatB mLatC];
    recievers_lon = [mLonA mLonB mLonC];

    % Выбираем начало координат в середине треугольника ABC
    lat0 = mean(recievers_lat);
    lon0 = mean(recievers_lon);
    
    % Пересчитываем координаты приёмников относительно центра
    [yA, xA] = GPS_to_relative(lat0, lon0, mLatA, mLonA);
    [yB, xB] = GPS_to_relative(lat0, lon0, mLatB, mLonB);
    [yC, xC] = GPS_to_relative(lat0, lon0, mLatC, mLonC);
    
    syms x y
    min_x = -3000; max_x = +3000;
    
    % Пересчёт задержки в расстояние
    c = 299792458; %Скорость света
    dl_oa_minus_ob = dtAB * 1e-9 * c;
    dl_oa_minus_oc = dtAC * 1e-9 * c;
    dl_ob_minus_oc = dtBC * 1e-9 * c;
    
    % Координаты (долгота и широта) из этих массивов
    % будут выводиться на экран
    markers_lat = [];
    markers_lon = [];
    
    % Создаём окно именно сейчас, чтобы предотвратить вывод графиков ezplot
    % (вероятно эту проблему можно решить по-другому, но я не знаю как)
    figure('Position', [300, 300, 1000, 600])
    
    for i = 1:length(dtAB)
        % Гиперболы
        hypAB = (sqrt((x-xA)^2 + (y-yA)^2) - sqrt((x-xB)^2 + (y-yB)^2) == dl_oa_minus_ob(i));
        hypAC = (sqrt((x-xA)^2 + (y-yA)^2) - sqrt((x-xC)^2 + (y-yC)^2) == dl_oa_minus_oc(i));
        hypBC = (sqrt((x-xB)^2 + (y-yB)^2) - sqrt((x-xC)^2 + (y-yC)^2) == dl_ob_minus_oc(i));
        
        % Получаем матрицы гипербол (первая строка - х, вторая - у)
        hypAB_cm = get(ezplot(hypAB,[min_x,max_x]),'contourMatrix');
        hypAC_cm = get(ezplot(hypAC,[min_x,max_x]),'contourMatrix');
        hypBC_cm = get(ezplot(hypBC,[min_x,max_x]),'contourMatrix');
        
        % Не знаю с чем это связано, но первый столбец имеет вид
        % х = 0, у = <число>, что выдаёт левые результаты
        % при поиске точки пересечения, поэтому удаляем его
        hypAB_cm(:, 1) = [];
        hypAC_cm(:, 1) = [];
        hypBC_cm(:, 1) = [];
        
        % Находим точки пересечения гипербол
        P1 = InterX([hypAB_cm(1,:); hypAB_cm(2,:)], [hypAC_cm(1,:); hypAC_cm(2,:)]);
        p1_x = P1(1); p1_y = P1(2);

        P2 = InterX([hypAB_cm(1,:); hypAB_cm(2,:)], [hypBC_cm(1,:); hypBC_cm(2,:)]);
        p2_x = P2(1); p2_y = P2(2);

        P3 = InterX([hypAC_cm(1,:); hypAC_cm(2,:)], [hypBC_cm(1,:); hypBC_cm(2,:)]);
        p3_x = P3(1); p3_y = P3(2);
        
        % Переводим точки пересечения в широту и долготу
        [p1_lat, p1_lon] = relative_to_GPS(lat0, lon0, p1_y, p1_x);
        [p2_lat, p2_lon] = relative_to_GPS(lat0, lon0, p2_y, p2_x);
        [p3_lat, p3_lon] = relative_to_GPS(lat0, lon0, p3_y, p3_x);
        
        % Находим центр получившегося треугольника
        intersection_lat = mean([p1_lat p2_lat p3_lat]);
        intersection_lon = mean([p1_lon p2_lon p3_lon]);
        
        % Добавляем найденную точку в массивы для вывода
        markers_lat(end+1) = intersection_lat;
        markers_lon(end+1) = intersection_lon;
    end
    
    % Вывод карты с метками
    geoscatter(recievers_lat, recievers_lon, 50, 'white', 'filled');
    hold on;
    geoscatter(markers_lat, markers_lon, 20, 'yellow', 'filled');
    geoscatter([transmitter_lat], [transmitter_lon], 30, 'blue', 'filled');
    geobasemap satellite;
end

function [y, x] = GPS_to_relative(lat_0, lon_0, lat, lon)
    meters_per_degree_lat = 111135;
    meters_per_degree_lon = meters_per_degree_lat * cos(lat_0/360 * 2 * pi);
    
    y = (lat - lat_0) * meters_per_degree_lat * (-1);
    x = (lon - lon_0) * meters_per_degree_lon;
end

function [lat, lon] = relative_to_GPS(lat_0, lon_0, y, x)
    meters_per_degree_lat = 111135;
    meters_per_degree_lon = meters_per_degree_lat * cos(lat_0/360 * 2 * pi);
    
    lat = -y/meters_per_degree_lat + lat_0;
    lon = x/meters_per_degree_lon + lon_0;
end










