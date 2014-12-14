//
//  GarageRenderer.cpp
//  Kamikaze
//
//  Created by Max Reshetey on 5/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "GarageRenderer.h"

#include "macro.h"

#include "Matrix.h"

#include "Misc.h" // Box2D physics engine (include here as we're inheriting b2ContactListener)

#include "GarageButtonsSatellite.h"

#include "StateController.h"

#include "PlayerCareer.h"

#import "MyWidget.h"

#include "constants.h"


typedef void (GarageRenderer::*Pointer) (byte); // Pointer to touch handler

GarageRenderer::GarageRenderer() : _currentItem(0), _currentRootItem(0), _popupExclusive(false)
{
//	glDisable(GL_CULL_FACE); // Too many holes in the airplane

	Mesh::preloadScene("garage_support.pod");

	// Garage back texture
	_back.setSize(10.0f).setPos(0.0f, 0.0f).setPosZ(kDepthBack-2.0f).addMesh().addTexture("garage_bg.png");

	// Big fan behind the back
	_fan.setSize(10.0f).setPos(0.5f, 8.0f).setPosZ(kDepthBack-2.1f).
	addMesh().addTexture("fan-1");

	// Platform for the airplane to stand on
	_platform.addMesh("garage_support").
	addTexture("garage_support_color").
	addTexture("garage_support_nm").
	addTexture("spotted-light-reflection-map");

	// TODO: Consider tying somehow body and .pod scene it uses
	// TODO: This must also be loaded according to the current upgrades
	// TODO: We must now load all meshes!
	Mesh::preloadScene("airplane_wood.pod");
	Mesh::preloadScene("airplane_plastic.pod");
//	Mesh::preloadScene("airplane_steel.pod");

	// Recreate airplane with current upgrades
	for (byte i=0; i<eNumVisibleUpgrades; i++)
	{
		UpgradeItem * item = PlayerCareer::get()->current((UpgradeType)i);

		_jet[i].addMesh(item->mesh.c_str()).
		addTexture(item->texDiffuse.c_str()).
		addTexture(item->texNormal.c_str()).
		addTexture("bloored-light-reflection-map");

		if (i == eUpgradeWings) // Way to attach additional meshes
		{
			printf("Adding wings, see extra: %s\n", item->meshExtra.c_str());
			_jet[i].addMesh(item->meshExtra.c_str()).
			addTexture(item->texDiffuse.c_str()).
			addTexture(item->texNormal.c_str()).
			addTexture("bloored-light-reflection-map");
		}
	}

	//
	// UI elements
	//
	MyButton but;
	but.init("leave_garage.png", &GarageRenderer::touchReturn).setPosInMeters(8.0f, -6.0f).attach();

	// Current points and game money in the screen top
	_points.init("garage_points.png", 3.0f, 6.5f, &GarageRenderer::touchMoney).attach();
	_points.setToken("pts");
	_points.setText(PlayerCareer::get()->points()); // TODO: Replace with bonus

	_money.init("garage_cash.png", 7.0f, 6.5f, &GarageRenderer::touchMoney).attach();
	_money.setToken("$");
	_money._token.setFontSize(18);
	_money.setText(PlayerCareer::get()->money());


	// Root upgrade icons, set own touch handler and properly specify tags
	but.init("engine_100.png", &GarageRenderer::touchItemRoot).setPosInMeters(-8.0f, 5.0f).setTag(eUpgradeEngine).attach();
	but.init("control_basic.png", &GarageRenderer::touchItemRoot).setPosInMeters(-5.5f, 5.0f).setTag(eUpgradeControl).attach();
	but.init("wings_steel.png", &GarageRenderer::touchItemRoot).setPosInMeters(-3.0f, 5.0f).setTag(eUpgradeBody).attach();
	but.init("wings_steel.png", &GarageRenderer::touchItemRoot).setPosInMeters(-8.0f, 1.5f).setTag(eUpgradeWings).attach();
	but.init("propeller_steel.png", &GarageRenderer::touchItemRoot).setPosInMeters(-5.5f, 1.5f).setTag(eUpgradePropeller).attach();

	_strip.init("garage_line.jpg", 0.0f, -4.0f, noAction).setVisible(false).attach();
	_desc.init("buy_menu.png", 4.0f, 3.0f, noAction).setVisible(false).attach();
}

GarageRenderer::~GarageRenderer()
{
	// Stop all systems
	Texture::release(); // Release textures
	Mesh::release(); // Release meshes

	UIView * v = StateController::get()->_view;
    for (UIView * sv in v.subviews)
    {
        [sv removeFromSuperview];
    }
}

void GarageRenderer::frame()
{
	Renderer::preframe();

	ShaderManager::get()->useProgram(eShaderBasicTexture);
	setLightPos();
	setLightColor();

	glEnable(GL_BLEND);
	_fan.push().place().spinZ(false, -0.5f, true).draw(false).pop();
	_back.push().draw().pop(); // Since back is widget, it also draws all its kids - icons
	glDisable(GL_BLEND);

	ShaderManager::get()->useProgram(eShaderNormalReflectMapping);
//	ShaderManager::get()->useProgram(eShaderNormalMapping);
	setLightPos();
	setLightColor();

	// Draw platform, position it just above the hole
	_platform.push().
	place(true, 4.2f, -5.7f). // Move platform right above the hole
//	spinX(false, 8.0f). // Rotate towards us a bit, so looks in perspective
	spinX(false, 16.0f). // Rotate towards us a bit, so looks in perspective
	spinZ(false, -1.5f). // Very slight horizontal correction
	spinY(false, -0.3f, true). // Endless platform spin
	scale(1.8f).
	draw(false);

	_jet[0].place(false, 0.0f, 1.8f). // Put airplane right on the platform
	spinZ(false, 7.0f); // Put back chassis a bit down
//	spinX(false, 3.0f);

	// Attempt to draw currently chosen item transparently
	for (byte i = 0; i<eNumVisibleUpgrades; ++i)
	{
		if (_currentItem && _currentItem->type == i && !_currentItem->isPwned)
		{
			glEnable(GL_BLEND);
			glUniform1f(ShaderManager::get()->program()->uniforms[uniAlpha], 0.5f);
		}
		else
		{
			glUniform1f(ShaderManager::get()->program()->uniforms[uniAlpha], 1.0f);
		}

		if (i == eUpgradePropeller)
			_jet[i].spinX(false, 3.0f, true); // Make propeller rotate

		_jet[i].draw(false);
		glDisable(GL_BLEND);
	}

//	_jet[eUpgradeBody].draw(false);
//	_jet[eUpgradeWings].draw(false);
//	_jet[eUpgradePropeller].spinX(false, 3.0f, true).draw(false);

	_platform.pop();

	printer.Flush(); // Kids must call flush eventually
}


// This is called when confirmation popup's buttons touched
void GarageRenderer::touchPopupGet(byte tag)
{
	_popupGet.destroy();
	_popupExclusive = false;

	if (tag == eActionYes)
	{
		if (_currentItem->isCurrent) { /* do nothing */ }

		if (_currentItem->isPwned) // When we want to apply already pwned update
		{
			// Here we must make sure we have only one current in each item set
			// TODO: Find another quicker and wiser way of marking previous item as NOT current
			std::vector<UpgradeItem *> items = PlayerCareer::get()->itemSet(_currentItem->type);
			for (std::vector<UpgradeItem *>::iterator item=items.begin(); item!=items.end(); ++item)
			{
				(*item)->isCurrent = false;
			}
			_currentItem->isCurrent = true;
			return;
		}

		if (PlayerCareer::get()->points() > _currentItem->pricePoints)
		{ // We have enough points, let's get an upgrade

			// Here we must make sure we have only one current in each item set
			// TODO: Find another quicker and wiser way of marking previous item as NOT current
			std::vector<UpgradeItem *> items = PlayerCareer::get()->itemSet(_currentItem->type);
			for (std::vector<UpgradeItem *>::iterator item=items.begin(); item!=items.end(); ++item)
			{
				(*item)->isCurrent = false;
			}

			// Mark just purchased item as needed
			PlayerCareer::get()->setPoints(PlayerCareer::get()->points() - _currentItem->pricePoints);
			_currentItem->isPwned = true;
			_currentItem->isCurrent = true;

			_points.setText(PlayerCareer::get()->points()); // Update player's current points
		}
		else
		{ // If points not enough, check if we have enough money to obtain the item
			if (PlayerCareer::get()->money() > _currentItem->priceMoney) // TODO: Here must be item money price!
			{ // Enough money, buy upgrade
				// Here we must make sure we have only one current in each item set
				// TODO: Find another quicker and wiser way of marking previous item as NOT current
				std::vector<UpgradeItem *> items = PlayerCareer::get()->itemSet(_currentItem->type);
				for (std::vector<UpgradeItem *>::iterator item=items.begin(); item!=items.end(); ++item)
				{
					(*item)->isCurrent = false;
				}

				// Mark just purchased item as needed
				PlayerCareer::get()->setMoney(PlayerCareer::get()->money() - _currentItem->priceMoney); // TODO: Change for money!
				_currentItem->isPwned = true;
				_currentItem->isCurrent = true;

				_money.setText(PlayerCareer::get()->money()); // Update player's current money
			}
			else
			{ // No points and no money, get some through in-app purchases
				PlayerCareer::get()->setMoney(PlayerCareer::get()->money()+100); // TODO: Change for money!
				_money.setText(PlayerCareer::get()->money()); // Update player's current money
			}

			// TODO: Add money price into XML!
		}
	}
}

// This is called, when person touches the Get button of the Details screen
void GarageRenderer::touchItemGet(byte tag)
{
	if (!_currentItem)
		std::cout << "WARNING: Current item is NULL" << std::endl;

	// If we own current item, then just ask to apply it
	if (_currentItem->isCurrent)
	{
		_popupGet.init("blank_popup.png", &GarageRenderer::touchPopupGet).attach();
		_popupGet.setText("This is your current upgrade");
		_popupExclusive = true;
		return;
	}

	if (_currentItem->isPwned)
	{
		_popupGet.init("blank_popup.png", &GarageRenderer::touchPopupGet).attach();
		_popupGet.setText("You own this upgrade, apply now?");
		_popupExclusive = true;
		return;
	}

	if (PlayerCareer::get()->points() > _currentItem->pricePoints)
	{
		_popupGet.init("blank_popup.png", &GarageRenderer::touchPopupGet).attach();
		_popupGet.setText("Exchange upgrade for points?");
		_popupExclusive = true;
	}
	else
	{
		if (PlayerCareer::get()->money() > _currentItem->priceMoney) // TODO: Here must be item points price!
		{
			_popupGet.init("blank_popup.png", &GarageRenderer::touchPopupGet).attach();
			_popupGet.setText("Not enough points, buy for game money?");
			_popupExclusive = true;
		}
		else
		{
			_popupGet.init("blank_popup.png", &GarageRenderer::touchPopupGet).attach();
			_popupGet.setText("Not enough game money, buy some?");
			_popupExclusive = true;
		}
	}
}

void GarageRenderer::touchItemPreview(byte tag)
{
	if (_popupExclusive) return;

	_strip.setVisible(!_strip.visible());
}

void GarageRenderer::touchItem(byte tag)
{
	if (_popupExclusive) return;

	// Identify, store and update touched upgrade item

	// Remember current item, this is crucial
	UpgradeItem * item = _currentItem = PlayerCareer::get()->itemSet((UpgradeType)_currentRootItem)[tag];

	std::cout << "Item touched, tag: " << tag << ", name: " << item->name << std::endl;

	_desc.setPrice(item->pricePoints, item->priceMoney);
	_desc.setName(item->name.c_str());
	_desc.setDesc(item->description.c_str());
	_desc.setVisible(true);

	// Update airplane with transparent upgrade model 
	if (item->type < eNumVisibleUpgrades) // Make sure we're in a visible range
	{
		_jet[item->type].setMesh(item->mesh.c_str(), 0).
		addTextureForMesh(item->texDiffuse.c_str(), 0).
		addTextureForMesh(item->texNormal.c_str(), 0);

		if (item->type == eUpgradeWings)
		{
			_jet[item->type].setMesh(item->meshExtra.c_str(), 1).
			addTextureForMesh(item->texDiffuse.c_str(), 1).
			addTextureForMesh(item->texNormal.c_str(), 1);
		}
	}
}

void GarageRenderer::touchItemRoot(byte tag)
{
	if (_popupExclusive) return; // Lock if any popup is on

	_strip.removeKids(); // Remove any previous content, so don't mess up

	_currentRootItem = tag; // Store last touched root item, important

	// Show sub-items for current root item
	std::vector<UpgradeItem *> items = PlayerCareer::get()->itemSet((UpgradeType)tag);
	byte itemIndex = 0; // Means item tag actually, as items arrayed
	for (std::vector<UpgradeItem *>::iterator item=items.begin(); item!=items.end(); ++item)
	{
		_strip.addItem((*item)->icon.c_str(), itemIndex++, &GarageRenderer::touchItem);
	}

	_strip.setVisible(true);

	// By default, make the very first sub-item current
	_currentItem = PlayerCareer::get()->itemSet((UpgradeType)_currentRootItem)[0];
	_desc.setPrice(items[0]->pricePoints, items[0]->priceMoney);
	_desc.setName(items[0]->name.c_str());
	_desc.setDesc(items[0]->description.c_str());
	_desc.setVisible(true);
}

void GarageRenderer::touchReturn(byte tag)
{
	if (_popupExclusive) return; // Lock if any popup is on

	StateController::get()->setState(eStateMainMenu);
}

void GarageRenderer::touchMoney(byte tag)
{
	std::cout << "Money widget touched" << std::endl;
}

void GarageRenderer::touchesBegan(float touchX, float touchY)
{
	if (_popupExclusive) return; // Lock if any popup is on

/*
	UIView * v = StateController::get()->_view;
    for (UIView * sv in v.subviews)
    {
		if ([(NSString *)[sv tag] isEqualToString: @"strip"])
			[sv removeFromSuperview];	
    }
*/
}

void GarageRenderer::touchesEnded(float touchX, float touchY)
{
	if (_popupExclusive) return; // Lock if any popup is on

	_strip.setVisible(false);
//	_strip.removeKids();

	_desc.setVisible(false);
//	_desc.removeKids();
}
