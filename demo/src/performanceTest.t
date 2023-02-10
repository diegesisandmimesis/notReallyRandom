#charset "us-ascii"
//
// performanceTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a simple demonstration "game" that intended to be usable
// as a platform for performance testing changes to the PRNG
// logic.
//
// It can be compiled via the included makefile with
//
//	# t3make -f performanceTest.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include <date.h>

#include "notReallyRandom.h"

versionInfo:    GameID;

gameMain:       GameMainDef
	runs = 1000000

	newGame() {
		runTests();
	}
	runTests() {
		local i, x;

		// This is pretty useless.
		// This entire "test" is really just here to be a template
		// to be edited and recompiled to compare the performance
		// of different modifications.
		notReallyRandomTimer.start();
		"<.p>Generating <<toString(runs)>> random integers.\n ";
		for(i = 0; i < runs; i++) {
			x = randomInt(0, 9);
		}
		if(x) {}
		"Done.<.p> ";
		"Test took <<toString(notReallyRandomTimer.getInterval())>>
			seconds.<.p> ";
	}
	showGoodbye() {}
;
