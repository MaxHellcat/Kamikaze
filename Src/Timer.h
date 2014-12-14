/*
 *  Timer.h
 *  Kamikaze
 *
 *  Created by Hellcat on 1/17/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef TIMER_H
#define TIMER_H

#include <CoreFoundation/CFDate.h> // For CFTimeInterval


// Class to represent timer operations, based on oolongo timer
class Timer
{
public:
	Timer() : startTime(0.0), interval(0.0) {};
	~Timer() {};

	float fps(unsigned int frame)
	{
		interval = CFAbsoluteTimeGetCurrent();

		if (startTime == 0.0)
			startTime = interval;

		return ((float)frame/(interval - startTime));
	}

private:
	CFTimeInterval startTime, interval;
};

#endif // #ifndef TIMER_H
