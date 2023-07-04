close all, clear all, clc

flag_import_data = false;
flag_compute_time_diff = false;
matfile_path = "matlab_data.mat";
N_ues = 1;
BS_IP = "10.241.115.1";
UE_IP = "172.16.0.8";

if flag_import_data
    import_data(matfile_path, N_ues, BS_IP, UE_IP)
end

if flag_compute_time_diff
    tic
    compute_time_difference(matfile_path, N_ues, BS_IP, UE_IP)
    toc
end

plot_graphs(matfile_path, N_ues)
