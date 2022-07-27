//
// notReallyRandom.h
//

// Uncomment to enable debugging options, including test methods
// (in notReallyRandomTests.t)
//#define __DEBUG_NOT_REALLY_RANDOM

#define gNRRseed(v) (notReallyRandom.setSeed(v))
#define gNRRrand(var...) (notReallyRandom.random(##var))
#define gNRRidx(a, var...) (notReallyRandom.idx(a, ##var))
#define gNRRxy(a, b, var...) (notReallyRandom.xy(a, b, ##var))
