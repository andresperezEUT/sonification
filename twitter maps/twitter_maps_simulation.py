################################################################################################################
 ##############################            (C) Andres Perez-Lopez, ICAD 2015         ##############################
 ##############################            all wrongs reserved                       ##############################
################################################################################################################


import OSC
import numpy.random as r
import time

client = OSC.OSCClient()
client.connect( ('127.0.0.1', 57120) )



if __name__ == '__main__':

    countries =  [ 'DE', 'SK', 'SI', 'HR', 'CZ', 'FR', 'AT', 'RO', 'CH', 'HU', 'RS', 'PL', 'BA', 'IT' ]
    l = len(countries)

    ccTime = time.time()
    ccWait = r.rand()*3

    locTime = time.time()
    locWait = r.rand()*5

    while True:

        if ( (time.time() - ccTime) > ccWait ):
            ccTime = time.time()
            ccWait = r.rand()*3
            i = int(r.rand()*(l-0.0001))
            cc = countries[i]
            msg = OSC.OSCMessage() #  we reuse the same variable msg used above overwriting it
            msg.setAddress("/cc")
            msg.append(cc)
            client.send(msg)
            print cc

        if ( (time.time() - locTime) > locWait ):
            locTime = time.time()
            locWait = r.rand()*5
            # 15.4515101,47.0704153 # graz location
            x = (r.rand()*20)+5 # [5..25]
            y = (r.rand()*20)+37 # [37..57]
            msg = OSC.OSCMessage() #  we reuse the same variable msg used above overwriting it
            msg.setAddress("/loc")
            msg.append(x)
            msg.append(y)
            client.send(msg)
            print x,y
