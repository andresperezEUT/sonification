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
// traffic_osc.scd
//
// Sonification for the traffic_osc.netlogo model
//
// This model implements a traffic simulation. There are a few parameters:
// -Changing in real-time
// ---On/off power (traffic lights)
// ---ticks per cycle (traffic lights changing rate)
// ---speed limit
//
// -Not-changing in real time (only in setup)
// ---grid size x/y
// ---num-cars (total amount)
//
// The model presents 3 graphical outputs:
// -Number of stopped cars
// -Average of car speed
// -Average of car waiting time
//
//
// Sonification takes these parameters and interpret them in a auditive way.
// There are four different streams:
//
// 1) Average car speed is related with a engine-like sound. The faster the cars, the higher the pitch

// 2) Each time traffic lights change, a tick is triggered

// 3) There is a background continuous traffic light noise.
//    Loudness of this noise is coupled with the percentage of cars stopped (relative to the total amount of cars)

// 4) Drivers get angry when they wait for a while.
//    Every time that multiples of [threshold waiting time] are reached (which is set by default to 20 seconds), somebody hits the claxon.
//    So, in a complete jam, every 20 seconds somebody will get angry.
//
//
// There are still some minor bugs, but anyway the model is working.
//
// Have fun!
//
////////////////////////////////////////////////////////////////////////////


// first, load synthdefs and buffers, if you did not do it before
(
"./traffic_osc_load.scd".loadRelative
)

// then run the code below. netlogo shoud be stopped
// after that, setup and run netlogo model

(
var numCars; //just in case program is not correctly initializated
var power = \true; //not booleans from netlogo, they are symbols

// time threshold in which drivers start to hit the claxon, the souther the lower (:
var th_wait=20;
var min_wait=1;
var current_th_wait=20;

// variables to handel stopped cars
var max_current_cars_stopped=0;
var current_cars_stopped=0;
var last_cars_stopped=0;
var percent=0;

// wether netlogo started to run
var run=0;


// SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

// receive amount of cars at the beggining
OSCdef(\num_cars, {|msg| numCars=msg@1}, '/variables/num_cars');



// RUN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

// these synths are always running and modified on running time
~speed=Synth(\mean_speed);
~stop=Synth(\stop,[\bufnum,~loud]); // start silent until running

// receive the inital run message to start synthesizing engines
OSCdef(\run, {|msg| ~speed.set(\level,msg@1)}, '/variables/run');


// ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
// OSC continuous receivers


// ;;;;;;;;;
// engine sound :: mean speed values
OSCdef(\mean_speed, {|msg| ~speed.set(\val,msg@1)}, '/variables/mean_speed');




// ;;;;;;;;;
// ticks :: traffic lights
OSCdef(\power, {|msg| power=msg@1;}, '/variables/power');
OSCdef(\phase, { |msg|
	if (msg@1 == 0 and:{power==\true}) {
		Synth(\tick)
	}
}, '/variables/phase');



// ;;;;;;;;;
// spontaneous claxons :: mean waiting time
OSCdef(\mean_wait_time, {|msg|
	var current_wait = msg@1;

	if (current_wait > current_th_wait) {
		// randomly pick one traffic noise
		// claxon level related with number of stopped cars
		Synth(\traffic,[\bufnum,~traffic.choose,\level,percent]);
		current_th_wait=current_th_wait+th_wait;
	} {
		if (current_wait <= min_wait) {
			current_th_wait=th_wait;
		}
	}

}, '/variables/mean_wait_time');




// ;;;;;;;;;
// spontaneous claxons :: mean waiting time
OSCdef(\num_cars_stopped, {|msg|
	// netlogo counts and sends one by one the number of stopped cars
	// when it arrives to the actual number, resets the count
	// we want only to keep the maximum value every time

	last_cars_stopped = current_cars_stopped;
	current_cars_stopped = msg@1;


	if (current_cars_stopped >= last_cars_stopped) {
		// count increasing
		max_current_cars_stopped = current_cars_stopped;
	} {
		// count reset
		percent=(max_current_cars_stopped/numCars);
		~stop.set(\level,ControlSpec(0.0005, 1, \exp).map(percent));
	}
}, '/variables/num_cars_stopped');


)


