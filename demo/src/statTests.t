#charset "us-ascii"
//
// statTests.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" that illustrates the
// functionality of the notReallyRandom library
//
// It can be compiled via the included makefile with
//
//	# t3make -f statTests.t3m
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
	_prngIdx = 0
	newGame() {
		local d0;

		d0 = new Date();
		runTests();
		"<.p>Tests took <<toString(notReallyRandom.getInterval(d0))>>
			seconds.<.p> ";
	}
	runTests() {
		local i, n;

#ifdef __DEBUG_NOT_REALLY_RANDOM
		"Starting tests.\n ";
		i = 0;
		n = 0;
		if(!notReallyRandom.nrrReseedTest()) i += 1;
		n += 1;
		if(!notReallyRandom.nrrXYTest()) i += 1;
		n += 1;
		if(!notReallyRandom.nrrIdxTest()) i += 1;
		n += 1;
		if(!notReallyRandom.nrrChiSquareTest(
			new XORshiftPRNG(nil, 0, 255)))
			i += 1;
		n += 1;
		if(!notReallyRandom.nrrRunsTest(new XORshiftPRNG(nil, 0, 255)))
			i += 1;
		n += 1;

		"Ran <<toString(n)>> tests.\n ";
		if(i == 0) {
			"All tests passed.\n ";
		} else {
			"FAILED <<toString(i)>>
				test<<((i > 1) ? 's' : '')>>.\n ";
		}
#else // __DEBUG_NOT_REALLY_RANDOM
		// Complain if we were compiled without the test logic
		"Tests cannot be run because the notReallyRandom library was
			compiled without the __DEBUG_NOT_REALLY_RANDOM flag. ";
		"<.p> ";
#endif // __DEBUG_NOT_REALLY_RANDOM
	}
	showGoodbye() {}
;
