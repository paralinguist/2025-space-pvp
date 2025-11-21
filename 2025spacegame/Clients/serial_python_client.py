import serial
import space_api
import time

ip = "10.202.176.227"
port = 9876
role = "weapons"
team = "retro"
weapon_id = 1

space_api.connect(role, team, ip, port)


port = "/dev/tty.usbmodem11301"
#port = "/dev/tty.usbmodem14202"

baud = 115200
ser = serial.Serial(port)
ser.baudrate = baud

while True:
  if (ser.inWaiting()>0):
    data = ser.read().decode()
    if "b" in data:
        print("pew pew")
        space_api.shoot(5)