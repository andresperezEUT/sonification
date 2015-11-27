###############################################################################
#                                                                             #
#    ------------------- Twitter Text2Speech Sonification ------------------- #
#               people gossip in Barcelona, discover about what               #
#        presented at CC Convent de Sant Agustí, #Recorreguts Sonors 2015     #
#                                                                             #
#                                   twitter.py                                #
#                   (c) La Neurona Tropical, November 2015                    #
#                               All Wrongs Reserved                           #
#                                                                             #
###############################################################################

from __future__ import absolute_import, print_function

from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream

import json
import httplib
import pyvona
import datetime

import OSC

client = OSC.OSCClient()
# if the osc client doesn't exist, it will crash here
client.connect( ('127.0.0.1', 57120) )

# put your tweepy streaming access data here
consumer_key=
consumer_secret=
access_token=
access_token_secret=

audioPath = "/path/to/the/folder/where/the/tmp/mp3/files/will/be/stored"


class StdOutListener(StreamListener):
    """ A listener handles tweets are the received from the stream.
    This is a basic listener that just prints received tweets to stdout.
    """
    def on_data(self, data):
        print(data)

        decoded = json.loads(data)


        try:
            string = decoded["text"]

            filename = unicode(datetime.datetime.now().strftime("%d%m%Y_%H%M%S_%f"))
            v = pyvona.create_voice('access_key', 'secret_key')
            v.codec = 'mp3'
            v.voice_name = "Conchita" # maybe also "Miguel"
            v.fetch_voice(string, audioPath + filename)
            
            country_code = decoded["place"]["country_code"]
            print(country_code)

            msg = OSC.OSCMessage() #  we reuse the same variable msg used above overwriting it
            msg.setAddress("/cc")
            msg.append(filename)
            client.send(msg)

        except (KeyError, NameError, TypeError):
            pass
        
        return True

    def on_error(self, status):
        print("ERROR:" + str(status))
        if status == 420:
            print(status)
            #returning False in on_data disconnects the stream
            return False



if __name__ == '__main__':
    l = StdOutListener()
    auth = OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)

    stream = Stream(auth, l)
    stream.filter(locations=[-0.3744964999999638,39.4755755, 2.1858544000000393, 41.4821923], async=True)
