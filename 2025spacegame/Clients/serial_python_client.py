import serial
import space_api
import time

ip = "10.184.1.111"
port = 9876
role = "weapons"
team = "retro"
weapon_id = 1

space_api.connect(role, team, ip, port)


port = "/dev/tty.usbmodem1101"
#port = "/dev/tty.usbmodem14202"

baud = 115200
ser = serial.Serial(port)
ser.baudrate = baud
print("DO THE THING")
while True:
  if (ser.inWaiting()>0):
    data = ser.read().decode()
    print(data)
    if "Q" in data:
        space_api.power("up","pilot")
        print("Power up pilot")
    elif "W" in data:
        space_api.power("up","weapons")
        print("Power up weapons")
    elif "R" in data:
        space_api.power("down", "pilot")
        print("Power down pilot")
    elif "Y" in data:
        space_api.power("down", "science")