### This module is dependent on the 'BasicArducopter' project by John Buczek.

### Imports ---------
from BasicArdu import BasicArdu, Frames
from time import sleep, time


## from BasicArducopter.BasicArdu.BasicArdu import BasicArdu, Frames

### Main Function ----------
def main():
	
	drone = BasicArdu( connection_string = 'tcp:127.0.0.1:5762' )
	drone.handle_landing()

	#disarming
	if drone.verbose:
		print('> Disarming')
		drone.vehicle.armed=False
		sleep(5)

### Program entry point ----------
if __name__ == '__main__':
	main()