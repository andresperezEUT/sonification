////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////            (C) Andres Perez-Lopez, ICAD 2015         ////////////////////////////
//////////////////////////////            all wrongs reserved                       ////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

(

r=SpatialRender.new(s).verbose_(false);

~satDistance = 2;

s.doWhenBooted({
	r.setBinauralDecoder(\cipic,33);
	/*	SynthDef(\sat,{ |out=2,freq=440,amp=0.5|
	Out.ar(out,SinOsc.ar(freq,mul:amp));
	}).add;*/
	SynthDef(\sat,{ |out=2,freq=440,amp=0.5|
		var sig = SinOsc.ar(WhiteNoise.kr(1000,100),mul:amp);
		Out.ar(out,Resonz.ar(sig,((WhiteNoise.kr*10 > 5)*3000+1000),(WhiteNoise.kr*10 > 5) *2 + 5));
	}).add;


	//r.setBinauralDecoder(\listen,1030);
	{
		w = SSWorld([10,10,10]).showView;
		w.setSweetSpotSize(1.5);

		~sats = [
			'ISS (ZARYA)             ',
			'TIANGONG 1',
			'SOYUZ-TMA 15M',
			'SPINSAT',
			'PROGRESS-M 26M',
			'FLOCK 1B-27',
			'FLOCK 1B-28',
			'FLOCK 1B-21',
			'FLOCK 1B-22',
			'FLOCK 1B-10',
			'FLOCK 1B-9',
			'FLOCK 1D-1',
			'FLOCK 1D-2',
			'FLOCK 1B-5',
			'FLOCK 1B-6',
			'GEARRS-1',
			'MICROMAS',
			'FLOCK 1B-11',
			'FLOCK 1B-12',
			'SOYUZ-TMA 16M'
		];

		~satObjects = Array.newClear(~sats.size);

		~sats.do { |s,i|
			[s,i].postln;
			~satObjects.put(i, SSObject(w,channel:i,name:s).locSph_([~satDistance,2pi.rand,0]).present_(false));
		};



		OSCdef(\sat,{ |msg|
			var name = msg[1];
			var long = msg[2]; // azimuth in degrees
			var lat = msg[3]; // elevation in degrees

			var index = ~sats.indexOf(name) ? 0; // small problem with ISS name...
			var obj= ~satObjects[index];

			obj.locSph_(azi:long.degree2rad);
			obj.locSph_(ele:lat.degree2rad);
		},'/sat');

		~sats.size.do{|i|
			Synth(\sat,[\out,2+i,\amp,0.3]);
			("jack_connect SuperCollider:out_"++(i+3)++" SuperCollider:in_"++(i+1)).systemCmd;
		};


		////////////////////////////////////////////
		// CONTROL WINDOW

		~controlWindow = Window.new("control",Rect(500,Window.screenBounds.height-50,300,500)).front.alwaysOnTop_(true);
		~sats.do{ |str,i|
			if (i < 10) {
				b = Button(~controlWindow,Rect(0,0+(50*i),150,50));
			} {
				b = Button(~controlWindow,Rect(150,0+(50*(i-10)),150,50));
			};
			b.states_([[str, Color.white, Color.black],[str, Color.black, Color.green]]);
			b.value_(0);
			b.action_({|but|
				~satObjects[i].present_(but.value.asBoolean);
			});
		};

	}.defer(3);

});
)
