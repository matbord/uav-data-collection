from BasicArdu import BasicArdu, Frames

# Main Method
def main():
    # simple use example
    print('---Starting Basic Drone---')
    drone  = BasicArdu(connection_string='tcp:127.0.0.1:5762')    # connect to Intel Aero using 'North, East, Down' Reference Basis

    #arming
    drone.handle_arm()

    # takeoff drone
    drone.handle_takeoff(2)  # takeoff alititude: 2 meters

if __name__ == '__main__':
    main()  # Calls main method if the python file is run directly (python3 filename.py)



