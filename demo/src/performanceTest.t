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
	showAbout() {
		"This is a simple test game intended to be used for performance
		testing the notReallyRandom library.
		<.p> ";
	}
;
// Game world only contains the bare minimum required to successfully compile
// because we never reach a prompt in it.
gameMain:       GameMainDef
	newGame() {
		runTests();
	}
	runTests() {
		local i, x;

		"<.p>Starting tests.<.p>";
		for(i = 0; i < 1000000; i++) {
			x = randomInt(0, 9);
		}
		if(!x) return;
		"<.p>Tests complete.<.p> ";
	}
	showGoodbye() {}
;
