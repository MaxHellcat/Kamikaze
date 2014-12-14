//
//  PlayerCareer.cpp
//  Kamikaze
//
//  Created by Max Reshetey on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "PlayerCareer.h"

#include "tinyxml.h" // The very fast and tiny XML parser
#include "Misc.h" // For bundle

Career::Career() : _playerName(""), _rank(eRankAirmanBasic),
_score(0), _points(0), _money(0) {}

Career::~Career()
{
	for (byte i = 0; i < eNumUpgrades; ++i)
	{
		std::vector<UpgradeItem *> item = _items[eUpgradeBody];

		for (std::vector<UpgradeItem *>::iterator it=item.begin(); it!=item.end(); ++it)
		{ delete *it; *it = 0; }
	}
}

void Career::restore()
{
	_playerName = "Maxim";
	_rank = eRankAirmanBasic;

	_score = 0;
	_points = 999;
	_money = 99;

	parseXML(eUpgradeBody, "body");
	parseXML(eUpgradeWings, "wings");
	parseXML(eUpgradePropeller, "propeller");
	parseXML(eUpgradeEngine, "engine");
	parseXML(eUpgradeControl, "control");

	// Initial setting, later replace with what actually read from the disk
	for (short i = 0; i < eNumUpgrades; ++i)
	{
		_items[i][0]->isEnabled = true;
		_items[i][0]->isPwned = true;
		_items[i][0]->isCurrent = true;
	}
}

// Essentially, this methods should be executed only once - upon the very first application start
bool Career::parseXML(UpgradeType upgradeType, const char * upgradeName)
{
	TiXmlDocument doc(((Bundle::get()->path()+upgradeName)+".xml").c_str()); // Load the XML

	if (doc.LoadFile() == false)
	{
		printf("BAD XML!\n");
		return false;
	}

	TiXmlNode * nodeRoot = doc.FirstChild("upgrades");

	// Read upgrades
	int d = 0;
	for (TiXmlElement * elem = nodeRoot->FirstChildElement(upgradeName); elem; elem = elem->NextSiblingElement())
	{
		UpgradeItem * item = new UpgradeItem();

		item->type = upgradeType;

		item->name = elem->Attribute("name");
		item->description = elem->Attribute("description");

		elem->Attribute("points", &d);
		item->pricePoints = (short)d;

		elem->Attribute("money", &d);
		item->priceMoney = (short)d;

		item->icon = elem->Attribute("icon");

		item->mesh = elem->Attribute("modelMesh");
		if (upgradeType == eUpgradeWings) item->meshExtra = elem->Attribute("modelMeshTail");
		item->texDiffuse = elem->Attribute("texDiffuse");
		item->texNormal = elem->Attribute("texNormal");

		item->isPwned = false;
		item->isEnabled = true;
		item->isCurrent = false;

		_items[upgradeType].push_back(item);
	}		

	return true;
}
