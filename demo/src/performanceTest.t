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

// Class for both of our perf tests.  Entirely so we can twiddle the iterations
// in one place for both.
class PerfTest: NotReallyRandomPerfTest
	// We need a lot of interations, because T3's timestamp resolution
	// is small and random number generation is fast.
	iterations = 1000000
;

// Class for generating values via our PRNG.  We use the global randomInt()
// method (a macro) for convenience.
class PRNGTest: PerfTest
	svc = 'NotReallyRandom PRNG'
	pickOutcome() { return(randomInt(1, 10)); }
;

// Class for generating values via T3's native rand() implementation.
class RandTest: PerfTest
	svc = 'native rand()'
	pickOutcome() { return(rand(10) + 1); }
;

gameMain:       GameMainDef
	newGame() { runTests(); }
	runTests() {
		local r, t, t0, t1;

		t = new PRNGTest();
		t.runTest();
		t.report();
		t0 = t.getInterval();

		t = new RandTest();
		t.runTest();
		t.report();
		t1 = t.getInterval();

		// Ratio of the module's PRNG runtime to the native runtime.  We
		// should expect that the module's PRNG will always be slower.
		r = t0/t1;
		"<.p>PRNG slowdown factor of
			<<toString(r.roundToDecimal(3))>>\n ";
	}
;
