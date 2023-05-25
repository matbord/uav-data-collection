#!/usr/bin/env python3


from BasicArdu import BasicArdu, Frames
from argparse import ArgumentParser
from time import sleep, time
from math import pi



# Main Method
def main():
    # simple use example
    print('---Starting Basic Drone---')
    drone  = BasicArdu(connection_string='tcp:127.0.0.1:5762')    # connect to Intel Aero using 'North, East, Down' Reference Basis

    #arming
    #drone.handle_arm()

    # takeoff drone
    drone.handle_takeoff(5)  # takeoff alititude: 5 ft
    
    # goto first waypoint
    drone.handle_waypoint(Frames.NED, 5.0, 0, -5.0, 0)    # 5 ft North, 0 ft East, -5 ft Down (original position), Yaw angle 0rad (North) 

    # goto second wayoint
    drone.handle_waypoint(Frames.NED, 5.0, 5.0, -5.0, 0) # 5 ft North, 5 ft East, -5 ft Down, Yaw angle 0rad (North)


    # go to the third waypoint
    drone.handle_waypoint(Frames.NED, 0, 5.0, -5.0, 0) # O meters North, -10 meters East (10 meters West), 0 meters down, Yaw angle 0rad (North)
    
    # goto Home waypoint (starting position)
    drone.handle_waypoint(Frames.NED, 0, 0, -5.0, 0)   # original position after takeoff

    # land
    drone.handle_landing()

    #disarming
    if drone.verbose:
        print('> Disarming')
    drone.vehicle.armed=False

    sleep(5)


if __name__ == '__main__':
    main()  # Calls main method if the python file is run directly (python3 filename.py)


