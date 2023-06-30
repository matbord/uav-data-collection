close all, clear all, clc
format long

load("data.mat")

% debug
% figure(1)
% semilogy(UE_tables{1,1}.Timestamp,UE_tables{1,1}.SequenceNumber,'b', ...
%     BS_tables{1,2}.Timestamp,BS_tables{1,2}.SequenceNumber,'r')

seq_n = [BS_tables{1,1}(:,2); UE_tables{1,2}(:,2)];
[GC, GR] = groupcounts(seq_n.SequenceNumber);
[GCC1, GCR] = groupcounts(GC);

seq_n = [UE_tables{1,1}(:,2); BS_tables{1,2}(:,2)];
[GC, GR] = groupcounts(seq_n.SequenceNumber);
[GCC2, GCR] = groupcounts(GC);

% end debug

%% Init variables and counters
search_window_size = 500;
sync_error_est = -10e-3;
counter_discarded_packets = 0;
counter_unarrived_packets = 0;
time_diff = cell(number_ues,2);
cmd_id = [];
counter_seq_match = 0;
% vars_compared = ["SequenceNumber", "MavlinkCommand", ...
%     "IPSourceHost", "TCPSourceHost", "IPDestHost", "TCPDestPort", ...
%     "PacketLength"];vars_compared = ["SequenceNumber", "PacketLength"];

% vars_compared = ["SequenceNumber", "MavlinkCommand", "PacketLength"];
vars_compared = ["SequenceNumber"];
% vars_comp = zeros(length(vars_compared), 1);
% for ind = 1:length(vars_compared)
%     vars_comp(ind) = find(vars_compared(ind) == ...
%         BS_tables{1,1}.Properties.VariableNames);
% end

%% Compute time difference

for ue_ind = 1:number_ues % loop over the UEs

    tic
    % from BS to UE
    while ~isempty(BS_tables{ue_ind,1}) && ~isempty(UE_tables{ue_ind,2})
        row = BS_tables{ue_ind,1}(1,:);
        BS_tables{ue_ind,1}(1,:) = [];
        % delete all packets arrived before the time of row; the threshold of 
        % 10e-3 s is to ensure that even if the two devices are not sycnronized, 
        % matching packets are not deleted
        while height(UE_tables{ue_ind,2}) > 0 && ...
                UE_tables{ue_ind,2}(1,:).Timestamp < (row.Timestamp + sync_error_est)

            % debug
%             row(:,[1,2,3,8]), UE_tables{ue_ind,2}(1,[1,2,3,8])
            % end debug
            
            UE_tables{ue_ind,2}(1,:) = [];
            counter_discarded_packets = counter_discarded_packets + 1;
        end
        for row_ind = 1:min(search_window_size,height(UE_tables{ue_ind,2}))
            
            % debug
%             row(:,[1,2,3,8]), UE_tables{ue_ind,2}(row_ind,[1,2,3,8])
            % end debug
            
            % check conditions for compared variables
            conditions = false(length(vars_compared),1);
            for i = 1:length(vars_compared)
                conditions(i) = row.(vars_compared(i)) == UE_tables{ue_ind,2}(row_ind,:).(vars_compared(i));
            end
            if all(conditions)
                counter_seq_match = counter_seq_match + 1;
                time_diff{ue_ind,1} = [time_diff{ue_ind,1};
                    UE_tables{ue_ind,2}(row_ind,:).Timestamp - row.Timestamp];
                cmd_id = [cmd_id; row.SequenceNumber];
                UE_tables{ue_ind,2}(row_ind,:) = [];
                break
            end
            if row_ind == min(search_window_size,height(UE_tables{ue_ind,2}))
                counter_unarrived_packets = counter_unarrived_packets + 1;
            end
        end
    end

    % from UE to BS
    while ~isempty(UE_tables{ue_ind,1}) && ~isempty(BS_tables{ue_ind,2})
        row = UE_tables{ue_ind,1}(1,:);
        UE_tables{ue_ind,1}(1,:) = [];
        % delete all packets arrived before the time of row; the threshold of 
        % 10e-3 s is to ensure that even if the two devices are not sycnronized, 
        % matching packets are not deleted
        while BS_tables{ue_ind,2}(1,:).Timestamp < row.Timestamp + sync_error_est
            BS_tables{ue_ind,2}(1,:) = [];
            counter_discarded_packets = counter_discarded_packets + 1;
        end
        for row_ind = 1:min(search_window_size,height(BS_tables{ue_ind,2}))
            % check conditions for compared variables
            conditions = false(length(vars_compared),1);
            for i = 1:length(vars_compared)
                conditions(i) = row.(vars_compared(i)) == ...
                    BS_tables{ue_ind,2}(row_ind,:).(vars_compared(i));
            end
            if all(conditions)
                counter_seq_match = counter_seq_match + 1;
                time_diff{ue_ind,2} = [time_diff{ue_ind,2};
                    BS_tables{ue_ind,2}(row_ind,:).Timestamp - row.Timestamp];
                BS_tables{ue_ind,2}(row_ind,:) = [];
                break
            end
            if row_ind == min(search_window_size,height(BS_tables{ue_ind,2}))
                counter_unarrived_packets = counter_unarrived_packets + 1;
            end
        end
    end
    time_UE_to_BS = toc

end

%% Display
disp( ...
    "Number of packet collected:        " + n_tot_packets + newline + ...
    "Number of packets matched:         " + ...
    sum([length(time_diff{1,1}),length(time_diff{1,2})]) + newline + ...
    "Number of packets with seq match:  " + counter_seq_match + newline + ...
    "Number of packets unarrived:       " + counter_unarrived_packets + newline + ...
    "Number of packets discarded:       " + counter_discarded_packets + newline +...
    "Number of total packets analised:  " + ...
    sum([length(time_diff{1,1})*2,length(time_diff{1,2})*2, ...
    counter_unarrived_packets,counter_discarded_packets, ...
    height(BS_tables{1,1}),height(BS_tables{1,2}), ...
    height(UE_tables{1,1}),height(UE_tables{1,1})]))


%% Plot

figure(1)
subplot(311)
plot(time_diff{1,1})
subplot(312)
boxplot(time_diff{1,1})
subplot(313)
ecdf(time_diff{1,1})

figure(2)
subplot(311)
plot(time_diff{1,2})
subplot(312)
boxplot(time_diff{1,2})
subplot(313)
ecdf(time_diff{1,2})

