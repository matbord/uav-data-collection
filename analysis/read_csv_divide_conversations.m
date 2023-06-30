close all, clear all, clc

matfile_path = "matlab_data.mat";
number_ues = 1;
BS_IP = "10.241.115.1";
UE_IP = "172.16.0.8";

%% Read tables
% Set readtable options
opts = delimitedTextImportOptions("NumVariables", 8);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["Timestamp", "SequenceNumber", "MavlinkCommand", "IPSourceHost", "TCPSourcePort", "IPDestHost", "TCPDestPort", "PacketLength"];
opts.VariableTypes = ["double", "double", "string", "string", "double", "string", "double", "double"];
opts.ImportErrorRule = "omitrow";
opts.MissingRule = "omitrow";
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Read table for BS from csv files and get the number of packets
BS_csv = readtable("data/BS_data.csv", opts);
Len_BS_csv = height(BS_csv);

% Read table for UEs from csv files and get the number of packets
UE_csv = cell(number_ues);
Len_UE_csv = zeros(number_ues, 1);
for ue_ind = 1:number_ues
    % TODO: change here reading pattern of files
    UE_csv{ue_ind} = readtable("data/UE_data.csv", opts);
    Len_UE_csv(ue_ind) = height(UE_csv{ue_ind});
end

%% Collect packet stats
n_tot_packets = length([BS_csv.SequenceNumber; UE_csv{1, 1}.SequenceNumber]);
% all_packets_SequenceNumber = [BS_csv.SequenceNumber; UE_csv{1, 1}.SequenceNumber];
% [GC, GR] = groupcounts(all_packets_SequenceNumber);
% [GCC, GCR] = groupcounts(GC);
% disp("Number of matched (2) and unmatched (1) packets:")
% tabulate(all_packets_SequenceNumber)

%% Init variables and counters
% The first column of the cell array is for sent packets, the second column
% is for received packets. The BS array has a line for each UE, the UE
% arrray has a line for each UE.
BS_tables = cell(number_ues, 2);
UE_tables = cell(number_ues, 2);

%% Divide flows and conversations into different tables

% Read UE_csv files
for ue_ind = 1:number_ues % loop over the UEs
    for row_ind = 1:Len_UE_csv(ue_ind) % loop over the lines of the table
        row = UE_csv{ue_ind}(row_ind, :);
        if strcmp(row.IPSourceHost{1}, UE_IP(ue_ind)) % if packet sent
            UE_tables{ue_ind, 1} = [UE_tables{ue_ind, 1}; row];
        elseif strcmp(row.IPSourceHost{1}, BS_IP) % if packet received
            UE_tables{ue_ind, 2} = [UE_tables{ue_ind, 2}; row];
        end
    end
    %     % Sort tables
    %     UE_tables{ue_ind,1} = sortrows(UE_tables{ue_ind,1}, "SequenceNumber", "ascend");
    %     UE_tables{ue_ind,2} = sortrows(UE_tables{ue_ind,2}, "SequenceNumber", "ascend");
end

% Read BS_csv files
for row_ind = 1:Len_BS_csv % loop over the lines of the table
    row = BS_csv(row_ind, :);
    for ue_ind = 1:number_ues % loop over the UEs
        if strcmp(row.IPSourceHost{1}, BS_IP) % if packet sent
            BS_tables{ue_ind, 1} = [BS_tables{ue_ind, 1}; row];
            break % don't need to check other UEs if found match
        elseif strcmp(row.IPSourceHost{1}, UE_IP(ue_ind)) % if packet received
            BS_tables{ue_ind, 2} = [BS_tables{ue_ind, 2}; row];
            break % don't need to check other UEs if found match
        end
    end
    %     % Sort tables
    %     BS_tables{ue_ind,1} = sortrows(BS_tables{ue_ind,1}, "SequenceNumber", "ascend");
    %     BS_tables{ue_ind,2} = sortrows(BS_tables{ue_ind,2}, "SequenceNumber", "ascend");
end

save(matfile_path)
