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

#include "notReallyRandom.h"

versionInfo:    GameID
        name = 'notReallyRandom Library Performance Test Game'
        byline = 'Diegesis & Mimesis'
        desc = 'Performance test for the notReallyRandom library. '
        version = '1.0'
        IFID = '12345'
	// No ABOUT because we're not interactive
	showAbout() {}
;
// Game world only contains the bare minimum required to successfully compile
// because we never reach a prompt in it.
gameMain:       GameMainDef
	newGame() {
		runTests();
	}
	runTests() {
		local i, x;

		// This is pretty useless.
		// This entire "test" is really just here to be a template
		// to be edited and recompiled to compare options.
		// I.e.
		// 	# time emglken ./games/performanceTest.t3
		//	[some numbers]
		//	# vi src/performanceTest.t
		//	# t3make -a -d -f performanceTest.t3m
		// 	# time emglken ./games/performanceTest.t3
		//	[some different numbers]
		// ...and so on
		"<.p>Starting tests.<.p>";
		for(i = 0; i < 1000000; i++) {
			x = randomInt(0, 9);
		}
		if(!x) return;
		"<.p>Tests complete.<.p> ";
	}
	showGoodbye() {}
;
