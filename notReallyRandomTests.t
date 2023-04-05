#charset "us-ascii"
//
// notReallyRandomTests.t
//
#include <adv3.h>
#include <en_us.h>

#include "notReallyRandom.h"

// Debugging/testing logic.
// This is all wrapped in a big #ifdef to allow production code to be
// compiled without the testing stuff.
#ifdef NOT_REALLY_RANDOM_TESTS

#include <date.h>
#include <bignum.h>

// Base class for our tests.  We build off the StatTest module's base class.
class NotReallyRandomTest: StatTest
	svc = 'NotReallyRandomTest'

	prng = nil			// PRNG instance we're testing
	seed = nil			// saved copy of seed we started with

	// Args are:
	//	p	PRNG instance
	//	s	seed
	//	mn	minimum value for PRNG output (not used if p is non-nil)
	//	mx	max value for PRNG output (not used if p is non-nil)
	//	n	int range for seed (not used if seed is non-nil)
	construct(p?, s?, mn?, mx?, n?) {
		n = ((n != nil) ? n : 65535);
		seed = ((s != nil) ? s : rand(n));
		prng = (p ? p : new XORshiftPRNG(seed, mn, mx));
	}
;

// The random() method accepts a min and max value as arguments.  Here
// we just validate that the PRNG doesn't return values outside the
// requested interval.
// We generate random bounds for each pass, so we have to do a little
// juggling to convert our results
class NotReallyRandomRangeTest: NotReallyRandomTest, StatTestFencepost
	// Our valid outcomes are 1 and 2.
	outcomes = static [ 1, 2 ]

	// Tell the test to figure out what the range of values is and
	// keep track of values that fail out of range low and out of
	// range high.
	useRange = true

	pickOutcome() {
		local min, max, v;

		// Pick random bounds.
		min = rand(100);
		max = rand(10000) + min + 1;

		// Select a number from the random interval.
		v = prng.random(min, max);

		// If we got value below the min, return an invalid low value.
		if(v < min) return(0);

		// If we got a value above the max, return an invalid high
		// value.
		if(v > max) return(3);

		// Convert our random value into a coin toss, returning 1
		// if our value is in the lower half of the range, 2 otherwise.
		return((v <= ((max + min) / 2)) ? 1 : 2);
	}
;

// Trivial test that seeds the PRNG, generates a bunch of values,
// then re-sets the seed to the original value, generates a bunch more
// values, and then compares the results.
// There is not situation in which this should ever fail, so if it
// does there be troubles ahead.
class NotReallyRandomReseedTest: NotReallyRandomTest
	svc = 'NotReallyRandomReseedTest'

	_v0 = nil
	_v1 = nil

	// We replace the whole runTest() method because our methodology
	// doesn't really follow the general stat test model here.
	runTest() {
		local i;

		initTest();

		_debug('using seed <<toString(seed)>>');

		// Initialize our results vectors.
		_v0 = new Vector(iterations);
		_v1 = new Vector(iterations);

		// Set the seed and then pick a bunch of random
		// numbers.
		prng.setSeed(seed);
		for(i = 0; i < iterations; i++)
			_v0.append(prng.random(1, 10));

		// Re-set the seed to the original value and then
		// pick a bunch of random numbers again.
		prng.setSeed(seed);
		for(i = 0; i < iterations; i++)
			_v1.append(prng.random(1, 10));
	}

	report() {
		local err, i;

		// We start out with zero errors.
		err = 0;

		// Go through our result vectors and verify that we got
		// the same values before and after re-seeding.
		for(i = 1; i <= iterations; i++) {
			if(_v0[i] != _v1[i]) {
				_error('ERROR:  mismatch at index
					<<toString(i)>>, <<toString(_v0[i])>>
					!= <<toString(_v1[i])>>');
				err += 1;
			}
		}
		if(err == 0) {
			_debug('matched all <<toString(iterations)>> values');
			_debug('passed');
			return;
		}
		_error('mismatch in <<toString(err)>> of
			<<toString(iterations)>> values');
		_error('FAILED');
	}
;

// Test generation of "positional" PRNG values.  In principle the
// positional PRNG should be no worse than the underlying base
// PRNG, so this is mostly to test for implemention errors in
// the positional-specific code.
// We use the NotReallyRandomReseedTest as a base so we don't have to
// re-declare most of the methods or properties.
class NotReallyRandomXYTest: NotReallyRandomReseedTest
	svc = 'NotReallyRandomXYTest'

	// We replace runTest() again because we're not doing a standard
	// stat test.
	runTests() {
		local i, xs, ys;

		initTest();

		_debug('using seed <<toString(seed)>>');

		// Create our results vectors.
		_v0 = new Vector(iterations);
		_v1 = new Vector(iterations);

		// Vectors to hold random x and y values we'll use
		// as inputs for the PRNG positional queries.
		xs = new Vector(iterations);
		ys = new Vector(iterations);

		// Set the PRNG seed.
		prng.setSeed(seed);

		for(i = 1; i <= iterations; i++) {
			// Add a random x and y value.
			xs.append(rand(256));
			ys.append(rand(256));

			// Pick and remember a number in the range [ 1, 10 ]
			// using the x and y value we just generated as a
			// positional seed.
			_v0.append(prng.xy(xs[i], ys[i], 1, 10));
		}

		// Re-seed the PRNG to the same seed we started with above.
		prng.setSeed(seed);

		// Repeat what we did above.
		for(i = 1; i <= iterations; i++)
			_v1.append(prng.xy(xs[i], ys[i], 1, 10));
	}
;

// Test generation of "indexed" PRNG values.  In principle the
// indexed PRNG should be no worse than the underlying base
// PRNG, so this is mostly to test for implemention errors in
// the index-specific code.
class NotReallyRandomIdxTest: NotReallyRandomReseedTest
	svc = 'NotReallyRandomIdxTest'

	// We replace runTest() again because we're not doing a standard
	// stat test.
	runTests() {
		local i, idxs;

		initTest();

		_debug('using seed <<toString(seed)>>');

		// Create our results vectors.
		_v0 = new Vector(iterations);
		_v1 = new Vector(iterations);

		// Vector to hold random index values to be used for
		// inputs by the PRNG.
		idxs = new Vector(iterations);

		// Set the PRNG seed.
		prng.setSeed(seed);

		for(i = 1; i <= iterations; i++) {
			// Add a random index value.
			idxs.append(rand(256));

			// Pick and remember a number in the range [ 1, 10 ]
			// using the index value we just generated as a
			// positional seed.
			_v0.append(prng.idx(idxs[i], 1, 10));
		}

		// Re-seed the PRNG to the same seed we started with above.
		prng.setSeed(seed);

		// Repeat what we did above.
		for(i = 1; i <= iterations; i++)
			_v1.append(prng.idx(idxs[i], 1, 10));
	}
;

// Run a Chi-square test.  
// This is NOT a rigorous test for randomness.  All it evaluates (in
// this case) is how flat a histogram of the values generated by PRNG
// is--that is, we assume that an ideal randomness source produces each
// value in its range with equal probability, and we compare the
// subject PRNG to this distribution.
// Even a very bad PRNG will pass this test (just enumerating the
// integers mod the max value will pass, for example), so this is
// mostly to catch gross implementation errors of various sorts;  it
// isn't a meaningful evaluation of the quality of the PRNG.
class NotReallyRandomChiSquareTest: NotReallyRandomTest, StatTestChiSquare
	svc = 'NotReallyRandomChiSquareTest'
	outcomes = perInstance(List.generate({ i : i }, 64))
	pickOutcome() { return(prng.random(1, 64)); }
;

// Run a Wald-Wolfowitz runs test
// This is a very basic test of the independence of successive
// PRNG values.
class NotReallyRandomRunsTest: NotReallyRandomTest, StatTestRuns
	svc = 'NotReallyRandomRunsTest'
	outcomes = perInstance(List.generate({ i : i }, 64))
	pickOutcome() { return(prng.random(1, 64)); }
;

class NotReallyRandomPerfTest: NotReallyRandomTest
	svc = 'NotReallyRandomPerfTest'
	runTest() {
		local i;

		initTest();
		startTimestamp();
		for(i = 0; i < iterations; i++)
			pickOutcome();
	}
	report() {
		_debug('running <<toString(iterations)>> iterations
			took <<toString(getInterval().roundToDecimal(3))>>
			seconds.');
	}
;

#endif // NOT_REALLY_RANDOM_TESTS
