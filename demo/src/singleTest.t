#charset "us-ascii"
//
// singleTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" that illustrates the
// functionality of the notReallyRandom library
//
// It can be compiled via the included makefile with
//
//	# t3make -f singleTest.t3m
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
	// Excessively simple test that generates values in the range [0, 1].
	// This is primarily useful for quickly identifying if an update has
	// done something particularly silly and introduced an off by one error
	// in PRNG range logic.
	runTest() {
		local i, n, p, v;

		n = 100000;
		v = new Vector(2);
		v[1] = 0;
		v[2] = 0;
		p = new XORshiftPRNG();
		"<.p>Starting tests.<.p>";
		for(i = 0; i < n; i++) {
			v[p.random(0, 1) + 1] += 1;
		}
		"Zero:  <<toString(v[1])>>\n ";
		"One:  <<toString(v[2])>>\n ";
		"Total: <<toString(v[1] + v[2])>>\n ";
	}
;
