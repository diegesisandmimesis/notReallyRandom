#charset "us-ascii"
//
// rangeTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// Test case to evaluate if the PRNG logic for generating values in
// a specified range is generating values outside the range.
//
// It can be compiled via the included makefile with
//
//	# t3make -f rangeTest.t3m
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
	newGame() {
		runTest();
	}
	// Simple test to make sure we're not generating values outside
	// the allowed range.
	runTest() {
		local t;

		t = new NotReallyRandomRangeTest();
		t.runTest();
		t.report();
	}
;
