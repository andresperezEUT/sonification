////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////            (C) Andres Perez-Lopez, ICAD 2015         ////////////////////////////
//////////////////////////////            all wrongs reserved                       ////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

(
n=NetAddr("127.0.0.1",12000); // processing

r=SpatialRender.new(s).verbose_(false);
s.doWhenBooted({
	r.setBinauralDecoder(\cipic,33);
	SynthDef(\test,{ |out=10,freq=440,amp=1|
		Out.ar(out,SinOsc.ar(freq,mul:amp*EnvGen.kr(Env.perc,doneAction:2)));
	}).add;
	//r.setBinauralDecoder(\listen,1030);
	{
		w = SSWorld([30,30,10]).showView;
		w.setSweetSpotSize(1.5);

		~ccFunc = false;
		~locFunc = false;

		~grazLoc = Point(15.4515101,47.0704153); // TU Graz
		~offsetAngle = 0;

		~countryLocs = (
			\RS: Point(20.468056,44.818611),
			\CH: Point(7.4666667, 46.9166667),
			\RO: Point( 26.1,44.4333333),
			\IT: Point(12.4833333,41.9),
			\BA: Point(18.3833333,43.85),
			\DE: Point(13.4,52.5166667),
			\AT: Point(16.3666667,48.2),
			\PL: Point(21,52.25),
			\HR: Point(16,45.8),
			\SK: Point(17.1166667,48.15),
			\FR: Point(2.333333,48.866667),
			\SI: Point(14.5144444,46.0552778),
			\CZ: Point(14.4666667,50.0833333),
			\HU: Point(19.0833333,47.5)
		);

		~countries = ~countryLocs.keys.asArray;
		~countryObjects = Array.newClear(~countries.size);
		~countries.do{|cc,i|
			var pos = ~grazLoc - ~countryLocs[cc];
			~countryObjects.put(i,SSObject(w,channel:i,name:cc).loc_([pos.y.neg,pos.x,0]).present_(false));
		};

		OSCdef(\cc,{ |msg|
			if (~ccFunc) {
				var cc = msg[1]; // country code
				var out = ~countries.indexOf(cc);

				var object = ~countryObjects.at(out);

				object.present_(true);
				{object.present_(false)}.defer(1);

				Synth(\test,[\freq,880,\out,out+2,\amp,0.6]);

				// visualization;
				n.sendMsg("/cc",~countries.indexOf(cc));
			}
		},'/cc');

		o=SSObject(w,[2,0,0],name:\O,channel:~countries.size).present_(false);

		OSCdef(\loc,{ |msg|
			if (~locFunc) {
				var x = msg[1]; // longitude
				var y = msg[2]; // latitude
/*				var newLoc = ~grazLoc - Point(x,y);
				o.loc_([newLoc.y.neg,newLoc.x,0]);*/

				var newLoc = (~grazLoc - Point(x,y)).asPolar ;
				newLoc.theta_(newLoc.theta + ~offsetAngle);
				newLoc = newLoc.asCartesian;
				o.loc_([newLoc.y.neg,newLoc.x,0]);

				o.present_(true);
				{o.present_(false)}.defer(1);


				Synth(\test,[\out,~countries.size+2,\amp,0.75]);

				// visualization;
				n.sendMsg("/loc",newLoc.x.neg.linlin(-15,15,0,1),newLoc.y.linlin(-15,15,0,1));
			}
		},'/loc');

		// one per country + the one with geolocation
		(~countries.size+2).do { |i|
			var string = "jack_connect SuperCollider:out_" ++ (i+2).asString ++ " SuperCollider:in_" ++ i;
			string.systemCmd;
		};
	}.defer(3);
	// run twitter script
	// {"python /home/pans/Documentos/python/twitter/test_tweepy.py".runInTerminal;}.defer(3);


	////////////////////////////////////////////7
	// CONTROL WINDOW

	~controlWindow = Window.new("control",Rect(500,Window.screenBounds.height-50,200,50)).front.alwaysOnTop_(true);
	["cc","loc"].do{ |str,i|
		b = Button(~controlWindow,Rect(0+(50*i),0,50,50));
		b.states_([[str, Color.white, Color.black],[str, Color.black, Color.green]]);
		b.action_({|but|
			switch(str)
			{"cc"} {~ccFunc=but.value.asBoolean}
			{"loc"} {~locFunc=but.value.asBoolean}
		});
	};
	Slider2D(~controlWindow, Rect(100, 0, 50, 50))
	.x_(0.5) // initial location of x
	.y_(1)   // initial location of y
	.action_({|sl|
		var polar = Point(sl.x-0.5,sl.y-0.5).asPolar;
		var angle = polar.theta;
		var newPos = Polar(0.5,angle);
		sl.x_(newPos.x+0.5);
		sl.y_(newPos.y+0.5);
		~offsetAngle = angle - (pi/2);
		~countryObjects.do{|o|
			var pos = (~grazLoc - ~countryLocs[o.name]).asPolar ;
			pos.theta_(pos.theta + ~offsetAngle);
			pos = pos.asCartesian;
			o.loc_([pos.y.neg,pos.x,0])
		}
	});


});
)