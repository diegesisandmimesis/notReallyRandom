#charset "us-ascii"
//
// statTests.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a non-interactive suite of randomness tests run against the
// PRNG implemented by the notReallyRandom module.
//
// It can be compiled via the included makefile with
//
//	# t3make -f statTests.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// Include the -D __DEBUG_NOT_REALLY_RANDOM_VERBOSE flag in the compile
// command line or makefile to enable chatty debugging information from
// the individual tests.
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
	testList = [
		new NotReallyRandomReseedTest(),
		new NotReallyRandomXYTest(),
		new NotReallyRandomIdxTest(),
		new NotReallyRandomChiSquareTest(nil, nil, 0, 255),
		new NotReallyRandomRunsTest(nil, nil, 0, 255)
	]
	_prngIdx = 0
	newGame() {
		runTests();
	}
	runTests() {
		local err, t;

		err = 0;
		t = 0;
		
		notReallyRandomTimer.start();
		testList.forEach(function(o) {
			t += 1;
			if(!o.runTest()) err += 1;
		});

		"Completed <<toString(t)>> tests in
			<<toString(notReallyRandomTimer.getInterval()
			.roundToDecimal(3))>>
			seconds.\n ";
		if(err == 0) {
			"All tests passed.\n ";
		} else {
			"FAILED <<toString(err)>>
				test<<((err > 1) ? 's' : '')>>.\n ";
		}
	}
;
