import serial
import numpy as np
import matplotlib.pyplot as plt

ser = serial.Serial('COM3',115200)

angles=[]
distances=[]

while True:

    line = ser.readline().decode().strip()

    angle,d = line.split(",")

    angles.append(float(angle))
    distances.append(float(d))

    if len(angles) >= 20:
        break

angles.np.radians(angles)

x = np.cos(angles)*distances
y = np.sin(angles)*distances


plt.scanner(x,y)
plt.titel("Puddle Eyes Scan")
plt.xlabel("X")
plt.yLabel("Y")
plt.show()