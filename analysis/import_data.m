function import_data(matfile_path, N_ues, BS_IP, UE_IP)
%IMPORT_DATA

%% Read tables
% Set options
opts = delimitedTextImportOptions("NumVariables", 8);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["Timestamp", "SequenceNumber", "MavlinkCommand", "IPSourceHost", "TCPSourcePort", "IPDestHost", "TCPDestPort", "PacketLength"];
opts.VariableTypes = ["double", "double", "string", "string", "double", "string", "double", "double"];
opts.ImportErrorRule = "omitrow";
opts.MissingRule = "omitrow";
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% BS
BS_csv = readtable("data/BS_data.csv", opts);
Len_BS_csv = height(BS_csv);

% UEs
UE_csv = cell(N_ues);
Len_UE_csv = zeros(N_ues, 1);
for ue_ind = 1:N_ues
    UE_csv{ue_ind, 1} = readtable("data/UE_data.csv", opts);
    Len_UE_csv(ue_ind) = height(UE_csv{ue_ind});
end

%% Collect packet stats
all_packets_SequenceNumber = [BS_csv.SequenceNumber];
for ind_ue = 1:N_ues
    all_packets_SequenceNumber = [all_packets_SequenceNumber; UE_csv{ind_ue, 1}.SequenceNumber];
end
N_tot_packets = length(all_packets_SequenceNumber);
[GC, GR] = groupcounts(all_packets_SequenceNumber);
[GCC, GCR] = groupcounts(GC);
disp("Number of matched (2), unmatched (1), and retransmitted (3) packets:")
tabulate(GC)

%% Init variables and counters
% The first column of the cell array is for sent packets, the second column
% is for received packets. The BS array has a line for each UE, the UE
% arrray has a line for each UE.
bs_tables = cell(N_ues, 2);
ue_tables = cell(N_ues, 2);

%% Divide flows and conversations into different tables

% Read UE_csv files
for ue_ind = 1:N_ues % loop over the UEs
    for row_ind = 1:Len_UE_csv(ue_ind) % loop over the lines of the table
        row = UE_csv{ue_ind}(row_ind, :);
        if strcmp(row.IPSourceHost{1}, UE_IP(ue_ind)) % if packet sent
            ue_tables{ue_ind, 1} = [ue_tables{ue_ind, 1}; row];
        elseif strcmp(row.IPSourceHost{1}, BS_IP) % if packet received
            ue_tables{ue_ind, 2} = [ue_tables{ue_ind, 2}; row];
        end
    end
    %     % Sort tables
    %     ue_tables{ue_ind,1} = sortrows(ue_tables{ue_ind,1}, "SequenceNumber", "ascend");
    %     ue_tables{ue_ind,2} = sortrows(ue_tables{ue_ind,2}, "SequenceNumber", "ascend");
end

% Read BS_csv files
for row_ind = 1:Len_BS_csv % loop over the lines of the table
    row = BS_csv(row_ind, :);
    for ue_ind = 1:N_ues % loop over the UEs
        if strcmp(row.IPSourceHost{1}, BS_IP) % if packet sent
            bs_tables{ue_ind, 1} = [bs_tables{ue_ind, 1}; row];
            break % don't need to check other UEs if found match
        elseif strcmp(row.IPSourceHost{1}, UE_IP(ue_ind)) % if packet received
            bs_tables{ue_ind, 2} = [bs_tables{ue_ind, 2}; row];
            break % don't need to check other UEs if found match
        end
    end
    %     % Sort tables
    %     bs_tables{ue_ind,1} = sortrows(bs_tables{ue_ind,1}, "SequenceNumber", "ascend");
    %     bs_tables{ue_ind,2} = sortrows(bs_tables{ue_ind,2}, "SequenceNumber", "ascend");
end

save(matfile_path, ...
    "bs_tables", ...
    "ue_tables", ...
    "N_tot_packets", ...
    "GCC", ...
    "GCR")

end
