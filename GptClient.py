import cv2
import numpy as np
import socket

# Create a socket object
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Get the server's IP address
host = "127.0.0.1"

# Connect to the server
port = 8080
client_socket.connect((host, port))

# Start receiving video frames from server
while True:
    # Receive video frame from server
    data = client_socket.recv(65507)
    encoded_frame = np.frombuffer(data, dtype=np.uint8)
    frame = cv2.imdecode(encoded_frame, cv2.IMREAD_COLOR)

    # Check if frame is valid
    if frame is not None and frame.size > 0:
        # Display video frame
        cv2.imshow('frame', frame)

    # Exit loop if 'q' is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release resources
cv2.destroyAllWindows()
client_socket.close()



