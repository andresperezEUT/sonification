////////////////////////////////////////////////////////////////////////////
//
// Copyright ANDRÉS PÉREZ LÓPEZ, April 2014 [contact@andresperezlopez.com]
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; withot even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>
//
////////////////////////////////////////////////////////////////////////////
//
// This document contains the buffer and synths definition to be used
// in traffic_osc.scd
//
////////////////////////////////////////////////////////////////////////////





// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
// load claxon buffers
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
var path = Platform.userHomeDir+/+"Documentos/netlogo/traffic/sounds";
var numSamples=6;

~traffic = Array.new(numSamples);

(1..numSamples).do { |i|
	var string = "traffic"++i.asString++".wav";
	~traffic.add(Buffer.read(s,path+/+string))
};

~loud = Buffer.read(s,path+/+"traffic_loud.wav");

// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
// define synthdefs
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // //


 // engine-like sound mean speed
SynthDef(\mean_speed,{ |val=0,level=0|
	var freq;
	freq=LinLin.kr(val,0,1,100,400);
	Out.ar(0,SinOsc.ar(freq,mul:0.2*level)!2)
	// SinOsc.ar()
}).add;


// some high-pitched trigger sound for the traffic lights
SynthDef(\tick,{
	var sig=FreeVerb.ar(SinOsc.ar(1000,mul:0.75*EnvGen.kr(Env.perc(0.01,0.5,0.2), doneAction: 2)),room:0.25,damp:1);
	Out.ar(0,sig!2)
}).add;


// traffic claxons that sporadically trigger due to waiting time
SynthDef(\traffic, { |bufnum,level=1|
	var sig, pos;
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum),doneAction:2);
	pos=Rand.new(-1,1);
	Out.ar(0, Pan2.ar(sig,pos,level))
}).add;


// backgound traffic noise related with percentage of stopped cars
SynthDef(\stop, { |bufnum,level=0|
	var sig, pos;
	sig = level*PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum),loop:1,doneAction:2);
	Out.ar(0, [sig,DelayN.ar(sig,delaytime:0.1)])
}).add;


