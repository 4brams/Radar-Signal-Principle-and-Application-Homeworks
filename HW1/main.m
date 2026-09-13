%init
clear;
clc;
close all;

%config
FIGURE_WIDTH = 3000;
FIGURE_HEIGHT = 2000;
LINE_WIDTH = 0.1;
X_LABEL = "Time(year)";
Y_LABEL = "Sunspot Numbers";

points = [1, 3, 7, 11];

%func
function ma = movingAverage(data, point)
    sizeofData = size(data);
    sizeofData = sizeofData(1);
    margin = floor(point / 2);

    ma = [];

    for i = 1 : sizeofData
        if((i <= margin) || (i > (sizeofData - margin)))
            continue;
        end

        sum = 0;
        for j = (i - margin) : (i + margin)
            sum = sum + data(j);
        end

        ma(end + 1) = sum / point;
    end
end

%read
data = readtable("SN_d_tot_V2.0.txt");
sizeofData = size(data);
sizeofData = sizeofData(1);

%handle data
sunSpotNum = int16(data.Var5);
period = datetime(data.Var1, data.Var2, data.Var3);

for i = 1 : sizeofData
    if(sunSpotNum(i) < 0)
        sunSpotNum(i) = 0;
    end
end

%plot config
figure("Position", [0, 0, FIGURE_WIDTH, FIGURE_HEIGHT]);
t = tiledlayout(2, 2);
t.TileSpacing = "compact";
t.Padding = "loose";

%plot 1
x = period(:);
y = sunSpotNum(:);

nexttile;
plot(x(:), y(:),"LineWidth", LINE_WIDTH);
title("Original Signal");
xlabel(X_LABEL);
ylabel(Y_LABEL);
grid("on");

%plot 2~4
for i = 2 : 4
    x = period((floor(points(i) / 2) + 1) : (sizeofData - floor(points(i) / 2)));
    y = movingAverage(sunSpotNum(:), points(i));

    nexttile;
    plot(x(:), y(:), "LineWidth", LINE_WIDTH);
    title(points(i) + "-Point Moving Average")
    xlabel(X_LABEL);
    ylabel(Y_LABEL);
    grid("on");
end

%save plot
exportgraphics(gcf, "figure.png", "Resolution", 300, "Padding", 80);