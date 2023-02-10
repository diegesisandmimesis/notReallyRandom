#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>

#include "notReallyRandom.h"

// Debugging/testing logic.
// This is all wrapped in a big #ifdef to allow production code to be
// compiled without the testing stuff.
#ifdef __DEBUG_NOT_REALLY_RANDOM

#include <date.h>
#include <bignum.h>

// Convenience object included only when the debugging flag is set.
// start() saves the current time, getInterval() returns the number of
// seconds since start() was called, as a BigNumber.
notReallyRandomTimer: object
	_start = nil

	start() { _start = new Date(); }
	getInterval() { return((_start != nil)
		? ((new Date() - _start) * 86400)
		: nil); }
;

// Abstract class for our tests.
class NotReallyRandomTest: object
	svc = nil		// string prefix to use for debugging output
	prng = nil		// PRNG instance to test
	seed = nil		// saved copy of the seed we started with

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

	// Logging methods.
	_error(v) { "\n<<(svc ? '<<svc>>:' : '')>> <<v>>\n "; }
	_debug(v) {}

	// Stub method.  This is the entry point for external callers, needs
	// to be set to be something useful by subclasses/instances.
	runTest() {}
;

class NotReallyRandomRangeTest: NotReallyRandomTest
	svc = 'nrrRangeTest'

	runTest() {
		local err, i, min, max, n, v;

		err = new Vector(2);
		err.fillValue(0, 1, 2);
		n = 100000;
		for(i = 0; i < n; i++) {
			min = rand(100);
			max = rand(10000) + min + 1;
			v = prng.random(min, max);
			if(v < min) err[1] += 1;
			if(v > max) err[2] += 1;
		}
		_debug('generated <<toString(n)>> values'); 
		if((err[1] == 0) && (err[2] == 0)) {
			_debug('success');
			return(true);
		}
		_error('out of range low: <<toString(err[1])>>');
		_error('out of range high: <<toString(err[2])>>');
		_error('FAILED');
		return(nil);
	}
;

// Trivial test that seeds the PRNG, generates a bunch of values,
// then re-sets the seed to the original value, generates a bunch more
// values, and then compares the results.
// There is not situation in which this should ever fail, so if it
// does there be troubles ahead.
class NotReallyRandomReseedTest: NotReallyRandomTest
	svc = 'nrrReseedTest'

	runTest() {
		local err, foo, bar, i, n;

		// Number of values to generate per run
		n = 65535;
		_debug('running test with <<toString(n)>> values');

		_debug('using seed <<toString(seed)>>');

		foo = new Vector(n);
		bar = new Vector(n);
		prng.setSeed(seed);
		for(i = 0; i < n; i++) {
			foo += prng.random(1, 10);
		}
		prng.setSeed(seed);
		for(i = 0; i < n; i++) {
			bar += prng.random(1, 10);
		}
		err = 0;
		for(i = 1; i <= n; i++) {
			if(foo[i] != bar[i]) {
				_error('FAILURE: mismatch at <<toString(i)>>');
				err += 1;
			}
		}
		if(err == 0) {
			_debug('success');
			return(true);
		}
		return(nil);
	}
;

// Test generation of "positional" PRNG values.  In principle the
// positional PRNG should be no "worse" than the underlying base
// PRNG, so this is mostly to test for implemention errors in
// the positional-specific code.
class NotReallyRandomXYTest: NotReallyRandomTest
	svc = 'nrrXYTest'

	runTest() {
		local err, foo, bar, i, n, xs, ys;

		// Number of values to generate per run
		n = 65535;
		_debug('running test with <<toString(n)>> values');

		_debug('using seed <<toString(seed)>>');

		foo = new Vector(n);
		bar = new Vector(n);
		xs = new Vector(n);
		ys = new Vector(n);
		prng.setSeed(seed);
		for(i = 0; i < n; i++) {
			xs += rand(256);
			ys += rand(256);
			foo += prng.xy(xs[i + 1], ys[i + 1], 1, 10);
		}
		prng.setSeed(seed);
		for(i = 0; i < n; i++) {
			bar += prng.xy(xs[i + 1], ys[i + 1], 1, 10);
		}
		err = 0;
		for(i = 1; i <= n; i++) {
			if(foo[i] != bar[i]) {
				_error('FAILURE: mismatch at <<toString(i)>>');
				err += 1;
			}
		}
		if(err == 0) {
			_debug('success');
			return(true);
		}
		return(nil);
	}
;

// Test generation of "indexed" PRNG values.  In principle the
// indexed PRNG should be no "worse" than the underlying base
// PRNG, so this is mostly to test for implemention errors in
// the index-specific code.
class NotReallyRandomIdxTest: NotReallyRandomTest
	svc = 'nrrIdxTest'

	runTest() {
		local err, foo, bar, i, n, xs;

		// Number of values to generate per run
		n = 65535;
		_debug('running test with <<toString(n)>> values');

		if(seed == nil) seed = rand(n);
		_debug('using seed <<toString(seed)>>');

		foo = new Vector(n);
		bar = new Vector(n);
		xs = new Vector(n);
		prng.setSeed(seed);
		for(i = 0; i < n; i++) {
			xs += rand(256);
			foo += prng.idx(xs[i + 1], 1, 10);
		}
		prng.setSeed(seed);
		for(i = 0; i < n; i++) {
			bar += prng.idx(xs[i + 1], 1, 10);
		}
		err = 0;
		for(i = 1; i <= n; i++) {
			if(foo[i] != bar[i]) {
				_error('FAILURE: mismatch at <<toString(i)>>');
				err += 1;
			}
		}
		if(err == 0) {
			_debug('success');
			return(true);
		}
		return(nil);
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
class NotReallyRandomChiSquareTest: NotReallyRandomTest
	svc = 'nrrChiSquareTest'
	_chiSquareRangeMax = nil

	runTest() {
		local chi, n, r, v;

		// Number of values to generate
		n = 65536;
		// Generate values in the range 1 through this
		_chiSquareRangeMax = 255;

		_debug('running test with <<toString(n)>> values');

		_debug('using seed <<toString(prng.getSeed())>>');

		_debug('using values <<toString(prng._min)>> -
			<<toString(prng._max)>>');
		chi = new NotReallyRandomChiSquareWidget(prng, n);
		v = chi.runTest();

		_debug('chi square value = <<toString(v)>>');
		_debug('critical = <<chi.checkCritical(v)>>');

		r = nil;
		if(chi.success()) {
			_debug('success');
			r = true;
		} else {
			_error('FAILED');
		}
		_debug('done');

		return(r);
	}
;

// Run a Wald-Wolfowitz runs test
// This is a very basic test of the independence of successive
// PRNG values.
class NotReallyRandomRunsTest: NotReallyRandomTest
	svc = 'nrrRunsTest'

	runTest() {
		local runs, n, r, z;

		// Number of values to generate
		n = 65536;
		_debug('running test with <<toString(n)>> values');

		_debug('using seed <<toString(prng.getSeed())>>');
		runs = new NotReallyRandomRunsWidget(prng, n);

		r = nil;
		z = runs.runTest();
		if(z) {
			_debug('Z = <<toString(z)>>');
			_debug('mean = <<toString(runs.mean())>>');
			_debug('variance = <<toString(runs.variance())>>');
			if(z <= runs.getCritical()) {
				_debug('success');
				r = true;
			} else {
				_error('FAILURE');
			}
		} else {
			_error('ERROR:  Failed to compute Z value');
		}

		_debug('done');
		return(r);
	}
;

// A domain-specific Chi-square test.
// Usage:
//
//	// Create a new Chi-square test.  Args are a NotReallyRandomPRNG
//	// instance and the number of values to generate for the test.
//	chi = new NotReallyRandomChiSquareWidget(prng, n);
//
//	// Actually run the test, returning the chi value
//	v = chi.runTest();
//
//	// Return the significance level of the chi value.  This will
//	// be a string containing the level (hopefully "0.001") or "FAILED".
//	// Note that it's always a string, even if the string is decimal
//	// number;  we only care about displaying it as part of a test result,
//	// so we don't bother with a BigNumber or whatever.
//	r = chi.checkCritical(v);
//
// Implementation notes:
//	We always try to use a range of values that's a multiple of 64, so we
//	can use 64 buckets (and add values to them by a simple idx = (v % 64)),
//	and we don't need to know critical values for anything other
//	than n = 64
//
class NotReallyRandomChiSquareWidget: object
	_total = nil		// accumulator for the chi-square value
	_buckets = nil		// list to hold the frequency counts
	_ev = nil		// expectation value of an individual bucket
	_n = nil		// number of values we've generated

	_prng = nil		// the PRNG we're evaluating
	_count = nil		// the number of values we need to generate

	_success = nil		// status of test

	// Critical values for n = 64
	_critical = static [
		'0.001' -> new BigNumber(34.633),
		'0.01' -> new BigNumber(40.649),
		'0.025' -> new BigNumber(43.776),
		'0.05' -> new BigNumber(46.595),
		'0.10' -> new BigNumber(49.996)
	]

	// Args are:
	//	prng	PRNG to generate random values
	//	n	number of tests to run
	//	maxVal	create buckets for values from 1 to maxVal
	//
	// NOTE:  We require maxVal to be a multiple of 64, so we can use
	// 64 buckets and we don't need to know critical values for anything
	// other than n = 64.
	construct(prng, n) {
		local range;

		_prng = prng;
		_count = n;

		// Get the range of values produced by the PRNG
		range = prng._max - prng._min + 1;

		if(range % 64) {
			"NotReallyRandomChiSquare:  ERROR:  range is not a
				multiple of 64.\n ";
			"   THIS WILL CAUSE THE TEST TO FAIL.\n ";
			exit;
		}
		if(range > 64)
			range = 64;

		// Create a list as long as the range of values and
		// initialize each element to zero
		//_buckets = makeList(0, range);
		_buckets = new Vector(range);
		_buckets.fillValue(0, 1, range);

		// Figure out what the expectation value of each bucket
		// is.  Since the PRNG should output each integer in its
		// range with the same probability, this is just the
		// inverse of the range.
		_ev = new BigNumber(1) / new BigNumber(range);

		// Initialize the counter that will keep track of how many
		// values we've generated.
		_n = 0;
	}

	// Entry point for callers.
	// This is where we actually run the test.
	runTest() {
		local i;

		// Generate however many values we were told to use,
		// calling the PRNG's random() method to get each one.
		for(i = 0; i < _count; i++) {
			addData(_prng.random());
		}

		// Return the resulting chi value
		return(chiSquare());
	}

	// Add a single value to our test
	addData(v) {
		local idx;

		// Bail if we haven't be initialized properly
		if(_buckets == nil) return(nil);

		// We insist that the output range of the PRNG is a multiple
		// of the number of buckets, so taking the value mod the
		// number of buckets shouldn't affect our distribution.
		// We have to add one because TADS indexes from the 1st, not
		// the 0th, element.
		idx = (toInteger(v) % _buckets.length) + 1;

		// Count this value
		_buckets[idx] += 1;
		// Increase the counter for the number of values
		_n += 1;

		return(true);
	}
	chiSquare() {
		local delta, i;

		// Bail if we haven't been initialized
		if(_ev == nil || _buckets == nil) return(nil);
		// Bail if we haven't run any tests
		if(_n == 0) return(nil);

		// Initialize our sum to zero
		_total = new BigNumber(0);

		// We initialize the expectation value to be the inverse of
		// the number of buckets, which is the expectation value per
		// trial.  To get the expectation value for this test we
		// multiply this by the number of trials.
		_ev *= new BigNumber(_n);

		// The "meat" of the chi-square test.
		// Delta is the difference between the observed value and
		// the expectation value.  We keep a running total of
		// (the square of each delta divided by the expectation value).
		for(i = 1; i <= _buckets.length; i++) {
			delta = new BigNumber(_buckets[i]) - _ev;
			_total += (delta * delta) / _ev;
		}

		// Return the square root of the sum.
		return(_total.sqrt());
	}

	// Return the highest significance matching the chi value, or
	// "FAILURE" if we fall off the end without matching any.
	checkCritical(chi) {
		local r;

		r = nil;
		_success = nil;
		_critical.forEachAssoc(function(k, v) {
			if(r != nil) return;
			if(chi < v) {
				r = k;
				_success = true;
			}
		});
		if(!r) r = 'FAILURE';
		return(r);
	}
	success() { return(_success); }
;


// Implements a Wald-Wolfowitz runs test
// Usage:
//
//	// Create a new runs test.  Args are a NotReallyRandomPRNG
//	// instance and the number of values to generate for the test.
//	test = new NotReallyRandomRunsWidget(prng, n);
//
//	// Actually run the test, returning the Z value
//	z = test.runTest();
//
//	// Compare the computed Z value to the critical value.
//	if(z <= test.getCritical()) {
//		// success
//	} else {
//		// failure
//	}
class NotReallyRandomRunsWidget: object
	_prng = nil		// the PRNG we're evaluating
	_count = nil		// the number of values we need to generate

	_nUp = nil		// number of "up" runs
	_nDown = nil		// number of "down" runs
	_n = nil		// total number of runs
	_ev = nil		// computed expectation value
	_variance = nil		// computed variance
	_critical = static new BigNumber(1.96)

	// Args are:
	//	prng	PRNG to generate random values
	//	n	number of tests to run
	construct(prng, n) {
		_prng = prng;
		_count = n;

		_n = 0;
	}

	// Entry point for callers.
	// This is where we actually run the test.
	runTest() {
		local dir, i, lst, s, v, w;

		// Initialize our counters
		_nUp = 0;
		_nDown = 0;

		// Generate however many values we were told to use,
		// calling the PRNG's random() method to get each one.
		w = nil;
		dir = nil;
		lst = nil;
		for(i = 0; i < _count; i++) {
			// Generate a new value
			v = _prng.random();

			// Check to see if this is the first time through
			// the loop.
			if(w == nil) {
				w = v;
				continue;
			}

			// See if the new value is greater or less
			// than the last value.  We define
			// a "direction" for the new value, boolean
			// true if it's greater than the last value,
			// nil if it's less.
			dir = ((v >= w) ? 1 : -1);

			if(dir > 0) {
				_nUp += 1;
			} else {
				_nDown += 1;
			}

			if((lst != nil) && (lst != dir))
				_n += 1;

			// Remember the current "direction"
			lst = dir;

			// Remember the current value
			w = v;
		}

		s = variance();
		if(!s) return(0);

		return(((new BigNumber(_n) - mean()) / s).getAbs());
	}
	mean() {
		if(!_n) return(0);
		if(_ev == nil)
			_ev = ((new BigNumber(2) * new BigNumber(_nUp)
				* new BigNumber(_nDown))
				/ new BigNumber(_n)) + new BigNumber(1);
		return(_ev);
	}
	variance() {
		local ev;

		ev = mean();
		if(!ev) return(0);
		if(_variance == nil) {
			_variance = ((ev - new BigNumber(1))
				* (ev - new BigNumber(2)))
				/ (new BigNumber(_n) - new BigNumber(1));
		}
		return(_variance);
	}
	getCritical() {
		return(_critical);
	}
;

#ifdef __DEBUG_NOT_REALLY_RANDOM_VERBOSE

modify NotReallyRandomTest
	_debug(v) { "\n<<(svc ? '<<svc>>:' : '')>> <<v>>\n "; }
;

#endif // __DEBUG_NOT_REALLY_RANDOM_VERBOSE

#endif // __DEBUG_NOT_REALLY_RANDOM
