#charset "us-ascii"
//
// notReallyRandomPRNG.t
//
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

	// This is the method by which we access the PRNG.  This is an
	// abstract class so we don't implement an actual PRNG here, but
	// all the derived classes need to do something useful here.
	nextValue(seed?) {
		return(0);
	}

	// Generate a random-ish number in the given range.
	_random(rng?, seed?) {
		local n, r, v;

		// Handle the case where the range is the full range
		// we generate in.
		if(rng == _bigInt) {
			v = nextValue(seed);

			// When we're out of range we just chuck the value
			// and grab the next, because anything we'd do to
			// munge the value into range would skew the histogram.
			while((v < 0) || (v > _bigInt))
				v = nextValue();

			return(v);
		} else {
			// Figure out how many of our ranges fit inside the
			// maximum integer range.
			r = _bigInt / rng;

			// The size of the above times our range.  If the
			// number we pick is less than or equal to this, then
			// we can safely convert it to a number inside our
			// desired range without skewing the results.
			n = rng * r;

			// Keep picking values until we get one in our range.
			v = nextValue(seed);
			while((v < 0) || (v >= n))
				v = nextValue();

			return(v % rng);
		}
	}

	// random() is the base number generation method.  Args are:
	// 	min	Minimum value returned
	//	max	Maximum value returned
	//	seed	Seed value to use for the PRNG
	random(min?, max?, seed?) {
		return(_random(max - min + 1, seed) + min);
	}

	// idx() returns a pseudorandom value that (deterministically)
	// depends not only on the seed (if given, the PRNG's current seed
	// otherwise) but also on the passed index value.
	// Most of the logic is almost identical to the logic of random()
	// above, but all the differences are in the loop, so we avoid
	// calling methods or doing conditionals to improve performance.
	idx(x, min?, max?, seed?) {
		local n, r, range, v;

		if((min == nil) || (min < 0)) min = 0;
		if((max == nil) || (max > _bigInt)) max = _bigInt;

		if((min == 0) && (max == _bigInt)) {
			v = nextValue(seed) ^ nextValue(x);
			while((v < 0) || (v > _bigInt))
				v = nextValue() ^ nextValue(x);
			return(v);
		} else {
			range = max - min + 1;
			r = _bigInt / range;
			n = range * r;
			v = nextValue(seed) ^ nextValue(x);
			while((v < 0) || (v >= n))
				v = nextValue() ^ nextValue(x);
			return((v % range) + min);
		}
	}

	// xy() returns a pseudorandom value that (deterministically)
	// depends not only on the seed value but also on the passed
	// x and y values.
	// As with the idx() method above, this mostly duplicates logic
	// from random() but we deal with that via duplicating the code
	// for better performance.
	xy(x, y, min?, max?, seed?) {
		local n, r, range, v;

		if((min == nil) || (min < 0)) min = 0;
		if((max == nil) || (max > _bigInt)) max = _bigInt;

		if((min == 0) && (max == _bigInt)) {
			v = nextValue(seed) ^ nextValue(x) ^ nextValue(y);
			while((v < 0) || (v > _bigInt))
				v = nextValue() ^ nextValue(x) ^ nextValue(y);
			return(v);
		} else {
			range = max - min + 1;
			r = _bigInt / range;
			n = range * r;
			v = nextValue(seed) ^ nextValue(x) ^ nextValue(y);
			while((v < 0) || (v >= n))
				v = nextValue() ^ nextValue(x) ^ nextValue(y);
			return((v % range) + min);
		}
	}

	// fix() returns an integer in the range [min - max], given a
	// BigNumber v.
	fix(v, min?, max?) {
		local r;

		if(min == nil)
			min = _min;
		if(max == nil)
			max = _max;
		r = v * new BigNumber(max - min + 1);
		return(r.getFloor() + min);
	}
;

// TADS3 implementation of Marsaglia's xorshift
class XORshiftPRNG: NotReallyRandomPRNG
	nextValue(seed?) {
		local v;

		// If we were passed a seed, we use it.  Otherwise we
		// call getSeed(), which will initialize us up a seed or
		// use an existing one, as appropriate.
		v = ((seed != nil) ? seed : getSeed());

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

// TADS3 implementation of xxHash
class XXHashPRNG: NotReallyRandomPRNG
	// _pr = static [ 2654435761, 2246822519, 3266489917, 668265263
	//	374761393 ]
	_pr = static [
		[ 40503, 31153 ],
		[ 34283, 51831 ],
		[ 49842, 44605 ],
		[ 10196, 60207 ],
		[  5718, 26545 ]
	]

	nextValue(seed?) {
		local a00, a16, b00, b16, c00, c16, lo, hi, s, v;

		s = 1;
		if(s == 1)
			throw new Exception('The XXHashPRNG implementation is
				not ready for use');

		s = ((seed != nil) ? seed : getSeed());

		lo = s & 0xffff;
		hi = s >> 16;

		b00 = _pr[2][1];
		b16 = _pr[2][2];

		c00 = lo * b00;
		c16 = c00 >> 16;

		c16 += hi * b00;
		c16 &= 0xffff;
		c16 += lo * b16;

		a00 = lo + (c00 & 0xffff);
		a16 = a00 >>> 16;

		a16 += hi + (c16 & 0xffff);

		v = (a16 << 16) | (a00 & 0xffff);
		v = (v << 13) | (v >> 19);

		a00 = v & 0xffff;
		a16 = v >>> 16;

		b00 = _pr[1][1];
		b16 = _pr[1][2];

		c00 = a00 * b00;
		c16 = c00 >>> 16;

		c16 += a16 * b00;
		if(c16 < 0) c16 = ~c16;
		c16 &= 0xffff;
		c16 += a00 * b16;

		c16 &= 0xffff;
		v = c16 << 16;
		v = v | c00;

		if(seed == nil) setSeed(toInteger(v, 16));

		return(v);
	}
;

class PearsonHashPRNG: NotReallyRandomPRNG
	_table = static [
		0x01, 0x57, 0x31, 0x0c, 0xb0, 0xb2, 0x66, 0xa6,
		0x79, 0xc1, 0x06, 0x54, 0xf9, 0xe6, 0x2c, 0xa3,
		0x0e, 0xc5, 0xd5, 0xb5, 0xa1, 0x55, 0xda, 0x50,
		0x40, 0xef, 0x18, 0xe2, 0xec, 0x8e, 0x26, 0xc8,
		0x6e, 0xb1, 0x68, 0x67, 0x8d, 0xfd, 0xff, 0x32,
		0x4d, 0x65, 0x51, 0x12, 0x2d, 0x60, 0x1f, 0xde,
		0x19, 0x6b, 0xbe, 0x46, 0x56, 0xed, 0xf0, 0x22,
		0x48, 0xf2, 0x14, 0xd6, 0xf4, 0xe3, 0x95, 0xeb,
		0x61, 0xea, 0x39, 0x16, 0x3c, 0xfa, 0x52, 0xaf,
		0xd0, 0x05, 0x7f, 0xc7, 0x6f, 0x3e, 0x87, 0xf8,
		0xae, 0xa9, 0xd3, 0x3a, 0x42, 0x9a, 0x6a, 0xc3,
		0xf5, 0xab, 0x11, 0xbb, 0xb6, 0xb3, 0x00, 0xf3,
		0x84, 0x38, 0x94, 0x4b, 0x80, 0x85, 0x9e, 0x64,
		0x82, 0x7e, 0x5b, 0x0d, 0x99, 0xf6, 0xd8, 0xdb,
		0x77, 0x44, 0xdf, 0x4e, 0x53, 0x58, 0xc9, 0x63,
		0x7a, 0x0b, 0x5c, 0x20, 0x88, 0x72, 0x34, 0x0a,
		0x8a, 0x1e, 0x30, 0xb7, 0x9c, 0x23, 0x3d, 0x1a,
		0x8f, 0x4a, 0xfb, 0x5e, 0x81, 0xa2, 0x3f, 0x98,
		0xaa, 0x07, 0x73, 0xa7, 0xf1, 0xce, 0x03, 0x96,
		0x37, 0x3b, 0x97, 0xdc, 0x5a, 0x35, 0x17, 0x83,
		0x7d, 0xad, 0x0f, 0xee, 0x4f, 0x5f, 0x59, 0x10,
		0x69, 0x89, 0xe1, 0xe0, 0xd9, 0xa0, 0x25, 0x7b,
		0x76, 0x49, 0x02, 0x9d, 0x2e, 0x74, 0x09, 0x91,
		0x86, 0xe4, 0xcf, 0xd4, 0xca, 0xd7, 0x45, 0xe5,
		0x1b, 0xbc, 0x43, 0x7c, 0xa8, 0xfc, 0x2a, 0x04,
		0x1d, 0x6c, 0x15, 0xf7, 0x13, 0xcd, 0x27, 0xcb,
		0xe9, 0x28, 0xba, 0x93, 0xc6, 0xc0, 0x9b, 0x21,
		0xa4, 0xbf, 0x62, 0xcc, 0xa5, 0xb4, 0x75, 0x4c,
		0x8c, 0x24, 0xd2, 0xac, 0x29, 0x36, 0x9f, 0x08,
		0xb9, 0xe8, 0x71, 0xc4, 0xe7, 0x2f, 0x92, 0x78,
		0x33, 0x41, 0x1c, 0x90, 0xfe, 0xdd, 0x5d, 0xbd,
		0xc2, 0x8b, 0x70, 0x2b, 0x47, 0x6d, 0xb8, 0xd1
	]

	nextValue(seed?) {
		local h, i, s, v;

		v = ((seed != nil) ? seed : getSeed());
		h = 0;

		for(i = 0; i <= 3; i++) {
			s = (v >> (i << 3)) & 0xff;
			h = _table[(h ^ s) + 1];
		}

		if(seed == nil)
			setSeed(h);

		return(h);
	}
;

// Trivial "PRNG" where v[x] = (v[x - 1] + a) % b, where a and b are
// co-prime.  This will produce a sequence with a period of b.
class CoPrimePRNG: NotReallyRandomPRNG
	prime0 = 33343
	prime1 = 65521
	nextValue(seed?) {
		local v;
		v = ((seed != nil) ? seed : getSeed());
		v = (v + prime0) % prime1;
		if(seed == nil) setSeed(v);
		return(v);
	}
;

// This is how we assign a global default PRNG.  We can still create
// other PRNG instances if we want, but this is the one that gets pointed
// to by all of the #defines in notReallyRandom.h.
class NotReallyRandom: XORshiftPRNG;
notReallyRandom: NotReallyRandom;
