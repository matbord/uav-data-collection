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

            # Create a new CSV file for writing
            with open(file_path_no_ext + '.csv', 'w', newline='') as outfile:
                # Create a CSV writer object
                writer = csv.writer(outfile)
                # Write headers
                writer.writerow(["Timestamp", "SequenceNumber", "MavlinkCommand",
                                "IPSourceHost", "TCPSourcePort", "IPDestHost",
                                 "TCPDestPort", "PacketLength"])

                # Iterate over the packets in the capture
                for packet in capture:
                    # Write the chosen variables into the csv file. The variables are:
                    # epoch time, tcp sequence number, pckt message id (command id),
                    # source ip/port, destination ip/port, packet size app layer
                    if 'mavlink_proto' in packet:
                        writer.writerow([packet.sniff_timestamp, packet.tcp.seq,
                                        packet.mavlink_proto.get_field_by_showname(
                                            'Payload'),
                                        packet.ip.src_host, packet.tcp.srcport,
                                        packet.ip.dst_host, packet.tcp.dstport,
                                        packet.length])


if __name__ == "__main__":
    main()
