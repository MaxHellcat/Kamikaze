/*
 *  XMLManager.h
 *  Kamikaze
 *
 *  Created by Hellcat on 04/14/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef LEVELMANAGER_H
#define LEVELMANAGER_H

#include <OpenGLES/ES2/gl.h>

#include "queue"

#include "BodyBox2d.h" // Because we'll be creating bodies
#include "BodySimple.h"

typedef
enum
{
	eEventTypeBox=0,
	eEventTypeSphere,
	eEventTypeCone,
	eEventTypeCylinder,
	eNumEventTypes
} EventType;

#define kMaxDrawArraySize 50


// Class to manage bodies creation when playing.
// For proper working needs to know level covered meters, so update() frequently
// Note: The update() period of 0.5sec is set for now (tune up in future)
class LevelFactory
{
public: // Methods
	LevelFactory(const char * levelName);
	~LevelFactory();

	// Struct to incapsulate one separate event from XML
	struct Event
	{
		Event() : type(0), shape(eBodyShapeBox), size(0.0f), posX(0.0f), posY(0.0f), texName("") {}
		byte type; // Body type, e.g. Cone, Sphere
		byte shape;
		float size, posX, posY;
		std::string texName;
	};

	// Functor to asc sort events in the queue (top element has the minimal value)
	class CompareFunctor
	{
	public:
//		bool operator() (const Event & lhs, const Event & rhs) const { return (lhs.distance > rhs.distance); }
		bool operator() (const Event & lhs, const Event & rhs) const { return (lhs.posX > rhs.posX); }
	};

	// The event queue, always asc sorted by Event::distance value
	typedef std::priority_queue<Event, std::vector<Event>, CompareFunctor> EventQueue;

	// The drawing pool, contains bodies pending drawing on screen
	typedef std::vector<BodyBox2d *> DrawPool;
    
//    typedef std::vector<Upgrade> Upgrades;

	bool readXML(const char * levelName); // Read and parse XML level
	void update(GLfloat metersGone); // Main processing logic, call reasonably frequently

	const char * backTex(GLbyte index) { return mBack[index].c_str(); }
	GLbyte numBackTex() const { return mBack.size(); }

//	DrawPool & drawPool() { return mDrawPool; }
	BodyBox2d * drawPool(int index) { return _drawPool[index]; }
	const int drawCount() const { return _drawCount; }

//    Upgrades & getUpgrades() { return upgrades; }

    int getLevelLength() { return mLevelLength; }

private: // Vars
	EventQueue mEvents; // The events queue
	GLfloat mLevelLength; // Level length in meters
	std::vector<std::string> mBack; // List of backgound textures
//	DrawPool mDrawPool; // The bodies to be drawn
	BodyBox2d * _drawPool[kMaxDrawArraySize]; // For speed, allow no more than this body count
	int _drawCount;

};

#endif
