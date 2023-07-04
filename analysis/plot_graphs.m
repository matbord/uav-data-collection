function [] = plot_graphs(matfile_path, N_ues)
%PLOT_GRAPHS Summary of this function goes here
%   Detailed explanation goes here

load(matfile_path, ...
    "bs_tables", ...
    "ue_tables", ...
    "N_tot_packets", ...
    "GCC", ...
    "GCR", ...
    "counter_unarrived_packets", ...
    "counter_discarded_packets")

bs2ue_edges = [0, 10e-3, 1, 10];
ue2bs_edges = [0, 150e-3, 1, 10];

for ind_ue = 1:N_ues
    % TimeDIff from BS to UE
    figure(ind_ue)
    subplot(211)
    hold on, grid on
    ecdf(bs_tables{ind_ue, 1}.TimeDiff)
    title("TimeDiff BS to UE")

    subplot(212)
    hold on, grid on
    histogram(bs_tables{ind_ue, 1}.TimeDiff)
    xlabel('Time difference [s]')


    % TimeDIff from UE to BS
    figure(N_ues+ind_ue)
    subplot(211)
    hold on, grid on
    ecdf(ue_tables{ind_ue, 1}.TimeDiff)
    title("TimeDiff UE to BS")

    subplot(212)
    hold on, grid on
    histogram(ue_tables{ind_ue, 1}.TimeDiff)
    xlabel('Time difference [s]')


    % PacketLength from BS to UE
    figure(2*N_ues+ind_ue)
    subplot(211)
    hold on, grid on
    ecdf(bs_tables{ind_ue, 1}.PacketLength)
    title("PacketLength BS to UE")

    subplot(212)
    hold on, grid on
    histogram(bs_tables{ind_ue, 1}.TimeDiff)
    xlabel('Packet size [bytes(?)]')


    % PacketLength from UE to BS
    figure(3*N_ues+ind_ue)
    subplot(211)
    hold on, grid on
    ecdf(ue_tables{ind_ue, 1}.PacketLength)
    title("PacketLength UE to BS")

    subplot(212)
    hold on, grid on
    histogram(ue_tables{ind_ue, 1}.TimeDiff)
    xlabel('Packet size [bytes(?)]')
end


end
