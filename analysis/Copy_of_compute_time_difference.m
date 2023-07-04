function compute_time_difference(matfile_path, N_ues, BS_IP, UE_IP)
%COMPUTE_TIME_DIFFERENCE

load(matfile_path, ...
    "bs_tables", ...
    "ue_tables", ...
    "N_tot_packets", ...
    "GCC", ...
    "GCR")

%% Init variables and counters
search_window_size = 20;
sync_error_est = -10e-3;

counter_discarded_packets = 0;
counter_unarrived_packets = 0;
time_diff = cell(N_ues, 2);
cmd_id = [];
counter_seq_match = 0;
vars_compared = ["SequenceNumber"];

bs_tables{1,1}.TimeDiff = nan([height(bs_tables{1,1}), 1]);
for ind_ue = 1:N_ues
    ue_tables{ind_ue,1}.TimeDiff = nan([height(ue_tables{ind_ue,1}), 1]);
end

%% Discard packets arrived before the first packet has been sent
% Delete all packets arrived before the time of row; the threshold of
% 10e-3 s is to ensure that even if the two devices are not sycnronized,
% matching packets are not deleted

% for ue_ind = 1:N_ues % loop over the UEs
%     while ue_tables{ue_ind, 2}(1, :).Timestamp < ...
%             (bs_tables{ue_ind, 1}(1, :).Timestamp + sync_error_est)
%         ue_tables{ue_ind, 2}(1, :) = [];
%         counter_discarded_packets = counter_discarded_packets + 1;
%     end
%     while bs_tables{ue_ind, 2}(1, :).Timestamp < ...
%             (ue_tables{ue_ind, 1}(1, :).Timestamp + sync_error_est)
%         bs_tables{ue_ind, 2}(1, :) = [];
%         counter_discarded_packets = counter_discarded_packets + 1;
%     end
% end

%% Compute time difference
for ind_ue = 1:N_ues % loop over the UEs
    % from BS to UE
    while ~isempty(bs_tables{ind_ue, 1}) && ~isempty(ue_tables{ind_ue, 2})
        row = bs_tables{ind_ue, 1}(1, :);
        bs_tables{ind_ue, 1}(1, :) = [];
        for ind_row = 1:min(search_window_size, height(ue_tables{ind_ue, 2}))
            % check conditions for compared variables
            conditions = false(length(vars_compared), 1);
            for i = 1:length(vars_compared)
                conditions(i) = row.(vars_compared(i)) == ue_tables{ind_ue, 2}(ind_row, :).(vars_compared(i));
            end
            if all(conditions)
                counter_seq_match = counter_seq_match + 1;
                time_diff{ind_ue, 1} = [time_diff{ind_ue, 1}; ...
                    ue_tables{ind_ue, 2}(ind_row, :).Timestamp - row.Timestamp];
                cmd_id = [cmd_id; row.SequenceNumber];
                ue_tables{ind_ue, 2}(ind_row, :) = [];
                break
            end
            if ind_row == min(search_window_size, height(ue_tables{ind_ue, 2}))
                counter_unarrived_packets = counter_unarrived_packets + 1;
            end
        end
    end

    % from UE to BS
    while ~isempty(ue_tables{ind_ue, 1}) && ~isempty(bs_tables{ind_ue, 2})
        row = ue_tables{ind_ue, 1}(1, :);
        ue_tables{ind_ue, 1}(1, :) = [];
        for ind_row = 1:min(search_window_size, height(bs_tables{ind_ue, 2}))
            % check conditions for compared variables
            conditions = false(length(vars_compared), 1);
            for i = 1:length(vars_compared)
                conditions(i) = row.(vars_compared(i)) == ...
                    bs_tables{ind_ue, 2}(ind_row, :).(vars_compared(i));
            end
            if all(conditions)
                counter_seq_match = counter_seq_match + 1;
                time_diff{ind_ue, 2} = [time_diff{ind_ue, 2}; ...
                    bs_tables{ind_ue, 2}(ind_row, :).Timestamp - row.Timestamp];
                bs_tables{ind_ue, 2}(ind_row, :) = [];
                break
            end
            if ind_row == min(search_window_size, height(bs_tables{ind_ue, 2}))
                counter_unarrived_packets = counter_unarrived_packets + 1;
            end
        end
    end

end

%% Display
disp( ...
    "Number of packet collected:        "+N_tot_packets+newline+ ...
    "Number of packets matched:         "+ ...
    sum([length(time_diff{1, 1}), length(time_diff{1, 2})])+newline+ ...
    "Number of packets with seq match:  "+counter_seq_match+newline+ ...
    "Number of packets unarrived:       "+counter_unarrived_packets+newline+ ...
    "Number of packets discarded:       "+counter_discarded_packets+newline+ ...
    "Number of total packets analised:  "+ ...
    sum([length(time_diff{1, 1}) * 2, length(time_diff{1, 2}) * 2, ...
    counter_unarrived_packets, counter_discarded_packets, ...
    height(bs_tables{1, 1}), height(bs_tables{1, 2}), ...
    height(ue_tables{1, 1}), height(ue_tables{1, 1})]))

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
