from BasicArdu import BasicArdu, Frames
from time import sleep, time

# Main Method
def main():
    # simple use example
    print('---Starting Basic Drone---')
    drone  = BasicArdu(connection_string='tcp:10.228.150.1:5760')    # connect to Intel Aero using 'North, East, Down' Reference Basis
    sleep(5)
    for x in range(0,200):
        print('Loop number ', x)
        #arming
        drone.handle_arm()
        print('Arming')
        sleep(1)

        #disarming
        if drone.verbose:
            print('> Disarming')
            drone.vehicle.armed=False
        print('Disarming')
        
        sleep(1)

        # takeoff drone and arm
        drone.handle_takeoff(0.1)  # takeoff alititude: 0.1 meters

        sleep(1)
        
        drone.handle_landing()

        print('Landed')

        #disarming
        if drone.verbose:
            print('> Disarming')
            drone.vehicle.armed=False
            sleep(1)
        
        drone.handle_kill() #emergency stop
        print('Kill')

        #Upload and Download a mission

        import_mission_filename = '../missions/wp1.waypoints'
        export_mission_filename = '../missions/exportedmission.txt'


        #Upload mission from file
        drone.upload_mission(import_mission_filename)
        print("Mission uploaded")
        sleep(1)
        #Download mission we just uploaded and save to a file
        drone.save_mission(export_mission_filename)
        print("Mission downloaded")
        sleep(1)
        #Close vehicle object before exiting script
        #print("Close vehicle object")
        #drone.vehicle.close()
        # print("\nShow original and uploaded/downloaded files:")
        # #Print original file (for demo purposes only)
        # drone.printfile(import_mission_filename)
        # #Print exported file (for demo purposes only)
        # drone.printfile(export_mission_filename)

if __name__ == '__main__':
    main()  # Calls main method if the python file is run directly (python3 filename.py)uploadeduploaded