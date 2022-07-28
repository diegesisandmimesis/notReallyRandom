notReallyRandom
Version 1.0
Copyright 2022 Diegesis & Mimesis, distributed under the MIT License



ABOUT THIS LIBRARY

The notReallyRandom library provides instanceable PRNGs and a number of
convenience methods for interacting with them.

The design goal is to allow individual objects/NPCs/events to get their
own PRNG instance so that their (pseudo-)random behaviors are independent
of each other, as well as the (default) TADS3 global PRNG.  This will
be of interest primarily in cases where the behavior of individual
objects needs to be "rolled back" and then repeated without affecting
anything else.



WARNING

All of the randomness provided by this library is intended to be "good
enough" for its purpose, which is to look plausibly random to a player
playing an interactive fiction game.

NONE OF THE PRNGS IN THIS LIBRARY PROVIDE CRYPTOGRAPHIC RANDOMNESS AND
THEY SHOULD NOT BE USED FOR ANY CRYPTOGRAPHIC OR SECURITY RELATED PURPOSES.

See the comments in the source for details about possible
limitations/weaknesses in this library's PRNG implementations.



LIBRARY CONTENTS

	notReallyRandom.h
		Header file, containing all the #defines for the library.

		You can enable and disable features by commenting or
		uncommenting the #define statements.  Each #define is prefaced
		by comments explaining what it does.

	notReallyRandom.t
		Contains the module ID for the library and miscellaneous
		global utility functions.

	notReallyRandomPRNG.t
		PRNG class definitions.

	notReallyRanomTests.t
		Test methods.  Not compiled in by default, uncomment
		#define __DEBUG_NOT_REALLY_RANDOM in notReallyRandom.h to
		enable.

	notReallyRandom.tl
		The library file for the library.

	doc/README.txt
		This file


