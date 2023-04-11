close all, clear all, clc

if ~isfile("data.mat")
    run("read_csv_divide_convs.m")
end

% TODO: clean data to ba saved
save("data.mat")
clear all

run("compute_time_difference.m")

