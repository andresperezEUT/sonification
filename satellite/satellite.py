################################################################################################################
 ##############################            (C) Andres Perez-Lopez, ICAD 2015         ##############################
 ##############################            all wrongs reserved                       ##############################
################################################################################################################


import ephem
import datetime
import time
from math import degrees
import OSC
import os

client = OSC.OSCClient()
client.connect( ('127.0.0.1', 57120) )

# data from http://www.celestrak.com/NORAD/elements/stations.txt
path = os.path.dirname(os.path.abspath(__file__))
txt = open(path + "/" + "stations.txt")
split = txt.read().split("\n")

while True:

    now = datetime.datetime.utcnow();

    for i in range(0,len(split)-1,3):
    # for i in range(0,1):
        name = split[i]
        data = ephem.readtle(name,split[i+1],split[i+2])
        data.compute(now)
        print name,degrees(data.sublong), degrees(data.sublat)

        msg = OSC.OSCMessage() #  we reuse the same variable msg used above overwriting it
        # msg.setAddress(split[i])
        msg.setAddress("/sat")
        msg.append(split[i])
        msg.append(degrees(data.sublong))
        msg.append(degrees(data.sublat))
        client.send(msg)


    time.sleep(0.5)
