################################################################################################################
 ##############################            (C) Andres Perez-Lopez, ICAD 2015         ##############################
 ##############################            all wrongs reserved                       ##############################
################################################################################################################


from __future__ import absolute_import, print_function

from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream

import json
import httplib

import OSC

client = OSC.OSCClient()
client.connect( ('127.0.0.1', 57120) )

consumer_key="consumer_key"
consumer_secret="consumer_secret"
access_token="access_token"
access_token_secret="access_token_secret"


class StdOutListener(StreamListener):
    """ A listener handles tweets are the received from the stream.
    This is a basic listener that just prints received tweets to stdout.
    """
    def on_data(self, data):
        # print(data)
        # print(type(data))
        # return True

        decoded = json.loads(data)

        try:
            if decoded['coordinates'] is None:
                country_code = decoded["place"]["country_code"]
                print(country_code)

                msg = OSC.OSCMessage() #  we reuse the same variable msg used above overwriting it
                msg.setAddress("/cc")
                msg.append(country_code)
                client.send(msg)
                pass
            else:
                x = decoded['coordinates']['coordinates'][0]
                y = decoded['coordinates']['coordinates'][1]
                country_code = decoded["place"]["country_code"]
                print(x,y,country_code)

                msg = OSC.OSCMessage() #  we reuse the same variable msg used above overwriting it
                msg.setAddress("/loc")
                msg.append(x)
                msg.append(y)
                msg.append(country_code)
                client.send(msg)
        except (KeyError, NameError, TypeError):
            pass
        # except IncompleteRead:
        #     pass

        return True

    def on_error(self, status):
        print(status)
        if status == 420:
            print(status)
            #returning False in on_data disconnects the stream
            return False



if __name__ == '__main__':
    l = StdOutListener()
    auth = OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)

    stream = Stream(auth, l)
    # stream.filter(track=['icad2015'], async=True)
    # stream.filter(locations=[-74,40,-73,41])
    # stream.filter(locations=[13.4515101,45.0704153,17.4515101,49.0704153], async=True) #austria
    # stream.filter(locations=[13.344269,52.486125,13.480225,52.549219], async=True) #berlin

    stream.filter(locations=[8.349609375,43.6440258476, 20.786132812, 50.569282865], async=True)
    #           -10.37109375, 36.94989178681327, 30.146484374999996, 58.95000823335702 #europe
    # 47.0704153,15.4515101 ---> TU GRAZ: CONFERENCE VENUE
