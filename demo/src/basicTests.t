#charset "us-ascii"
//
// basicTests.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" that illustrates the
// functionality of the notReallyRandom library
//
// It can be compiled via the included makefile with
//
//	# t3make -f basicTests.t3m
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
        name = 'notReallyRandom Library Demo Game'
        byline = 'Diegesis & Mimesis'
        desc = 'Demo game for the notReallyRandom library. '
        version = '1.0'
        IFID = '12345'
	showAbout() {
		"This is a simple test game that demonstrates the features
		of the notReallyRandom library.
		<.p>
		In-game that's pretty much all there is to it.  Consult the
		README.txt document distributed with the library source for
		a quick summary of how to use the library in your own games.
		<.p>
		The library source is also extensively commented in a way
		intended to make it as readable as possible. ";
	}
;
// Game world only contains the bare minimum required to successfully compile
// because we never reach a prompt in it.
gameMain:       GameMainDef
	_prngIdx = 0
	newGame() {
		runTests();
	}
	runTests() {
		local i;

		"<.p>Starting tests.<.p>";
		i = 0;
		if(!notReallyRandom.nrrReseedTest()) i += 1;
		if(!notReallyRandom.nrrXYTest()) i += 1;
		if(!notReallyRandom.nrrIdxTest()) i += 1;
		if(!notReallyRandom.nrrChiSquareTest(new XORshiftPRNG(nil, 0, 255)))
			i += 1;
		if(!notReallyRandom.nrrRunsTest(new XORshiftPRNG(nil, 0, 255)))
			i += 1;

		"<.p>Tests complete.<.p> ";
		if(i == 0) {
			"All tests passed.<.p> ";
		} else {
			"FAILED <<toString(i)>> test<<((i > 1) ? 's' : '')>>.<.p> ";
		}
	}
	showGoodbye() {}
;
