#charset "us-ascii"
//
// rangeTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" that illustrates the
// functionality of the notReallyRandom library
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
		local w;

		w = new NotReallyRandomRangeTest();
		if(w.runTest()) "Range test passed.\n ";
/*
		local eLow, eHigh, i, min, max, n, p, v;

		eLow = 0;
		eHigh = 0;
		n = 100000;
		p = new XORshiftPRNG();
		"Starting test.\n ";
		for(i = 0; i < n; i++) {
			min = rand(100);
			max = rand(10000) + min + 1;
			v = p.random(min, max);
			if(v < min) eLow += 1;
			if(v > max) eHigh += 1;
		}
		"Generated <<toString(n)>> random integers.\n ";
		if((eLow == 0) && (eHigh == 0)) {
			"Test success.\n ";
			"No out of range values generated.\n ";
		} else {
			"TEST FAILED.\n ";
			"Out of range low:  <<toString(eLow)>>\n ";
			"Out of range high:  <<toString(eHigh)>>\n ";
		}
*/
	}
;
