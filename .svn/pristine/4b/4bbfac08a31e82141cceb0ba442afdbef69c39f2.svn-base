/*
 *  Singleton.h
 *  
 *
 *  Created by Hellcat on 4.19.2011.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef SINGLETON_PATTERN_H
#define SINGLETON_PATTERN_H

// Class implementing the Singleton paradygm, examle of use Singleton<_YourAnyClass> YourAnyClass;
// For efficiency, method alloc() added, so we dont check for 0 when returning instance
// As a result, ALWAYS call alloc before any use
// TODO: A little trick here, we inherit Singleton from T, and so get() actually returns Singleton instance, not T.
// I'm not 100% sure this is healthy, and do get rid of inheritance if any sort of weird problems
template <class T>
class Singleton : public T
{
public:
	// Create single instance (always call first)
	static Singleton * alloc()
	{
		if (!_self)
			_self = new Singleton<T>; // Healthy?
		return _self;
	};

	// Get instance
	// Intentionally removed any null-checks for speed, so make sure you'd called alloc before
	static Singleton * get() { return _self; }
	static void release() { delete _self; }

private:
	Singleton() {}
	virtual ~Singleton() { _self = 0; } // So T's dtor gets called
	static Singleton * _self;
};

template <class T>
Singleton<T> * Singleton<T>::_self = 0;

#endif
