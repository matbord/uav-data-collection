close all, clear all, clc
format long

load("data.mat")

% debug
figure(1)
semilogy(UE_tables{1,1}.Timestamp,UE_tables{1,1}.SequenceNumber,'b', ...
    BS_tables{1,2}.Timestamp,BS_tables{1,2}.SequenceNumber,'r')
% end debug

%% Init variables and counters
search_window_size = 30;
counter_discarded_packets = 0;
counter_unarrived_packets = 0;
time_diff = [];
counter_seq_match = 0;
% vars_compared = ["SequenceNumber", "MavlinkCommand", ...
%     "IPSourceHost", "TCPSourceHost", "IPDestHost", "TCPDestPort", ...
%     "PacketLength"];vars_compared = ["SequenceNumber", "PacketLength"];

vars_compared = ["SequenceNumber", "MavlinkCommand", "PacketLength"];
% vars_comp = zeros(length(vars_compared), 1);
% for ind = 1:length(vars_compared)
%     vars_comp(ind) = find(vars_compared(ind) == ...
%         BS_tables{1,1}.Properties.VariableNames);
% end

%% Compute time difference

for ue_ind = 1:number_ues % loop over the UEs

%     % from BS to UE
%     while ~isempty(BS_tables{ue_ind,1}) && ~isempty(UE_tables{ue_ind,2})
%         row = BS_tables{ue_ind,1}(1,:);
%         BS_tables{ue_ind,1}(1,:) = [];
%         % delete all packets arrived before the time of row; the threshold of 
%         % 10e-3 s is to ensure that even if the two devices are not sycnronized, 
%         % matching packets are not deleted
%         while UE_tables{ue_ind,2}(1,:).Timestamp < row.Timestamp  + 10e-3
%             UE_tables{ue_ind,2}(1,:) = [];
%         end
%         for row_ind = 1:min(search_window_size,height(UE_tables{ue_ind,2}))
%             % check conditions for compared variables
%             conditions = false(length(vars_compared),1);
%             for i = 1:length(vars_compared)
%                 conditions(i) = row.(vars_compared(i)) == UE_tables{ue_ind,2}(row_ind,:).(vars_compared(i));
%             end
%             if all(conditions)
%                 time_diff = [time_diff;
%                     row.Timestamp - UE_tables{ue_ind,2}(row_ind,:).Timestamp];
%                 UE_tables{ue_ind,2}(row_ind,:) = [];
%                 break
%             end
%             if row_ind == min(search_window_size,height(UE_tables{ue_ind,2}))
%                 counter_unarrived_packets = counter_unarrived_packets + 1;
%             end
%         end
%     end

    tic
    % from UE to BS
    while ~isempty(UE_tables{ue_ind,1}) && ~isempty(BS_tables{ue_ind,2})
        row = UE_tables{ue_ind,1}(1,:);
        UE_tables{ue_ind,1}(1,:) = [];
        % delete all packets arrived before the time of row; the threshold of 
        % 10e-3 s is to ensure that even if the two devices are not sycnronized, 
        % matching packets are not deleted
        while BS_tables{ue_ind,2}(1,:).Timestamp < row.Timestamp + 10e-3
            BS_tables{ue_ind,2}(1,:) = [];
        end
        for row_ind = 1:min(search_window_size,height(BS_tables{ue_ind,2}))
            
            % debug
            row(:,[1,2,3,8]), BS_tables{ue_ind,2}(row_ind,[1,2,3,8])
            % end debug
            
            % check conditions for compared variables
            conditions = false(length(vars_compared),1);
            for i = 1:length(vars_compared)
                conditions(i) = row.(vars_compared(i)) == ...
                    BS_tables{ue_ind,2}(row_ind,:).(vars_compared(i));
            end

            % debug
            if conditions(1) == true
                counter_seq_match = counter_seq_match + 1;
            end
            % end debug

            if all(conditions)
                time_diff = [time_diff;
                    row.Timestamp - BS_tables{ue_ind,2}(row_ind,:).Timestamp];
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
    "Number of packet collected:       " + n_tot_packets + newline + ...
    "Number of packets matched:        " + length(time_diff) + newline + ...
    "Number of packets with seq match: " + counter_seq_match + newline + ...
    "Number of packets not matched   : " + ...
    sum([counter_unarrived_packets,counter_discarded_packets]))

%% Plot

figure(1)
subplot(311)
plot(time_diff)
subplot(312)
boxplot(time_diff)
subplot(313)
ecdf(time_diff)


