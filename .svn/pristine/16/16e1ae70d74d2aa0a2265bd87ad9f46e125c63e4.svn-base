/*
 *  XMLManager.cpp
 *  Kamikaze
 *
 *  Created by Hellcat on 04/14/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "LevelFactory.h"

#include "tinyxml.h" // The very fast and tiny XML parser
#include "Misc.h" // For bundle

#include "queue" // For priority queue

LevelFactory::~LevelFactory()
{
/*
	for (LevelFactory::DrawPool::iterator it = drawPool().begin(); it != drawPool().end(); ++it)
	{
		delete (*it); (*it) = 0;
	}
 */
	// Since _drawCounter may've been reset, do a max count release.
	// As an obvious result, it's extremely important we check for zero here!
	for (int i = 0; i < kMaxDrawArraySize; ++i)
	{
		if (_drawPool[i]) delete _drawPool[i]; _drawPool[i] = 0;
	}
}

LevelFactory::LevelFactory(const char * levelName) :
mLevelLength(0),
//_drawPool(0),
_drawCount(0)
{	
	if (!levelName || !*levelName)
		throw kErrXMLBadFilename;

	// It is important to nullify drawPool pointers!
	for (byte i = 0; i < kMaxDrawArraySize; ++i)
	{
		_drawPool[i] = 0;
	}

	if (readXML(levelName) == false)
		throw kErrXMLReadFail; // Read XML level
//	update(0.0f); // Initial update
}

bool LevelFactory::readXML(const char * levelName)
{
	TiXmlDocument doc((Bundle::get()->path()+levelName).c_str()); // Load the XML

	if (doc.LoadFile() == false) return false; // Parse it

	TiXmlNode * nodeRoot = doc.FirstChild("description");

	static double d = 0; // TinyXml wants double, we'll cast to float anyway
	nodeRoot->ToElement()->Attribute("length", &d);
	mLevelLength = (GLfloat)d; // Level length in meters

	// Get level background textures, <background> section
	TiXmlNode * node = nodeRoot->FirstChild("background");
	for (TiXmlElement * elem = node->FirstChildElement(); elem; elem = elem->NextSiblingElement())
	{
		mBack.push_back(elem->Attribute("name"));
	}

	//
	// Parse all level events (just figures so far)
	//

	// Parse all groups
	const char * tmp = 0;
	for (TiXmlElement * elemGroup = nodeRoot->FirstChildElement("set"); elemGroup; elemGroup = elemGroup->NextSiblingElement())
	{
		std::cout << "Parsing set!" << std::endl;

		byte type = 0, shape = 0;
		float size = 0.0f, posX = 0.0f, posY = 0.0f;

		tmp = elemGroup->Attribute("type");
		if (strcmp(tmp, "cube")==0) { shape = eBodyShapeBox; type = eEventTypeBox; }
		else if (strcmp(tmp, "cone")==0) { shape = eBodyShapeBox; type = eEventTypeCone; }
		else if (strcmp(tmp, "sphere")==0) { shape = eBodyShapeCircle; type = eEventTypeSphere; }
		else if (strcmp(tmp, "cyl")==0) { shape = eBodyShapeBox; type = eEventTypeCylinder; }

		elemGroup->Attribute("size", &d); size = (float)d;
		elemGroup->Attribute("posX", &d); posX = (float)d;
		elemGroup->Attribute("posY", &d); posY = (float)d;

		// Check "count" atribute of the group
		int count = 0;
		elemGroup->Attribute("count", &count);

		// If it's not zero, then just create "count" figures (all relevant data must be in group)
		if (count > 0)
		{
			float posOffset = 0;
			for (byte i=0; i<count; ++i, posOffset+=1.0f)
			{
				Event event;
				event.type = type;
				event.shape = shape;
				event.size = size;
				event.posX = posX;
				event.posY = posY + posOffset * size;
				event.texName = elemGroup->Attribute("tex");
				mEvents.push(event);
			}

			// Now, as we've created count bodies of the set, check if we have any extra bodies in it
			// This is a case, for example to put smth different on the column of similar bodies
			for (TiXmlElement * elem = elemGroup->FirstChildElement("body"); elem; elem = elem->NextSiblingElement())
			{
				Event event;
				const char * type = elem->Attribute("type");
				if (strcmp(type, "cube")==0) { event.shape = eBodyShapeBox; event.type = eEventTypeBox; }
				else if (strcmp(type, "cone")==0) { event.shape = eBodyShapeBox; event.type = eEventTypeCone; }
				else if (strcmp(type, "sphere")==0) { event.shape = eBodyShapeCircle; event.type = eEventTypeSphere; }
				else if (strcmp(type, "cyl")==0) { event.shape = eBodyShapeBox; event.type = eEventTypeCylinder; }

				event.size = size;
				event.posX = posX;
				event.posY = posY + posOffset * size;
				event.texName = elem->Attribute("tex");
				mEvents.push(event);
			}
		}
		else // If it's missing, iterate <body/> kids and create bodies (only texture differs for now)
		{ // Allow kids to override set's attributes
			float posOffset = 0;
			for (TiXmlElement * elemBody = elemGroup->FirstChildElement("body"); elemBody; elemBody = elemBody->NextSiblingElement(), posOffset+=1.0f)
			{
				tmp = elemBody->Attribute("type"); // Check if type overriden
				if (tmp)
				{
					if (strcmp(tmp, "cube")==0) { shape = eBodyShapeBox; type = eEventTypeBox; }
					else if (strcmp(tmp, "cone")==0) { shape = eBodyShapeBox; type = eEventTypeCone; }
					else if (strcmp(tmp, "sphere")==0) { shape = eBodyShapeCircle; type = eEventTypeSphere; }
					else if (strcmp(tmp, "cyl")==0) { shape = eBodyShapeBox; type = eEventTypeCylinder; }
				}

//				elemGroup->Attribute("size", &count);// Size must be the same within a group
//				elemGroup->Attribute("posX", &count); // PosX must be the same within a group
//				elemGroup->Attribute("posY", &count); // Calculated automatically within a group

				Event event;
				event.type = type;
				event.shape = shape;
				event.size = size;
				event.posX = posX;
				event.posY = posY + posOffset * size;

				// Allow inline body to override texture name, specified for the set
				tmp = elemBody->Attribute("tex");
				if (tmp)
					event.texName = tmp;
				else
					event.texName = elemGroup->Attribute("tex");

				mEvents.push(event);
			}
		}
	}

	// Parse simple bodies
	const char * type = 0;
	for (TiXmlElement * elem = nodeRoot->FirstChildElement("body"); elem; elem = elem->NextSiblingElement())
	{
		Event event;
		type = elem->Attribute("type");
		if (strcmp(type, "cube")==0) { event.shape = eBodyShapeBox; event.type = eEventTypeBox; }
		else if (strcmp(type, "cone")==0) { event.shape = eBodyShapeBox; event.type = eEventTypeCone; }
		else if (strcmp(type, "sphere")==0) { event.shape = eBodyShapeCircle; event.type = eEventTypeSphere; }
		else if (strcmp(type, "cyl")==0) { event.shape = eBodyShapeBox; event.type = eEventTypeCylinder; }

		elem->Attribute("size", &d); event.size = (float)d;
		elem->Attribute("posX", &d); event.posX = (float)d;
		elem->Attribute("posY", &d); event.posY = (float)d;

		event.texName = elem->Attribute("tex");

		mEvents.push(event);
		printf("Added event, posX: %f\n", mEvents.top().posX);
	}


	return true;
};

// This should be called say each sec or so (needs experiments)
// Works out where we are in the level (covered distance), creates nearest bodies
void LevelFactory::update(GLfloat metersGone)
{
	while (!mEvents.empty())
	{
		const Event & event = mEvents.top();
//		printf("Processing event: posX %f\n", event.posX);

		float preX = 15.0f; // Number of meters ahead we are scanning pending events

		// Attention, if event is above the scene, create it immediately!
		// If we create if beforehand (like for any other events), the body will
		// drop out of screen in the right, bad.
		if (event.posY > kSceneHeight/2.0f)
		{
//			if (event.posX <= metersGone)
//			{
//			preX = 0.0f;
//			}
		}
		else
		{
//			preX = 10.0f;
		}

		if (event.posX <= metersGone + preX)
		{ // If event is close enough, create corresponding body
//			printf("Event is close, create body, posX: %f!\n", event.posX);
			BodyBox2d * body = 0;

//			body = new BodyBox2d(eBodyTypeDynamic, event.shape, event.size*0.5f, event.size*0.5f, event.posX+N, event.posY);
			body = new BodyBox2d(eBodyTypeDynamic, (eBodyShape)event.shape,
								 event.size*0.5f, event.size*0.5f,
//								 0.0f+preX, event.posY);
								 event.posX/*-preX*/, event.posY);

			if (event.type == eEventTypeBox)
			{
				body->addMesh("Box").
				addTexture(event.texName.c_str()).
				addTexture("cube_nm");
			}
			else if (event.type == eEventTypeSphere)
			{
				body->addMesh("Ball").
				addTexture(event.texName.c_str()).
				addTexture("ball_nm");
			}
			else if (event.type == eEventTypeCone)
			{
				body->addMesh("Cone").
				addTexture(event.texName.c_str()).
				addTexture("cone_nm");
			}
			else if (event.type == eEventTypeCylinder)
			{
				body->addMesh("Cylinder_vert_01").
				addTexture(event.texName.c_str()).
				addTexture("cylinder_nm");
			}
			body->setScale(event.size);

//			static int count = 0;
//			printf("Created bodies: %d\n", ++count);

//			body->addTexture("bloored-light-reflection-map");

//			if (event.posY > 7.0f)
//				body->angularImpulse(1.0f); // Spin falling objects

//			mDrawPool.push_back(body); // Add created body to the drawing list

//			printf("Adding new body, drawCount: %d\n", _drawCount);
			// Attempt to maintain drawPool efficiently
			// - Reset the counter if reached max
			// - Delete referenced body (only if valid) before assigning new
			if (_drawCount > kMaxDrawArraySize-1)
			{
//				printf("Reached max events, reset the counter!\n");
				_drawCount = 0;
			}

			// TODO: If the body is still within scene, it'll disappear
			// Filter before removal!
			if (_drawPool[_drawCount])
			{
//				printf("Slot not null, attempt to release first, %p\n", _drawPool[_drawCount]);
				delete _drawPool[_drawCount];
				_drawPool[_drawCount] = 0;
			}

			_drawPool[_drawCount++] = body; // Reference new body

			mEvents.pop(); // Remove processed event from the queue
		}
		else
		{ // Since we're asc sorted, we may safely quit once this event is too far
//			printf("Event is too far, leave loop!\n");
			return;
		}
	}
}
