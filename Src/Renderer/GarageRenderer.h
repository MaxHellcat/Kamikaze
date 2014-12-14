//
//  GarageRenderer.h
//  Kamikaze
//
//  Created by Max Reshetey on 5/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef GARAGE_RENDERER_H
#define GARAGE_RENDERER_H

#include "Renderer.h"

#include "BodySimple.h"

#include <string>
#include <vector>

#include "PlayerCareer.h"

#import "MyWidget.h"


class GarageRenderer : public Renderer
{
public:
	GarageRenderer();
	virtual ~GarageRenderer();

	virtual void beat() {};
	virtual void frame();

	// TODO: Move this into ShaderManager
	void setLightColor(GLfloat r=1.0f, GLfloat g=1.0f, GLfloat b=1.0f, GLfloat a=1.0f) { glUniform4f(ShaderManager::get()->program()->uniforms[uniLightColor], r, g, b, a); }
	void setLightPos(GLfloat x=0.0f, GLfloat y=0.0f, GLfloat z=100.0f) { glUniform3f(ShaderManager::get()->program()->uniforms[uniLightPos], x, y, z); }

	void touchItemGet(byte tag);
	void touchItemPreview(byte tag);

private: // Methods
	virtual void touchesBegan(float touchX, float touchY);
	virtual void touchesEnded(float touchX, float touchY);
	void touchMoney(byte tag);
	void touchItemRoot(byte tag);
	void touchItem(byte tag);
	void touchReturn(byte tag);
	
	void touchPopupGet(byte tag);


private: // Variables
	BodySimple _fan; // Huge fan in the back and background
	BodySimple _platform; // Scrolling base under the airplane
	BodySimple _jet[eNumVisibleUpgrades];
	Widget _back;

	// Icons
	MoneyWidget _money, _points;
	StripWidget _strip; // Full-width popup, container for specific upgrade items
	DetailsWidget _desc; // Popup with detailed information about curently touched upgrade item
	PopupWidget _popupGet, _popupInsuf;

	// To identify which root item was pressed last, so can index the items array
	// Seems to be the quickest and good enough way (as opposed to other two in mind)
	byte _currentRootItem;
	bool _popupExclusive; // Easy way to emulate modal popup (or implement stack of screen widgets)


	// TODO: We don't need these to be members
//	
//	ConfirmPopup _confirmPopup;
//	InsufficientPopup _insufPopup;

	UpgradeItem * _currentItem; // Last touched upgrade item, refer to it when getting upgrade

};


#endif
