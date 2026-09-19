%init
close all;
clear all;
clc;

%config
FILE_NAME = "SN_m_tot_V2.0.txt";
DELTA_T = 1;
LINE_WIDTH = 0.1;
FIGURE_WIDTH = 3000;
FIGURE_HEIGHT = 2000;

points = [1, 5, 9, 13];%try [1, 67, 71, 75, 79];

%function
function [frequency, amplitude] = DFT(data, delta_t)
    f = data;
    N = size(data(:));
    N = N(1);
    frequency = zeros(N, 1);
    amplitude = zeros(N, 1);
    idx = 1;

    for n = 0 : 1 : (N / 2 - 1)
        frequency(idx) = n / (N * delta_t);
        
        F = 0;
        for k = 0 : (N - 1)
            F = F + (f(k + 1) * exp(((-1i) * 2 * pi * n * k)/N)); 
        end

        amplitude(idx) = F;

        idx = idx + 1;
    end
end

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

%read data
data = readtable(FILE_NAME);
sizeofData = size(data);
sizeofData = sizeofData(1);

%handle data
sunspotNum = data.Var4;
period = datetime(data.Var1, data.Var2, 1);
T = [];

%compare fft and dft
figure;
t = tiledlayout(3, 1);
t.TileSpacing = "compact";
t.Padding = "loose";

%%og data
nexttile;

x = period(:);
y = sunspotNum(:);

plot(x(:), y(:), LineWidth = LINE_WIDTH);
xlabel("Time(Month)");
ylabel("Sunspots");
title("Original Data");
grid on;

%%dft
nexttile;

[x, y] = DFT((sunspotNum - mean(sunspotNum)), DELTA_T);
y = abs(y);

[val, idx] = max(y(:));
disp("T =");
disp(abs((1 / x(idx)) / 12));

plot(x(:), y(:), LineWidth = LINE_WIDTH);
xlim([0, abs(10 * x(idx))]);
xlabel("Freqency(1/Month)");
ylabel("Amplitude");
title("FFT of OG Data Using DFT()");
grid on;

%%fft
nexttile;

N = sizeofData;
x = [];
y = [];

for n = (-N/2) : 1 : (N / 2 - 1)
    x(end + 1) = n / (N * DELTA_T);
end

y = abs(fftshift(fft(sunspotNum - mean(sunspotNum))));

[val, idx] = max(y(:));
disp("T =");
disp(abs((1 / x(idx)) / 12));

plot(x(:), y(:), LineWidth = LINE_WIDTH);
xlim([0, abs(10 * x(idx))]);
xlabel("Freqency(1/Month)");
ylabel("Amplitude");
title("FFT of OG Data Using fftshift(fft())");
grid on;

%%save
saveas(gcf, "Figure1.png");
close;

%compare different ma
figure;
t = tiledlayout(length(points), 1);
t.TileSpacing = "compact";
t.Padding = "loose";

for point = points
    nexttile;

    ma = movingAverage(sunspotNum, point);

    [x, y] = DFT((ma - mean(ma)), point);
    y = abs(y);

    [val, idx] = max(y(:));
    disp("T =");
    T(end + 1) = abs((1 / (point * x(idx))) / 12);
    disp(T(end));
    
    plot(x(:), y(:), LineWidth = LINE_WIDTH);
    xlim([0, max([abs(-10 * x(idx)), 1e-3])]);
    xlabel("Freqency(1/" + point + " Month)");
    ylabel("Amplitude");
    title("FFT of " + point + "-Points Moving Average of Sunspots (T = " + T(end)+" years)");
    grid on;
end

%%save
saveas(gcf, "Figure2.png");
close;



%show T for different points
figure;

hold on;
x = points(:);
y = T;

plot(x(:), y(:), "-o", LineWidth = 3);

%p = polyfit(x, y, 1);
%yfit = polyval(p, x);
%plot(x, yfit);

hold off;

xlabel("Points");
ylabel("Period");
title("Periods of Different Points of MA");
legend(["Periods", "Regression"])
grid on;

saveas(gcf, "Figure3.png");
close;