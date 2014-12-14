//
//  GameStateController.h
//  Kamikaze
//
//  Created by Hellcat on 5/19/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef GAME_STATE_CONTROLLER_H
#define GAME_STATE_CONTROLLER_H


#include "Singleton.h"
#include "constants.h"

// Include here as viewController also need them
#include "ActionRenderer.h"
#include "GarageRenderer.h"
#include "MainMenuRenderer.h"


enum
{
	eStateUnknown = 0, // Set on app start, to provoke splash creation
	eStateSplash,
	eStateMainMenu,
	eStateAction,
	eStateActionPaused,
	eStateActionNeedsRestart,
	eStateActionCompleted,
	eStateGarage,
	eNumStates
};

// For debug only
static const char * states[eNumStates] =
{
	"eStateUnknown",
	"eStateSplash",
	"eStateMainMenu",
	"eStateAction",
	"eStateActionPaused",
	"eStateActionNeedsRestarted",
	"eStateActionCompleted",
	"eStateGarage"
};


// Class to manage application callflows
class _StateController
{
private:

	byte _prevState, _state;

	Renderer * _client;

public:
	_StateController();
	~_StateController();

	Renderer * activeRenderer() { return _client; };

	void setState(byte state) { _state = state; }
	const byte state() const { return _state; }
	const byte prevState() const { return _prevState; }
	
	const char * stateStr() const { return states[_state]; }
	const char * prevStateStr() const { return states[_prevState]; }
	
	void flow();
	
	UIView * _view;

	// Set view to draw on
//    void setView(UIView *);

    // The view we'll subview
//    UIView * _view;

};

typedef Singleton<_StateController> StateController;

#endif // GAME_STATE_CONTROLLER_H
