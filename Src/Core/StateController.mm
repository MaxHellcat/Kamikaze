//
//  GameStateController.mm
//  Kamikaze
//
//  Created by Hellcat on 5/19/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "StateController.h"

#include "Matrix.h"

#include "Misc.h"

#include "PlayerCareer.h"


_StateController::_StateController() :
_prevState(eStateUnknown), _state(eStateSplash), _client(0)
{
	// Do not recreate shaders in renderer! (that takes time)
	ShaderManager::alloc();
	MatrixManager::alloc();
}

_StateController::~_StateController()
{
	ShaderManager::release();
	MatrixManager::release();

	if (_client) delete _client; _client = 0;
}

void _StateController::flow()
{
//	printf("The flow, state: %s, prev: %s\n", states[_state], states[_prevState]);

	// If previous and current states are the same, just carry on with usual client drawing
	// TODO: Place rare states (e.g. splash) at the end
	if (_state == _prevState) // Do NOT enlarge this condition line
	{
		 _client->frame();
	}
	// State has just changed (e.g. quit main menu and start game), release previous client and load new one
	else
	{
		// TODO: Reduce these conditions
		// Just touched pause button, don't release the client!
		if (_state == eStateActionPaused || // If pause just touched
			_prevState == eStateActionPaused && _state == eStateAction) // Or just untouched and new state is not restarting
		{
			// Show/disable pause menu
			printf("Show/disable pause menu\n");
		}
		else if (_state == eStateActionCompleted)
		{
		
		}
		else
		{ // Previous client just finished drawing
			// Release previous client
			if (_client) delete _client; _client = 0;

			// Finally, identify new client and perform proper initialization (it will start drawing on the next :flow() call)
			switch (_state) {
				case eStateAction:
				case eStateActionNeedsRestart:
					_state = eStateAction;
					_client = new ActionRenderer();
					break;
				case eStateGarage:
					_client = new GarageRenderer();
					break;

				case eStateSplash:
				case eStateMainMenu:
					_client = new MainMenuRenderer(); // It knows how to branch cases
					break;

				//default:
				//	break;
			}
		}
		_prevState = _state; // Remember the previous state (so we keep the short history)
	}

}
