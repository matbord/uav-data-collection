import cv2
import numpy as np
import socket
import time

# Create a socket object
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Get the server's IP address
host = "127.0.0.1"

# Bind the socket to a public host and port
port = 8080
server_socket.bind((host, port))

# Listen for incoming connections
server_socket.listen(1)
print(f"Listening for incoming connections on {host}:{port}...")

# Accept a client connection
client_socket, client_address = server_socket.accept()
print(f"Accepted connection from {client_address[0]}:{client_address[1]}")

# Set the initial video quality parameters
video_quality = 80
video_fps = 30

# Start streaming video frames to the client
capture = cv2.VideoCapture(0)
while True:
    # Capture a video frame
    ret, frame = capture.read()

    # Encode the video frame with the current video quality parameters
    encode_param = [int(cv2.IMWRITE_JPEG_QUALITY), video_quality]
    result, encoded_frame = cv2.imencode('.jpg', frame, encode_param)

    # Send the encoded video frame to the client
    try:
        client_socket.send(encoded_frame.tobytes())
    except:
        break

    # Wait for a short time to simulate video streaming at a fixed frame rate
    time.sleep(1.0/video_fps)

    # Check the connection quality and adjust the video quality parameters if necessary
    connection_quality = client_socket.getsockopt(socket.SOL_SOCKET, socket.SO_ERROR)
    if connection_quality == 0:
        # Good connection quality, maintain current video quality
        pass
    elif connection_quality == 104:
        # Connection reset by peer, break out of the loop and stop streaming
        break
    else:
        # Poor connection quality, decrease video quality and frame rate
        if video_quality > 50:
            video_quality -= 10
        if video_fps > 5:
            video_fps -= 1

# Release resources
capture.release()
server_socket.close()
