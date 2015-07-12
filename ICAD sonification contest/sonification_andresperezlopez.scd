////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////            (C) Andres Perez-Lopez, ICAD 2015         ////////////////////////////
//////////////////////////////            all wrongs reserved                       ////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//// SONIFICATION CONTEST --- CLUSTER

(
r=SpatialRender.new(s).verbose_(false);


s.doWhenBooted({

	////////////////////////////////////////////////////////////////////////////////////
	// LOAD DATA


	~c = Array.newClear(4);
	~path="/home/pans/Documentos/papers/icad2015/SONIFICATION_CONTEST/data/Cluster/";

	~satNames=["C1","C2","C3","C4"];

	~featureNames=[
		"_B_xy.wav",
		"_B_zt.wav",
		"_Pos_xy.wav",
		"_Pos_z.wav",
		"_time.wav"
	];

	~reduceData = { |array, step=100| array.select({|a,i| (i%step == 0)})};

	"loading...".postln;
	Task({
		~satNames.do{ |sn,i|
			d = ();
			Buffer.readChannel(s, ~path ++ sn ++ ~featureNames[0],channels:[0]).loadToFloatArray(action:{|a|d.add(\bX -> ~reduceData.(a))});
			Buffer.readChannel(s, ~path ++ sn ++ ~featureNames[0],channels:[1]).loadToFloatArray(action:{|a|d.add(\bY -> ~reduceData.(a))});
			Buffer.readChannel(s, ~path ++ sn ++ ~featureNames[1],channels:[0]).loadToFloatArray(action:{|a|d.add(\bZ -> ~reduceData.(a))});
			Buffer.readChannel(s, ~path ++ sn ++ ~featureNames[1],channels:[1]).loadToFloatArray(action:{|a|d.add(\bT -> ~reduceData.(a))});
			Buffer.readChannel(s, ~path ++ sn ++ ~featureNames[2],channels:[0]).loadToFloatArray(action:{|a|d.add(\x -> ~reduceData.(a))});
			Buffer.readChannel(s, ~path ++ sn ++ ~featureNames[2],channels:[1]).loadToFloatArray(action:{|a|d.add(\y -> ~reduceData.(a))});
			Buffer.readChannel(s, ~path ++ sn ++ ~featureNames[3],channels:[0]).loadToFloatArray(action:{|a|d.add(\z -> ~reduceData.(a))});
			Buffer.readChannel(s, ~path ++ sn ++ ~featureNames[4],channels:[0]).loadToFloatArray(action:{|a|d.add(\t -> ~reduceData.(a))});

			d.add(\vX -> d[\x].differentiate.put(0,0));
			d.add(\vY -> d[\y].differentiate.put(0,0));
			d.add(\vZ -> d[\z].differentiate.put(0,0));
			d.add(\dBX -> d[\bX].differentiate.put(0,0));
			d.add(\dBY -> d[\bY].differentiate.put(0,0));
			d.add(\dBZ -> d[\bZ].differentiate.put(0,0));
			d.add(\dBT -> d[\bT].differentiate.put(0,0));
			~c.put(i,d);

			(sn).postln;
			// 1.wait;
		};

		~len = d[\bX].size;

		// total magnetic field
		~bT=Array.newClear(~len);
		~len.do{|i|
			~bT.put(i,~c[0][\bT][i]+~c[1][\bT][i]+~c[2][\bT][i]+~c[3][\bT][i]);
		};

		// total magnetic field derivative
		~dBT=Array.newClear(~len);
		~len.do{|i|
			~dBT.put(i,~c[0][\dBT][i].abs+~c[1][\dBT][i].abs+~c[2][\dBT][i].abs+~c[3][\dBT][i].abs);
		};
		"READY".postln;

		////////////////////////////////////////////////////////////////////////////////////
		// SYNTHDEF

		SynthDef(\sat,{ |out=0,freq=440,amp=0.5,nf=0,bwr=10|
			var sig = SinOsc.ar(WhiteNoise.kr(1000 + nf,100),mul:amp);
			sig = Resonz.ar(sig,((WhiteNoise.kr > MouseY.kr(0,10))*3000+1000),bwr);
			sig = sig + (1.5*PitchShift.ar(sig,pitchRatio:0.25));
			Out.ar([0,1],FreeVerb.ar(sig,mix:0.1,room:0.5));
			//Out.ar([0,1],sig);
		}).add;

		SynthDef(\ping,{ |out=0, delay = 0, amp = 1|
			var trig = Trig.ar(Impulse.ar(0.5), 0.1);
			var freq1 = WhiteNoise.kr(mul:0.5,add:1)*150+1500;
			var freq2 = WhiteNoise.kr(mul:0.5,add:1)*150+1500;
			var latch1 = Latch.kr(freq1,trig);
			var latch2 = Latch.kr(freq2,trig);
			var sig   = Decimator.ar((SinOsc.ar(latch1,mul:0.2) + SinOsc.ar(latch2,mul:0.2)),2500,5);
			var del = DelayN.ar(sig,0.2,delay);
			var env = EnvGen.kr(Env.perc(releaseTime:0.15),gate:trig);
			var rev = FreeVerb.ar(del*env,mix:1,room:0.1);
			Out.ar(out,rev*amp);
		}).add;

		////////////////////////////////////////////////////////////////////////////////////
		// SSWORLD
		{
			r.setBinauralDecoder(\cipic,33);
			w = SSWorld([100,100,20]).showView;
			w.setSweetSpotSize(1);

			~satObjects = Array.newClear(~satNames.size);
			~satSynths = Array.newClear(~satNames.size);
			~satNames.do{|n,i|
				~satObjects.put(i,SSObject(w,[~c[i][\x][0],~c[i][\y][0],~c[i][\z][0]],name:n,channel:i).present_(false));

				~satSynths.put(i,Synth(\ping,[\out,i+2,\delay,i*0.1]));
				("jack_connect SuperCollider:out_"++(i+3)++" SuperCollider:in_"++(i+1)).systemCmd;

			};


		}.defer(3);


	}).play;
})
)




////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
// PLAY



(
~synth=Synth(\sat,[\amp:0.01]);
//~bT.plot;
//~dBT.plot;

~satObjects.do(_.present_(true));
~t=Task({
	(~len).do{|i|
		~satObjects.do{|o,oi|
			var x = ~c[oi][\x][i].linlin(-1,1,-100,100);
			var y = ~c[oi][\y][i].linlin(-1,1,-100,100);
			var z = ~c[oi][\z][i].linlin(-1,1,-20,20);
			var d = ((x.pow(2))+y.pow(2)).sqrt.linlin(20,60,2,0.6);

			var bT = ~bT[i];
			var dBT = ~dBT[i];
			~synth.set(
				\nf,dBT.linlin(0,0.2,0,10000),
				\bwr,bT.linlin(0,2.2,0.01,20),
				\amp,dBT.linexp(0,0.025,0.04,0.08)
			);

			~satSynths[oi].set(\amp,d);
			o.loc_([x,y,z]);
		};
		{w.window.refresh}.defer;
		(1 / 300).wait;
	};
	~satObjects.do(_.present_(false));
	~synth.free;
}).play;
)

// PAUSE
(
~t.pause;
~synth.free;
)
