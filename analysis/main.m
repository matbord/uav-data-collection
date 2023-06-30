close all, clear all, clc

%% 
flag_read_data = true;

%% IMPORT DATA
if flag_read_data
    read_csv_divide_conversations()
end

%% RUN ANALYSIS
compute_time_difference

