import argparse
import csv  # try alternatively csvdict for better performance?
import os
import pyshark


def main():
    # Parse arguments
    parser = argparse.ArgumentParser(
        description='Read pcapng files, filter packets, and save them to csv files.'
    )
    parser.add_argument(
        'pcapng_dir',
        metavar='pcapng_dir',
        type=str,
        nargs='?',
        default='data',
        help='Relative path of the directory; supposed to accept an argument like "data".'
    )
    args = parser.parse_args()

    # save absolute path for the directory where the pcapng files are saved
    rel_dir = f"./{args.pcapng_dir}"

    # read .pcapng files
    for file in os.listdir(rel_dir):
        if file.endswith('.pcapng'):
            file_path = f"{rel_dir}/{file}"
            file_path_no_ext, _ = os.path.splitext(file_path)
            file_name = f"{args.pcapng_dir}/{file}"
            capture = pyshark.FileCapture(file_name)

            # check attributes
            # see all attributes for mavlink_proto
            # print(dir(capture[0].tcp.analysis))

            # Iterate over the packets in the capture
            data_map = {}
            for packet in capture:
                # Write the chosen variables in
                # epoch time, tcp sequence number, pckt message id (command id),
                # source ip/port, destination ip/port, packet size app layer
                if 'mavlink_proto' in packet:
                    # print duplicate packets
                    # if packet.tcp.seq in data_map:
                    #     print("Duplicate packet found: " + str(packet.tcp.seq))

                    # packets with the same key are overwritten, so we only keep the last one
                    data_map[packet.tcp.seq] = packet

            # Create a new CSV file for writing
            with open(file_path_no_ext + '.csv', 'w', newline='') as outfile:
                # Create a CSV writer object
                writer = csv.writer(outfile)
                # Write headers
                writer.writerow(["Timestamp", "SequenceNumber", "MavlinkCommand",
                                "IPSourceHost", "TCPSourcePort", "IPDestHost",
                                 "TCPDestPort", "PacketLength", "Retransmission"])

                writer.writerows(data_map.values())


if __name__ == "__main__":
    main()
