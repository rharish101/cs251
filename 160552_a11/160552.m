% Function to import data from csv
function [x, y] = read_csv (csv_name)
    [x, y] = textread(csv_name, '%f %f', 'delimiter', ',');
    if (isnan(x(1)))
        x = x(2:end);
    endif
    if (isnan(y(1)))
        y = y(2:end);
    endif
    x = [ones(rows(x), 1), x];
endfunction

% Part 1
global X_train y_train
[X_train, y_train] = read_csv('train.csv');

% Part 2
w = rand(2, 1);

% Function to plot data
function plotter (y_pred, plot_title, bool_pause)
    global X_train y_train
    plot(X_train(:, 2), y_train, 'rx', X_train(:, 2), y_pred, 'b-', 'linewidth', 1.5)
    xlabel('Feature')
    ylabel('Label')
    title(plot_title)
    if (nargin < 3 || bool_pause != 0)
        disp('Press any key to continue')
        pause()
    else
        pause(0.01)
    endif
endfunction

% Part 3
plotter(X_train * w, 'Initial Results')

% Part 4
w_direct = pinv(X_train' * X_train) * X_train' * y_train;
plotter(X_train * w_direct, 'Normal Equation Results')

% Part 5
total_epochs = 1;
learn_rate = 1e-8;
for num_epoch = 1:total_epochs
    for index = 1:rows(X_train)
        w = w - learn_rate * (w' * X_train(index,:)' - y_train(index,:)) * X_train(index,:)';
        if (rem(index, 100) == 0)
            printf('\rEpoch: %d, Batch: %d/%d', num_epoch, index, rows(X_train))
            plotter(X_train * w, 'SGD Progress', 0)
        endif
    endfor
endfor
printf('\n')

% Part 6
plotter(X_train * w, 'SGD Results')

% Part 7
[X_test, y_test] = read_csv('test.csv');
y_pred1 = X_test * w;
y_pred2 = X_test * w_direct;
printf('Root Mean Square Error for SGD is %f\n', sqrt(meansq(y_pred1 - y_test)))
printf('Root Mean Square Error for Normal Equation is %f\n', sqrt(meansq(y_pred2 - y_test)))
