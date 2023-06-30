close all, clear all, clc

matfile_path = "matlab_data.mat";
number_ues = 1;
BS_IP = "10.241.115.1";
UE_IP = "172.16.0.8";

%%
load("matlab_data.mat")

%% Init variables and counters
search_window_size = 20;
sync_error_est = -10e-3;
counter_discarded_packets = 0;
counter_unarrived_packets = 0;
time_diff = cell(number_ues, 2);
cmd_id = [];
counter_seq_match = 0;
vars_compared = ["SequenceNumber"]; % ["Timestamp", "SequenceNumber", "MavlinkCommand", "IPSourceHost", "TCPSourcePort", "IPDestHost", "TCPDestPort", "PacketLength"];

%% Discard packets arrived before the first packet has been sent
% Delete all packets arrived before the time of row; the threshold of
% 10e-3 s is to ensure that even if the two devices are not sycnronized,
% matching packets are not deleted
for ue_ind = 1:number_ues % loop over the UEs
    while UE_tables{ue_ind, 2}(1, :).Timestamp < ...
            (BS_tables{ue_ind, 1}(1, :).Timestamp + sync_error_est)
        UE_tables{ue_ind, 2}(1, :) = [];
        counter_discarded_packets = counter_discarded_packets + 1;
    end
    while BS_tables{ue_ind, 2}(1, :).Timestamp < ...
            (UE_tables{ue_ind, 1}(1, :).Timestamp + sync_error_est)
        BS_tables{ue_ind, 2}(1, :) = [];
        counter_discarded_packets = counter_discarded_packets + 1;
    end
end

%% Compute time difference
for ue_ind = 1:number_ues % loop over the UEs
    % from BS to UE
    while ~isempty(BS_tables{ue_ind, 1}) && ~isempty(UE_tables{ue_ind, 2})
        row = BS_tables{ue_ind, 1}(1, :);
        BS_tables{ue_ind, 1}(1, :) = [];
        for row_ind = 1:min(search_window_size, height(UE_tables{ue_ind, 2}))
            % check conditions for compared variables
            conditions = false(length(vars_compared), 1);
            for i = 1:length(vars_compared)
                conditions(i) = row.(vars_compared(i)) == UE_tables{ue_ind, 2}(row_ind, :).(vars_compared(i));
            end
            if all(conditions)
                counter_seq_match = counter_seq_match + 1;
                time_diff{ue_ind, 1} = [time_diff{ue_ind, 1}; ...
                    UE_tables{ue_ind, 2}(row_ind, :).Timestamp - row.Timestamp];
                cmd_id = [cmd_id; row.SequenceNumber];
                UE_tables{ue_ind, 2}(row_ind, :) = [];
                break
            end
            if row_ind == min(search_window_size, height(UE_tables{ue_ind, 2}))
                counter_unarrived_packets = counter_unarrived_packets + 1;
            end
        end
    end

    % from UE to BS
    while ~isempty(UE_tables{ue_ind, 1}) && ~isempty(BS_tables{ue_ind, 2})
        row = UE_tables{ue_ind, 1}(1, :);
        UE_tables{ue_ind, 1}(1, :) = [];
        for row_ind = 1:min(search_window_size, height(BS_tables{ue_ind, 2}))
            % check conditions for compared variables
            conditions = false(length(vars_compared), 1);
            for i = 1:length(vars_compared)
                conditions(i) = row.(vars_compared(i)) == ...
                    BS_tables{ue_ind, 2}(row_ind, :).(vars_compared(i));
            end
            if all(conditions)
                counter_seq_match = counter_seq_match + 1;
                time_diff{ue_ind, 2} = [time_diff{ue_ind, 2}; ...
                    BS_tables{ue_ind, 2}(row_ind, :).Timestamp - row.Timestamp];
                BS_tables{ue_ind, 2}(row_ind, :) = [];
                break
            end
            if row_ind == min(search_window_size, height(BS_tables{ue_ind, 2}))
                counter_unarrived_packets = counter_unarrived_packets + 1;
            end
        end
    end

end

%% Display
disp( ...
    "Number of packet collected:        "+n_tot_packets+newline+ ...
    "Number of packets matched:         "+ ...
    sum([length(time_diff{1, 1}), length(time_diff{1, 2})])+newline+ ...
    "Number of packets with seq match:  "+counter_seq_match+newline+ ...
    "Number of packets unarrived:       "+counter_unarrived_packets+newline+ ...
    "Number of packets discarded:       "+counter_discarded_packets+newline+ ...
    "Number of total packets analised:  "+ ...
    sum([length(time_diff{1, 1}) * 2, length(time_diff{1, 2}) * 2, ...
    counter_unarrived_packets, counter_discarded_packets, ...
    height(BS_tables{1, 1}), height(BS_tables{1, 2}), ...
    height(UE_tables{1, 1}), height(UE_tables{1, 1})]))

%% Plot

figure(1)
subplot(311)
plot(time_diff{1, 1})
subplot(312)
boxplot(time_diff{1, 1})
subplot(313)
ecdf(time_diff{1, 1})

figure(2)
subplot(311)
plot(time_diff{1, 2})
subplot(312)
boxplot(time_diff{1, 2})
subplot(313)
ecdf(time_diff{1, 2})
