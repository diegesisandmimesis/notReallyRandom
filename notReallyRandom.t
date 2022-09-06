#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>

#include <bignum.h>

#include "notReallyRandom.h"

// Module ID for the library
notReallyRandomModuleID: ModuleID {
	name = 'Not Really Random Library'
	byline = 'Diegesis & Mimesis'
	version = '1.0'
	listingOrder = 99
}

// Returns a number in the given range, inclusive.
// Example:  randomInt(0, 4) will return 0, 1, 2, 3, or 4 with equal
// probability.
// A PRNG instance can optionally be specified.  If none is given, tads-gen's
// rand() will be used instead.
randomInt(min, max, prng?) {
	if(prng != nil) return(prng.random(min, max));
	return(rand(max - min + 1) + min);
}

// Roll n d-sided dice.
// Example:  randomDice(2, 6) is 2d6, or the results of two six-sided dice
// added together for a number between 2 and 12.
randomDice(n, d, prng?) {
	local i, v;
	for(i = 0, v = 0; i < n; i++) v += randomInt(1, d, prng);
	return(v);
}

// Return a decimal number in the given range.  If no range is given, 0 and 1
// are assumed.
// Example:  randomBigNumber(0.5, 0.75) will return a decimal number between
// 0.5 and 0.75.  randomBigNumber() will return a decimal number between 0
// and 1.0.
randomBigNumber(min?, max?, prng?) {
	local v;

	v = new BigNumber(randomInt(0, 2147483647, prng)
		/ new BigNumber(2147483647));
	if((min == nil) || (max == nil)) return(v);
	min = new BigNumber(min);
	max = new BigNumber(max);
	return((v * (max - min)) + min);
}

// Return random values which match the given normal distribution.
// This means that, for example, ~68.2% of the returned values will
// be the given mean plus or minus sigma (the standard deviation);
// 95.4% will be the mean plus or minux two sigma;  99.6% will be the
// mean plus or minus three sigma, and so on.
randomBigNumberNormal(mean, sigma, prng?) {
	local one, u, v, x;

	mean = new BigNumber(mean);
	sigma = new BigNumber(sigma);
	one = new BigNumber(1.0);
	u = one - randomBigNumber(0, 1, prng);
	v = one - randomBigNumber(0, 1, prng);
	x = (new BigNumber(-2.0) * u.log10()).sqrt()
		* (new BigNumber(2.0) * BigNumber.getPi(10) * v).cosine();

	return(mean + (x * sigma));
}

// Returns a shuffled copy of the passed List.
// Uses Fischer/Yates to do the shuffling.
randomShuffle(lst, prng?) {
	local i, k, r, tmp;

	if((lst == nil) || !lst.ofKind(List)) return([]);
	r = lst.sublist(1, lst.length);
	for(i = r.length; i >= 2; i--) {
		k = randomInt(1, i, prng);
		tmp = r[i];
		r[i] = r[k];
		r[k] = tmp;
	}
	return(r);
}

// Returns a single random element of the passed List.
randomElement(lst, prng?) {
	return(lst[randomInt(1, lst.length, prng)]);
}

// Return a shuffled list of map directions.
// If the first argument is boolean true the diagonal directions are included,
// otherwise just the four cardinal directions are used.
randomDirection(diag?, prng?) {
	local l = [ 'n', 's', 'e', 'w' ];
	if(diag == true) l += [ 'ne', 'nw', 'se', 'sw' ];
	return(randomShuffle(l, prng));
}
