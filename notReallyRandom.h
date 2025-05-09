//
// notReallyRandom.h
//

// Uncomment to enable debugging options.
//#define __DEBUG_NOT_REALLY_RANDOM

// Use to enable statistical tests
//#define NOT_REALLY_RANDOM_TESTS

// Dependency check applied if we're being compiled with the test classes.
#ifdef NOT_REALLY_RANDOM_TESTS
#include "statTest.h"
#ifndef STAT_TEST_H
#error "This module requires the statTest module."
#error "https://github.com/diegesisandmimesis/statTest"
#error "It should be in the same parent directory as this module.  So if"
#error "notReallyRandom is in /home/user/tads/notReallyRandom, then statTest"
#error "should be in /home/user/tads/statTest ."
#endif // STAT_TEST_H
#endif // NOT_REALLY_RANDOM_TESTS

// Some macros.
#define nrrSeed(v) (notReallyRandom.setSeed(v))
#define nrrRand(var...) (notReallyRandom.random(##var))
#define nrrIdx(a, var...) (notReallyRandom.idx(a, ##var))
#define nrrXY(a, b, var...) (notReallyRandom.xy(a, b, ##var))

/*
#define salsaROTL(a, b) (((a) << (b)) | ((a) >> (32 - (b))))
#define salsaQR(a, b, c, d) \
	b ^= salsaROTL(a + d, 7); \
	c ^= salsaROTL(b + a, 9); \
	d ^= salsaROTL(c + b, 13); \
	a ^= salsaROTL(d + c, 18);
#define salsaRounds 20
*/

#ifndef isPRNG
#define isPRNG(v) ((v != nil) && v.ofKind(NotReallyRandom))
#endif // isPRNG

// Don't comment out.  Used for dependency checking.
#define NOT_REALLY_RANDOM_H
