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
capture = pyshark.FileCapture('BS-script.pcapng', display_filter='mavlink_proto')
dir(capture[1].tcp)
# Create a new CSV file for writing
with open('output.csv', 'w', newline='') as outfile:
    # Create a CSV writer object
    writer = csv.writer(outfile)

    # Iterate over the packets in the capture
    for packet in capture:
        # Convert the local timestamp to UTC
        local_time = datetime.datetime.fromisoformat(packet.sniff_time.isoformat())
        utc_time = datetime.datetime.utcfromtimestamp(local_time.timestamp())

        # Write the packet and UTC timestamps to the CSV file
        writer.writerow([utc_time, packet.mavlink_proto])



# # Open the output CSV file for reading
# with open('output.csv', 'r') as infile:
#     # Create a CSV reader object
#     reader = csv.reader(infile)

#     # Iterate over the rows in the file
#     for row in reader:
#         # Extract the mavlinkproto field from the row
#         mavlinkproto = row[2]

#         # Print the name of the packet
#         print('Packet name:', mavlinkproto)


#mockup code

# # Open the first pcapng file for reading
# capture1 = pyshark.FileCapture('file1.pcapng')

# # Open the second pcapng file for reading
# capture2 = pyshark.FileCapture('file2.pcapng')

# # Identify the packets in both files that correspond to the same event or transaction
# packet1 = None
# packet2 = None

# for packet in capture1:
#     # Check if this is the first packet of interest
#     if packet.some_condition:
#         packet1 = packet
#         break

# for packet in capture2:
#     # Check if this is the second packet of interest
#     if packet.some_condition:
#         packet2 = packet
#         break

# # Calculate the one-way time between the packets
# if packet1 is not None and packet2 is not None:
#     # Convert the local timestamps to UTC
#     local_time1 = datetime.datetime.fromisoformat(packet1.sniff_time.isoformat())
#     local_time2 = datetime.datetime.fromisoformat(packet2.sniff_time.isoformat())
#     utc_time1 = datetime.datetime.utcfromtimestamp(local_time1.timestamp())
#     utc_time2 = datetime.datetime.utcfromtimestamp(local_time2.timestamp())

#     # Calculate the one-way time
#     one_way_time = utc_time2 - utc_time1

#     # Print the one-way time in seconds
#     print(f"One-way time: {one_way_time.total_seconds()} seconds")
# else:
#     print("Packets not found in both files.")