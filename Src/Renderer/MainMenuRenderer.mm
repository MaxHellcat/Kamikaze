//
//  MainMenuRenderer.cpp
//  Kamikaze
//
//  Created by Max Reshetey on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "MainMenuRenderer.h"

#include "StateController.h"


MainMenuRenderer::MainMenuRenderer()
{
	if (StateController::get()->state() == eStateMainMenu)
	{
		_back.setSize(kSceneWidth/2.0f).setPosZ(kDepthBack).addMesh().addTexture("menu_bg");

		_back.addSubWidget("play", 2.5f, 2.5f, -4.0f, -5.0f, kDepthHUD).addMesh().addTexture("menu_play_button");
		_back.lastKid()->setTextureForTouched("menu_play_button_released");
		_back.addSubWidget("garage", 2.5f, 2.5f, 4.0f, -5.0f, kDepthHUD).addMesh().addTexture("menu_garage_button");
		_back.lastKid()->setTextureForTouched("menu_garage_button");

//		_handle.setSize(5.0f).setPos(4.0f+1.7f, -5.0f+2.3f).setPosZ(kDepthHUD+0.01f).addMesh().addTexture("menu_garage_handle");
		_handle.setSize(5.0f).setPos(6.5f, -4.6f).setPosZ(kDepthHUD+0.01f).addMesh().addTexture("menu_garage_handle");

		// Place out of screen to provoke randomly set position
		_clouds[eCloud1].setSize(5.0f).setPos(-7.0f, 2.0f).setPosZ(kDepthHUD+0.02f).addMesh().addTexture("menu_cloud_1");
		_clouds[eCloud2].setSize(5.0f).setPos(0.0f, -1.0f).setPosZ(kDepthHUD+0.03f).addMesh().addTexture("menu_cloud_2");
		_clouds[eCloud3].setSize(5.0f).setPos(6.0f, 4.0f).setPosZ(kDepthHUD+0.04f).addMesh().addTexture("menu_cloud_3");

		_flashes[eFlash1].setSize(2.5f).setPos(-5.0f, 0.0f).setPosZ(kDepthHUD+0.05f).addMesh().addTexture("menu_lightning_1");
		_flashes[eFlash2].setSize(2.5f).setPos(5.0f, 2.0f).setPosZ(kDepthHUD+0.05f).addMesh().addTexture("menu_lightning_2");

		_plane.setSize(5.0f).setPos(0.0f, 0.0f).setPosZ(kDepthHUD+0.1f).addMesh().addTexture("menu_airplane");
		_planeSmall.setSize(2.5f).setPos(-5.0f, 5.0f).setPosZ(kDepthBack+0.01f).addMesh().addTexture("airplane_small");
	}
	else if (StateController::get()->state() == eStateSplash)
	{
		_splash[eSplashBack].setSize(kSceneWidth/2.0f).addMesh().addTexture("splash");
		_splash[eSplashLoadLine].setSize(2.5f).setPos(-2.1f, 3.3f).setPosZ(0.01f).addMesh().addTexture("splash_progress");
		_splash[eSplashPilot].setSize(5.0f).setPos(1.7f, -0.2f).setPosZ(0.02f).addMesh().addTexture("splash_pilot");
	}
}

MainMenuRenderer::~MainMenuRenderer()
{
	Texture::release(); // Release loaded textures
	Mesh::release(); // Release loaded vbos
}

void MainMenuRenderer::eventHertzOne()
{
/*
	for (byte i=0; i<eNumClouds; ++i)
	{
		if (_clouds[i].posX() < -kSceneWidth/2.0f-3.0f)
		{
			float posY = randomFloat(0.0f, 8.0f);
//			float posX = randomFloat(3.0f, 5.0f);
			_clouds[i].setPosY(posY);
			_clouds[i].setPosX(kSceneWidth/2.0f+4.0f);
		}
	}
*/
	if (_planeSmall.posX() > kSceneWidth/2.0f+15.0f)
	{
		float posY = randomFloat(0.0f, 8.0f);
		_planeSmall.setPosY(posY);
		_planeSmall.setPosX(-kSceneWidth/2.0f-15.0f);
	}

}

void MainMenuRenderer::frame()
{
	Renderer::preframe();

	glEnable(GL_BLEND);

	if (StateController::get()->state() == eStateMainMenu) // Draw main main menu itself
	{
		ShaderManager::get()->useProgram(eShaderBasicTexture);
//		ShaderManager::get()->useProgram(eShaderBasicTextureColored);

		static float smallRot = 0.0f; smallRot+=0.01f;
		_back.push().draw().pop();
		_planeSmall.push().adjPosX(0.05f).place(false, 0.0f, sinf(smallRot)).scale(0.5f).draw().pop();

		static float handleRot = 0.0f; handleRot+=0.05f;
		_handle.push().
		place().place(false, -2.5f).spinZ(false, sinf(handleRot)).place(false, 2.5f).
		draw(false).
		pop();

//		glUniform4f(ShaderManager::get()->program()->uniforms[uniLightColor], 1.0f, 1.0f, 1.0f, 0.5f);

		static float f = 0.0f; f += 0.03f;

		for (byte i=0; i<eNumClouds; ++i)
		{
			_clouds[i].push().
//			adjPosX(-0.005f).
			place(false, 0.0f, sinf(f)*0.1f).draw().
			pop();
		}

//		for (byte i=0; i<eNumClouds; ++i)
//			_flashes[i].push().place(false, 0.0f, sinf(f)*0.1f).draw().pop();

		_plane.push().place(false, 0.0f, -sinf(f)*0.1f).draw().pop();

//		if (_frames > 1*kTargetFPS)
//			StateController::get()->setState(eStateAction);
	}
	else if (StateController::get()->state() == eStateSplash)
	{
		// Draw splash screen here
		ShaderManager::get()->useProgram(eShaderBasicTexture);

		_splash[eSplashBack].push().draw().pop();
		_splash[eSplashLoadLine].push().spinZ(false, 1.0f, true).draw().pop();
		_splash[eSplashPilot].push().draw().pop();

		if (_frames > 0.2f*kTargetFPS)
			StateController::get()->setState(eStateMainMenu);
	}
	glDisable(GL_BLEND);

	printer.Flush(); // Kids must call flush eventually
}

void MainMenuRenderer::touchesBegan(float touchX, float touchY)
{
	Widget * button = _back.isKidTouched(touchX, touchY);

	if (button) {}
}

void MainMenuRenderer::touchesEnded(float touchX, float touchY)
{
	Widget * button = _back.isKidUntouched(touchX, touchY);

	if (button)
	{
		if (button->tag() == "play")
		{
			// TODO: Add some animation, e.g. screen darking (now micro-freezes badly)
			StateController::get()->setState(eStateAction);
		}
		else if (button->tag() == "garage")
		{
			// TODO: Add some animation, e.g. screen darking
			StateController::get()->setState(eStateGarage);
		}
	}
}
