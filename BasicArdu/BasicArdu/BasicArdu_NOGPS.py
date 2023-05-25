from BasicArdu import BasicArdu, Frames
from time import sleep, time

# Main Method
def main():
    # simple use example
    print('---Starting Basic Drone---')
    drone  = BasicArdu(connection_string='tcp:192.168.10.110:5760')    # connect to Intel Aero using 'North, East, Down' Reference Basis

    
    # takeoff drone
    drone.handle_takeoff(2)  # takeoff alititude: 2 meters

    #drone.mode = VehicleMode("STABILIZE")

    #up circle
    # goto first waypoint (3m north, -5 meters east= 5 meters ovest, 5 meters up, facing North)
    drone.handle_waypoint(Frames.NED, 2, -2, -2, 0)
    sleep(1)
    # goto second wayoint
    drone.handle_waypoint(Frames.NED, 4, 0, -2, 0)
    sleep(1)
    # goto third wayoint
    drone.handle_waypoint(Frames.NED, 2, 2, -2, 0)
    sleep(1)
    # goto Home wayoint 
    drone.handle_waypoint(Frames.NED, 0, 0, -2, 0)
    sleep(1)

    #under circle
    drone.handle_waypoint(Frames.NED, -2, -2, -2, 0)
    sleep(1)
    drone.handle_waypoint(Frames.NED, -4, 0, -2, 0)
    sleep(1)
    drone.handle_waypoint(Frames.NED, -2, 2, -2, 0)
    sleep(1)
    drone.handle_waypoint(Frames.NED, 0, 0, -2, 0)
    sleep(1)


    # land
    drone.handle_landing()
    

if __name__ == '__main__':
    main()  # Calls main method if the python file is run directly (python3 filename.py)