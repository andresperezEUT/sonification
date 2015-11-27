/******************************************************************************
*                                                                             *
*    ------------------- Twitter Text2Speech Sonification ------------------- *
*               people gossip in Barcelona, discover about what               *
*        presented at CC Convent de Sant Agustí, #Recorreguts Sonors 2015     *
*                                                                             *
*                                   twitter.scd                               *
*                   (c) La Neurona Tropical, November 2015                    *
*                               All Wrongs Reserved                           *
*                                                                             *
******************************************************************************/
(

// change it according to the speaker setup
var numChannels = 8;

// put here your audioFiles folder path
var pathToAudioFiles = "/path/to/audio/files";

// time until files are deleted
var wait = 15;

~fileNames = List.new;
~buffers = List.new;

// run the server
s.boot;

s.doWhenBooted({

	// define the SynthDef
	SynthDef(\playBuf, {| bufnum = 0, pos = 0,rate=1, amp=1 |
		var buf = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, doneAction:2);
		var pan = PanAz.ar(numChans:numChannels, in: buf, pos:pos);
		Out.ar(0, pan*amp);
	}).add;

	"server booted".postln;

	OSCdef(\python, {|msg, time, addr, recvPort|
		var fileName = msg[1].postln;
		var pos = 2.0.rand;

		~fileNames.addFirst(fileName);
		// load the mp3 file into a buffer
		b = MP3.readToBuffer(s, pathToAudioFiles +/+ fileName ++ ".mp3");
		~buffers.addFirst(b);
		// play the buffer
		Synth(\playBuf,[bufnum:b,pos:pos,rate:0.1.rand+0.95,amp:(0.75.rand+0.25).postln]);

        // free buffer and remove file
        {
            ~buffers.pop().free;
            ~name = pathToAudioFiles +/+ ~fileNames.pop() ++ ".mp3";
            ("rm " ++ ~name).unixCmd;
        }.defer(wait);
	},'/cc');
})
)
