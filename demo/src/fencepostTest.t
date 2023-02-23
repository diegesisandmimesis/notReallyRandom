#charset "us-ascii"
//
// fencepostTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// Simple test to check for silly off-by-one errors in the PRNG code
// for generating values in an specified range.
//
// It can be compiled via the included makefile with
//
//	# t3make -f fencepostTest.t3m
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

versionInfo:    GameID;

gameMain:       GameMainDef
	newGame() { runTest(); }
	// Excessively simple test that generates values in the range [0, 1].
	// This is primarily useful for quickly identifying if an update has
	// done something particularly silly and introduced an off by one error
	// in PRNG range logic.
	runTest() {
		local t;

		t = new NotReallyRandomFencepostTest();
		if(t.runTest())
			"Fencepost test passed.\n ";
		else
			"Fencepost error.\n ";
	}
;
