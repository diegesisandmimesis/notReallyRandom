#charset "us-ascii"
//
// notReallyRandom.t
//
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
// Optional third arg is a callback function used to test elements;
// only elements for which the callback returns boolean true can
// be selected.
randomElement(lst, prng?, cb?) {
	local l;

	// Check the first arg.
	if((lst == nil) || !lst.ofKind(Collection)) return(nil);
	if(lst.length < 1) return(nil);

	// If we didn't get a callback, just return any random element.
	if(dataType(cb == TypeNil))
		return(lst[randomInt(1, lst.length, prng)]);

	// Shuffle the list.
	l = randomShuffle(lst, prng);

	// Return the first element in the shuffled list for which
	// the callback returns true when called with the element as
	// an arg.
	return(l.valWhich(cb));
}

// Weighted version of the above.  First arg is the list of choices, second
// arg is a list containing the integer weights of each choice.
// Example:  randomElementWeighted([ 'foo', 'bar', 'baz' ], [ 5, 10, 20 ])
//	will randomly pick 'foo', 'bar', or 'baz', with 'foo' happening
//	half as often as 'bar' and 'bar' happening half as often as
//	'baz' ('foo' 5 in 35 or 14.3%, 'bar' 10 in 35 or 28.6%, 'baz'
//	20 in 35 or 57.1%).
randomElementWeighted(lst, weights, prng?) {
	if((lst == nil) || (weights == nil)) return(nil);
	if(lst.length != weights.length) return(nil);
	return(lst[randomIndexWeighted(weights, prng)]);
}

randomIndexWeighted(weights, prng?) {
	local i, t, v;

	t = 0;
	weights.forEach({ x: t += x });
	v = randomInt(1, t, prng);
	t = 0;
	for(i = 1; i <= weights.length; i++) {
		t += weights[i];
		if(v < t) return(i);
	}
	return(weights.length);
}

// Pick a random index in the given list.
randomIndex(lst, prng?, cb?) {
	local i, l;

	// Check the first arg.
	if((lst == nil) || !lst.ofKind(Collection)) return(nil);
	if(lst.length < 1) return(nil);

	// If we didn't get a callback, just return any random index.
	if(dataType(cb == TypeNil))
		return(randomInt(1, lst.length, prng));

	// Shuffle the list.
	l = randomShuffle(lst, prng);

	// Return the first element in the shuffled list for which
	// the callback returns true when called with the element as
	// an arg.
	for(i = 1; i <= l.length; i++) {
		if((cb)(l[i]) == true) return(i);
	}
	return(nil);
}

// Simple Chinese restaurant process implementation.
// The restaurant has an unlimited number of tables, and each table
// can hold an unlimited number of customers.
// When a new customer arrives, they can either be seated at
// a new (currently empty) table or sit at a table that already
// has customers at it.  The chances of being seated at an already
// occupied table is proportional to the number of customers already
// seated at it--that is, the more people are already at a table,
// the more likely a new customer is to be seated there.
// Arguments are:
//	count	total number of customers to seat
//	theta	tuning factor.  the prob. of customer n + 1 picking an
//		empty table is theta / ( n + theta ), and the prob.
//		of being seated at a table with m customers already
//		seated at it is m / ( n + theta )
//		default: 1
//	weight	integer weight used to convert decimal probabilities
//		into integer weights
//		default: 1000
//	prng	PRNG instance to use
//		no default
randomChineseRestaurantProcess(count, theta?, weight?, prng?) {
	local d, i, j, prob, tables;

	tables = new Vector(count);

	// First customer always sits at a new table.
	tables.append(1);

	// Sanity check.
	if(count < 2) return(tables);

	// Theta is a fudge factor for tuning the likelihood of a
	// customer picking an empty table.  Default is 1.
	theta = new BigNumber(theta ? theta : 1);

	weight = (weight ? weight : 1000);

	prob = new Vector(count);

	// Probabilities are for customer n + 1, so we iterate
	// from 1 (to seat the second customer) and use < instead
	// of <=.
	for(i = 1; i < count; i++) {
		// Reset the probability vector.
		prob.setLength(0);

		// Denominator for all our probabilities.
		d = new BigNumber(i) + theta;

		// Chance of picking an empty table.
		prob.append(theta / d);

		// Probabilities for sitting at each in-use table.
		tables.forEach({ x: prob.append(new BigNumber(x) / d) });

		// Convert the probabilities to integer weights.
		for(j = 1; j <= prob.length; j++) {
			prob[j] = toIntegerNRR(prob[j] * weight);
		}

		// Pick a table.  1 is a new table, anything else is
		// the table number + 1 (because of how we assembled
		// the vector of weights above).
		j = randomIndexWeighted(prob, prng);
		if(j == 1)
			tables.append(1);
		else
			tables[j - 1] += 1;
	}

	// Return value, which is a vector containing the number of
	// customers seated at each table.
	return(tables);
}

// Return a shuffled list of map directions.
// If the first argument is boolean true the diagonal directions are included,
// otherwise just the four cardinal directions are used.
randomDirection(diag?, prng?) {
	local l = [ 'n', 's', 'e', 'w' ];
	if(diag == true) l += [ 'ne', 'nw', 'se', 'sw' ];
	return(randomShuffle(l, prng));
}

// Slightly braindead method to convert a string into a 16 bit integer seed.
// We generate the MD5 hash of the string and then xor 16-bit chunks together
// and return the result.
// NOT SAFE FOR CRYPTOGRAPHIC PURPOSES, but fine for what we want, which
// is to be able to convert a user-typed word or phrase into a PRNG seed
// for procgen stuff.
notReallyRandomStringToSeed(str) {
	local d, i, s, v;

	if((str == nil) || (dataType(str) != TypeSString))
		return(-1);

	d = str.digestMD5();
	i = 0;
	v = 0;
	while(i < d.length) {
		i += 4;
		s = toInteger(d.substr(i, 4), 16);
		if(i > 0) {
			v = v ^ s;
		} else {
			v = s;
		}
	}

	return(v);
}

nrrStringToSeed(str) { return(notReallyRandomStringToSeed(str)); }

toIntegerNRR(v) {
	local r;

	try { r = toInteger(v); }
	catch(Exception e) { r = 2147483647; }
	finally { return(r); }
}
