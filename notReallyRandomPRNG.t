#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

#include "notReallyRandom.h"

// Instantiable non-cryptographic PRNG(s) for TADS3.
//
// For most "normal" random number generation purposes you probably just
// want to use the native tads-gen rand() function.  It's faster, and
// probably produces slightly better-quality pseudo-random numbers.
//
// This stuff in this library is really only for when you want to be able
// to create multiple PRNG instances and have them "step" separately.  This
// is useful if you have some widget/NPC/whatever that you want to have
// random-ish behavior, but you want to be able to re-set that behavior and
// have it play out the same way again.
//
// WARNING:
//	This code is suitable ONLY for non-competitive game use.
//	Numerous shortcuts and workarounds are used to improve performance
//	and to work around inherent limitations in TADS3 (like the lack of
//	unsigned integer mathematics).
//
//	THIS CODE SHOULD NOT BE USED FOR CRYPTOGRAPHIC OR OTHER SECURE
//	APPLICATIONS.

// Base class for our PRNGs
class NotReallyRandomPRNG: object
	_seed = nil			// seed value for PRNG

	// These control the output range of the PRNG
	_min = 0			// min value output by PRNG
	_max = 2147483647		// max value output by PRNG

	// These control the maximum size of integers handled internally
	// by the PRNG.
	// You generally shouldn't have to fiddle with this;  we assume
	// that we're always using 32 bit signed integers, because that's
	// what TADS does by default.
	_bigInt = 2147483647		// max integer value handled by PRNG
	_bigIntBigNum = nil		// BigNumber of _bigInt

	construct(seed?, min?, max?) {
		if(min != nil) _min = min;
		if(max != nil) _max = max;
		if(seed != nil) _seed = seed;
	}

	// Pick a random seed for the PRNG
	initSeed() { _seed = rand(_max); }

	// Returns 
	maxBigNum() {
		if(_bigIntBigNum == nil) _bigIntBigNum = new BigNumber(_bigInt);
		return(_bigIntBigNum);
	}

	// Returns the current seed, initializing it if necessary
	getSeed() { if(_seed == nil) initSeed(); return(_seed); }

	// Manually set a seed
	setSeed(v) { _seed = v; }

	// Bounds check the argument.
	// This is basically just a kludge to work around the fact that
	// TADS doesn't support any unsigned integer types.  Here we just
	// check if the value is negative and return the arg's bitwise negation
	// if it is.
	fixValue(v) {
		if(v < 0) v = ~v;
		return(v);
	}

	// Convert an integer into a fraction of our integer size, returning
	// a BigNumber.
	// So if our PRNG generates 1234567890 and our max integer is
	// 2147483647, this would return 0.57489(...).
	toFraction(v) {
		return(new BigNumber(fixValue(v)) / maxBigNum());
	}

	// Just a convenience method.
	// Convert the value to an integer between min and max (inclusive).
	toRange(v, min, max) {
		min = (min ? min : 0);
		max = (max ? max : _bigInt);
		//return(fix(toFraction(v), min, max));
		// Total kludge, unsafe, but good enough for use in
		// games not involving money.  To insure our return values
		// are actually uniform we should do something like the
		// line commented out above, which converts the value into
		// a decimal fraction of the max integer value generated by
		// the PRNG and then maps that fraction to a value in the
		// given integer range.  That's more than an order of
		// magnitude slower than the below, so we do the below instead.
		return((fixValue(v) % (max - min + 1)) + min);
	}

	// This is the method by which we access the PRNG.  This is an
	// abstract class so we don't implement an actual PRNG here, but
	// all the derived classes need to do something useful here.
	nextValue(seed?) {
		return(0);
	}

	// random() is the base number generation method.  Args are:
	// 	min	Minimum value returned
	//	max	Maximum value returned
	//	seed	Seed value to use for the PRNG
	random(min?, max?, seed?) {
		return(toRange(nextValue(seed), min, max));
	}

	// idx() returns a pseudorandom value that (deterministically)
	// depends not only on the seed (if given, the PRNG's current seed
	// otherwise) but also on the passed index value.
	idx(x, min?, max?, seed?) {
		return(toRange(x ^ nextValue(seed), min, max));
	}

	// xy() returns a pseudorandom value that (deterministically)
	// depends not only on the seed value but also on the passed
	// x and y values.
	xy(x, y, min?, max?, seed?) {
		return(toRange(x ^ y ^ nextValue(seed), min, max));
	}

	// fix() returns an integer in the range [min - max], given a
	// BigNumber v.
	// Internally, TADS3 uses 32 bit signed integers.  The PRNG(s) generate
	// 
	fix(v, min?, max?) {
		local r;

		if(min == nil)
			min = _min;
		if(max == nil)
			max = _max;
		r = v * new BigNumber(max - min + 1);
		return(r.getFloor() + min);
	}

	// Stub methods to make it easier to include the debugging routines
	// in games without having them barf when compiled without the
	// debugging flag.
	nrrReseedTest() {}
	nrrXYTest() {}
	nrrIdxTest() {}
	nrrChiSquareTest() {}
;

// TADS3 implementation of Marsaglia's xorshift
class XORshiftPRNG: NotReallyRandomPRNG
	nextValue(seed?) {
		local v;

		// If we were passed a seed, we use it.  Otherwise we
		// call getSeed(), which will initialize us up a seed or
		// use an existing one, as appropriate.
		if(seed != nil) v = seed;
		else v = getSeed();

		// If v is zero then all our shifts will just produce another
		// zero, so we avoid doing that.
		if(v == 0) v = 1;

		// Just a standard set of values for xorshift.
		v ^= v << 13;
		v ^= v >> 17;
		v ^= v << 5;

		// Kludge for the fact we can't use unsigned integers
		if(v < 0) v = ~v;

		// If we *weren't* passed a seed, we save the current
		// value as the seed, to advance the prng.  If we were
		// passed a seed then we leave the prng state the way it
		// was.
		if(seed == nil) setSeed(v);

		return(v);
	}
;

// This is how we assign a global default PRNG.  We can still create
// other PRNG instances if we want, but this is the one that gets pointed
// to by all of the #defines in notReallyRandom.h.
class NotReallyRandom: XORshiftPRNG;
notReallyRandom: NotReallyRandom;
