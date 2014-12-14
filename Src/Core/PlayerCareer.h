//
//  PlayerCareer.h
//  Kamikaze
//
//  Created by Max Reshetey on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef PLAYER_CAREER_H
#define PLAYER_CAREER_H

#include "iostream"
#include "vector"

#include "map"


#include "constants.h"

#include "Singleton.h"

#include "PlayerCareerDefs.h" // Ranks, upgrades enums


class UpgradeItem
{
public:
	UpgradeItem() : name(""), description(""), pricePoints(0), priceMoney(0),
	icon(""), mesh(""), meshExtra(""), texDiffuse(""), texNormal(""),
	isEnabled(false), isPwned(false), isCurrent(false) {};
	~UpgradeItem() {};

	UpgradeType type;

	std::string name;
	std::string description;
	unsigned short pricePoints;
	unsigned short priceMoney;
	std::string icon; // Icon name to draw in the garage

	std::string mesh; // The .pod scene mesh name
	std::string meshExtra; // Additional mesh (may be empty)
	std::string texDiffuse;
	std::string texNormal;

	bool isEnabled; // Whether upgrade is enabled for purchase (rank dependent)
	bool isPwned; // Whether upgrade has been purchased
	bool isCurrent;
};

class Career
{
public:
	Career();
	~Career();

	const std::string playerName() const { return _playerName; }
	const byte rank() const { return _rank; }

//	const uint score() const { return _score; }
//	void setScore(uint score) { _score = score; };

	const uint points() const { return _points; }
	void setPoints(uint points) { _points = points; };

	const uint money() const { return _money; }
	void setMoney(uint money) { _money = money; };


	bool store() {return true; } // Persist player's career to the persistent store
	void restore(); // Restore player's career from the disk
	
	UpgradeItem * upgradeItem(UpgradeType type, byte evolution)
	{
		return _items[type][evolution];
	}
	
	std::vector<UpgradeItem *> itemSet(UpgradeType type)
	{
		return _items[type];
	}
	
	UpgradeItem * current(UpgradeType type)
	{
		for (byte i=0; i<eNumUpgrades; ++i)
		{
			if (_items[type][i]->isCurrent == true)
				return _items[type][i];
		}
		return 0;
	}

private: // Methods
	bool parseXML(UpgradeType upgradeType, const char * upgradeName);

private: // Variables
	std::string _playerName;
	Rank _rank;
	unsigned int _score; // Total score, grows as levels are beaten, never decreases
	unsigned int _points; // Bonus points, given for mission completions, spent on upgrades
	unsigned int _money; // In game money, filled through inapp purchases, spent on upgrades

//	byte currentUpgrades[eNumUpgrades];

	std::vector<UpgradeItem *> _items[eNumUpgrades];;
};

typedef Singleton<Career> PlayerCareer;


#endif

