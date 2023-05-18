from BasicArdu import BasicArdu, Frames
from time import sleep, time

# Main Method
def main():
    # simple use example
    print('---Starting Basic Drone---')
    drone  = BasicArdu(connection_string='tcp:192.168.10.110:5760')    # connect to Intel Aero using 'North, East, Down' Reference Basis

    #arming
    drone.handle_arm()
    
    sleep(5)

    #disarming
    if drone.verbose:
        print('> Disarming')
    drone.vehicle.armed=False
    
    # sleep(5)

    # # takeoff drone and arm
    # drone.handle_takeoff(0.1)  # takeoff alititude: 2 meters

    # sleep(5)
    
    # drone.handle_landing()

	# #disarming
    # if drone.verbose:
    #     print('> Disarming')
    #     drone.vehicle.armed=False
    #     sleep(5)

if __name__ == '__main__':
    main()  # Calls main method if the python file is run directly (python3 filename.py)