# waypoint 1 code -- tests to figure out why movingA.py is not working as intended 
# starts from arming, to takeoff, to waypoint, then landing
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
    #drone.handle_takeoff(5)  # takeoff alititude: 5 meters
    
    # goto first waypoint
    #drone.handle_waypoint(Frames.NED, 0, 0, -15.0, 0)    # 10 ft North, 0 ft East, 0 ft Down, Yaw angle 0rad (North)

    #sleep(25).py
    
    # goto Home waypoint (starting position)
    #drone.handle_waypoint(Frames.NED, 0, 0, 10.0, 0)  # back to original position of 5 meters altitude

    ########################### retest of waypoint, initial takeoff at 20 meters and then raising 5 more meters

    # takeoff drone
    drone.handle_takeoff(20)  # takeoff alititude: 20 meters

    sleep(10)
    
    # goto first waypoint
    drone.handle_waypoint(Frames.NED, 0, 0, -25.0, 0)    # 10 ft North, 0 ft East, 0 ft Down, Yaw angle 0rad (North)

    sleep(7)

    drone.handle_waypoint(Frames.NED, 10.0, 0, -25.0, 0)  # 10 ft North, 0 ft East, -25.0 ft Down, Yaw angle 0rad (North)

    sleep(7)


    # goto Home waypoint (starting position)
    drone.handle_waypoint(Frames.NED, 0, 0, -20.0, 0)  # back to original position of 20 meters altitude

    sleep(10)

    # land
    drone.handle_landing()

    # disarming
    if drone.verbose:
        print('> Disarming')
    drone.vehicle.armed=False

    sleep(5)


if __name__ == '__main__':
    main()  # Calls main method if the python file is run directly (python3 filename.py)


