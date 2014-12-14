/*
 *  AirplanePainter.h
 *  Kamikaze
 *
 *  Created by Arkadiev on 6.3.2011.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef AIRPLANE_PAINTER_H
#define AIRPLANE_PAINTER_H

#include "Body.h"
#include "PlayerCareer.h"

static float coords[eNumUpgrades][2] = {
	{ 0, 0 },
	{ 0, 0 },
	{ 0, 0 },
	{ -3, 0 },
	{ -0.5, 0 },
};

class AirplanePainter {
	Airplane * _jet;
	
	BodyBox2d * bodies[eNumUpgrades], * goodies[eNumUpgrades];
	UpgradeItem * items[eNumUpgrades], * goods[eNumUpgrades];
	
	int was[eNumUpgrades], now[eNumUpgrades];
	
public:
	AirplanePainter() {
		for (int i = 0; i < eNumUpgrades; i++) {
			bodies[i] = 0;
			items[i] = 0;
			goodies[i] = 0;
			goods[i] = 0;
		}
		_jet = 0;
	}
	
	~AirplanePainter() {
		for (int i = 0; i < eNumUpgrades; i++) {
			//delete bodies[i];
			delete goodies[i];
		}
		delete _jet;
	}
	
	void prepare() {
		for (int i = 0; i < eNumUpgrades; i++) {
			items[i] = PlayerCareer::get()->getCurrentUpgrade((UpgradeType)i);
			/*goods[i] = PlayerCareer::get()->currentUpgrades[i];*/
		}
		
		for (int i = 0; i < eNumUpgrades; i++) {
			if (items[i]->modelMesh != "") {
				bodies[i] = (BodyBox2d *) &
					(new BodyBox2d(eBodyTypeDynamic, eBodyShapeBox, 1, 1, 1, 1, 1))
						->addMesh(items[i]->modelMesh.c_str())
							.addTexture(items[i]->texDiffuse.c_str())
							.addTexture(items[i]->texNormal.c_str());
			}
/*			if (goods[i]->modelMesh != "") {
				goodies[i] = (BodyBox2d *) &
					(new BodyBox2d(eBodyTypeDynamic, eBodyShapeBox, 1, 1, 1, 1, 1))
						->addMesh(goods[i]->modelMesh.c_str())
							.addTexture(goods[i]->texDiffuse.c_str())
							.addTexture(goods[i]->texNormal.c_str());
			}*/
		}
		
		_jet = new Airplane(2.5f, 0.4f, 0.0f, 0.0f);
		_jet->addMesh(items[eUpgradeBody]->modelMesh.c_str()).addTexture(items[eUpgradeBody]->texDiffuse.c_str()).addTexture(items[eUpgradeBody]->texNormal.c_str()).addTexture("bloored-light-reflection-map").
		addMesh("tires_back").addTexture("wheels_diffuse").addTexture(items[eUpgradeBody]->texNormal.c_str()). // Back chassis is a part of fuselage
		addMesh("tires_wood").addTexture("wheels_diffuse").addTexture(items[eUpgradeBody]->texNormal.c_str()).
		addMesh("cabin").addTexture(items[eUpgradeBody]->texDiffuse.c_str()).addTexture(items[eUpgradeBody]->texNormal.c_str());

		
/*
		_jet = new Airplane(2.5f, 0.4f, 0.0f, 0.0f);
		_jet->addMesh(items[eUpgradeBody]->modelMesh.c_str()).addTexture(items[eUpgradeBody]->texDiffuse.c_str()).addTexture(items[eUpgradeBody]->texNormal.c_str()).addTexture("bloored-light-reflection-map").
			addMesh("tires_back").addTexture("wheels_diffuse").addTexture(items[eUpgradeBody]->texNormal.c_str()). // Back chassis is a part of fuselage
			addMesh("cabin").addTexture(items[eUpgradeBody]->texDiffuse.c_str()).addTexture(items[eUpgradeBody]->texNormal.c_str());
*/
 
		delete _jet->_parts[Airplane::eJetWings];
		_jet->_parts[Airplane::eJetWings] = bodies[eUpgradeWings];
		
		delete _jet->_parts[Airplane::eJetPropeller];
		_jet->_parts[Airplane::eJetPropeller] = bodies[eUpgradePropeller];
	}
	
	void draw() {
		for (int i = 0; i < eNumUpgrades; i++) {
			//if (bodies[i]) bodies[i]->draw();
		}
		_jet->draw();
		//_jet->_parts[Airplane::eJetPilot]->draw(false); // TODO: Make part of fuselage
		
		// Gun
		_jet->_parts[Airplane::eJetPropeller]->draw(false);
		
		// Keel and stabilizers
		_jet->_parts[Airplane::eJetTail]->draw(false);
		
		// Wings, front chassis
		_jet->_parts[Airplane::eJetWings]->draw(false);
	}
};

#endif // AIRPLANE_PAINTER_H
