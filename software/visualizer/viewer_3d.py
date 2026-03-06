import serial
import numpy as np
import matplotlib.pyplot as plt

from mpl_toolkits.mplot3d import Axes3D

ser = serial.Serial('COM3',115200)

angles=[]
distances=[]

print("Scanning...")

while True:
    line = ser.readline().decode().strip()

    try:
        angle,d = line.split(",")

        angle=float(angle)
        d=float(d)

        angles.append(angle)
        distances.append(d)

    except:
        continue

    if len(angles) >= 40:
        break

angles=np.radians(angles)

x = np.cos(angles)*distances
y = np.sin(angles)*distances

# Simulation de profondeur du terrain
z = -np.array(distances)

fig = plt.figure()

ax = fig.add_subplot(111, projection='3d')

ax.scatter(x,y,z)

ax.set_title("Prototype Puddle Eyes - Terrain Scan")

ax.set_xlabel("X")
ax.set_ylabel("Y")
ax.set_zlabel("Depth")


plt.show()