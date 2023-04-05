import pyshark
import csv
import datetime

"""
1) filter only packets tht I need in both send and receive file
2) check that they have the same size
3) substract from the received time, the sending time

dir(packet.mavlink_proto) #see all attributes for mavlink_proto
"""

# Open the pcapng file for reading, filtering by "mavlinkproto" command
pcapName=input("Write the pcap file name to read: ")
csvName=input("Write the name of csv output file: ")
capture = pyshark.FileCapture(pcapName+'.pcapng')
#print(capture[0].mavlink_proto.get_field_by_showname('Message id'))
#print(capture[0].mavlink_proto)
# Create a new CSV file for writing
with open(csvName+'.csv', 'w', newline='') as outfile:
    # Create a CSV writer object
    writer = csv.writer(outfile)
    # # Iterate over the packets in the capture
    for packet in capture:
        #Write the packet and UTC timestamps to the CSV file
        #epoch time timestamp, sequence number, pckt message id (command id), source ip/port, destination ip/port, packet size app layer
        if 'mavlink_proto' in packet:
            writer.writerow([packet.sniff_timestamp, packet.tcp.seq, packet.mavlink_proto.get_field_by_showname('Payload'), packet.ip.src_host, packet.tcp.srcport, packet.ip.dst_host, packet.tcp.dstport, packet.length ])

