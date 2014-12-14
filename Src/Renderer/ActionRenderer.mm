//
//  ActionRenderer.cpp
//  Kamikaze
//
//  Created by Max Reshetey on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "ActionRenderer.h"

#include "LevelFactory.h" // Level bodies and figures

#include "Misc.h"

#include "StateController.h"

#include "PlayerCareer.h" // Current upgrades

#import "basket.h"

#import "nestling.h"

// TODO: Init all vars properly in this section 
ActionRenderer::ActionRenderer() :
Renderer(),
bgTexCounter(eBackLeft+eBackRight),
//_speed(8.0f), // Initial flight speed, meters per second
_speed(0.0f), // Initial flight speed, meters per second
_speedPerFrame(0.0f),
_score(0),
_metersGone(0.0f)
//emitter("Smoke.pvr")
{
	//_levelFactory = new LevelFactory("Level1.xml");
    _levelFactory = new LevelFactory("payload1.xml");

	// Init Box2D
	World::alloc();
//	World::get()->SetWarmStarting(true); // For Box2d debug
	World::get()->SetAutoClearForces(true);
	World::get()->SetContactListener(this); // Set ourselves as collision listener

	// Preload meshes (for now its the only way to load meshes and avoid lags when framing)
	Mesh::preloadScene("front_objects.pod");
	Mesh::preloadScene("airplane_wood.pod");
	Mesh::preloadScene("airplane_plastic.pod");

	_jet = new Airplane(2.5f, 0.4f, -3.0f, 0.0f, 0.8f);

	UpgradeItem * item = PlayerCareer::get()->current(eUpgradeBody);

	_jet->addMesh(item->mesh.c_str()).
	addTexture(item->texDiffuse.c_str()).
	addTexture(item->texNormal.c_str()).
	addTexture("bloored-light-reflection-map").
	addMesh("pilot"). // TODO: Should be a separate body, to avoid reflecting
	addTexture(item->texDiffuse.c_str()).
	addTexture(item->texNormal.c_str()).
	addTexture("bloored-light-reflection-map");
//	addMesh("gun"). // TODO: Should be a separate body, to avoid reflecting
//	addTexture("gun_1_color.pvr").
//	addTexture("gun_1_nm.pvr").
//	addTexture("bloored-light-reflection-map");

	// Setup two parts of background textures
	_back[eBackLeft].setSize(kSceneWidth/2.0f, kSceneWidth/2.0f).setPosY(2.0f).setPosZ(kDepthBack).
	addMesh().addTexture(_levelFactory->backTex(eBackLeft), true);
	_back[eBackRight].setSize(kSceneWidth/2.0f, kSceneWidth/2.0f).setPosX(kSceneWidth).setPosY(2.0f).setPosZ(kDepthBack).
	addMesh().addTexture(_levelFactory->backTex(eBackRight), true);

	// Preload remaining bg parts, to avoid lags when lazy loading
	for (byte i=eBackRight+1; i<_levelFactory->numBackTex(); ++i)
	{ Texture(_levelFactory->backTex(i), true); }

	// Ground body, make it very long as we're moving the camera along X
//	_ground = new BodyBox2d(eBodyTypeStatic, eBodyShapeBox, kSceneWidth*2.0f, 0.5f, 0.0f, -kSceneHeight/2.0f);
	_ground = new BodyBox2d(eBodyTypeStatic, eBodyShapeBox, 5000.0f, 0.5f, 0.0f, -kSceneHeight/2.0f);

	// Widgets
	_joystick[eJoystickHeight].setSize(5.0f).setPos(-7.5f, -4.5f).setPosZ(kDepthHUD).addMesh().addTexture("height_meter");
	_joystick[eJoystickSlider].setSize(1.25f).setPos(-7.5f, -4.5f).setPosZ(kDepthHUD+0.1f).addMesh().addTexture("slider");

	_fireButton[eFireButtonSpinLayer].setSize(1.5f).setPos(8.0f, -5.5f).setPosZ(kDepthHUD).addMesh().addTexture("tomato_button_anim");
	_fireButton[eFireButtonBaseLayer].setSize(2.5f).setPos(8.0f, -5.5f).setPosZ(kDepthHUD+0.01f).addMesh().addTexture("strike_button");

	for (byte i = 0; i < eNumHPParts; ++i) { _hp[i].setSize(1.25f, 1.25f).setPosX(-8.0f).setPosY(5.5f).setPosZ(kDepthHUD+(float)i*0.1f); }
	_hp[eHPButton].addMesh().addTexture("button_bg");
	_hp[eHPFuselage].addMesh().addTexture("body");
	_hp[eHPPropeller].addMesh().addTexture("propeller");
	_hp[eHPWings].addMesh().addTexture("wings");
	_hp[eHPTail].addMesh().addTexture("small_wings");
	_hp[eHPFrame].addMesh().addTexture("blueprint");

	 // TODO: We have texture for released state
	_pauseButton.setSize(1.25f).setPos(-8.9f, 6.2f+0.5f).setPosZ(kDepthHUD+0.6f).addMesh().addTexture("pause_button");

	_speedometer[eSpeedometer].setSize(1.25f).setPos(-6.7f, 4.3f+0.5f).setPosZ(kDepthHUD+0.6f).
	addMesh().addTexture("speedometer");
	_speedometer[eSpeedometerArrow].setSize(1.25f).setPos(-6.7f, 4.3f+0.5f).setPosZ(kDepthHUD+0.7f).
	addMesh().addTexture("speedometer_arrow");

	_legend[eLegendHighscore].setSize(2.5f).setPos(5.0f, 6.5f).setPosZ(kDepthHUD).
	addMesh().addTexture("highscore");
	_legend[eLegendScore].setSize(1.25f).setPos(6.0f, 5.5f).setPosZ(kDepthHUD+0.1f).
	addMesh().addTexture("score");

	// Pause menu
	_menuPause.setSize(5.0f).setPosZ(kDepthHUD+1.0f).addMesh().addTexture("pause_popup");

	float offsetY = 0.3f;
	_menuPause.addSubWidget("resume", 2.5f, 0.75f, 0.0f, 2.0f+offsetY, kDepthHUD+1.1f).addMesh().addTexture("pause_resume");
	_menuPause.lastKid()->setTextureForTouched("pause_resume_released");

	_menuPause.addSubWidget("restart", 2.5f, 0.75f, 0.0f, 0.5f+offsetY, kDepthHUD+1.1f).addMesh().addTexture("pause_restart");
	_menuPause.lastKid()->setTextureForTouched("pause_restart_released");

	_menuPause.addSubWidget("settings", 2.5f, 0.75f, 0.0f, -1.0f+offsetY, kDepthHUD+1.1f).addMesh().addTexture("pause_settings");
	_menuPause.lastKid()->setTextureForTouched("pause_settings_released");

	_menuPause.addSubWidget("mainmenu", 2.5f, 0.75f, 0.0f, -2.5f+offsetY, kDepthHUD+1.1f).addMesh().addTexture("pause_main_menu");
	_menuPause.lastKid()->setTextureForTouched("pause_main_menu_released");

	// Level completion menu
	_menuEnd.setSize(10.0f).setPosZ(kDepthHUD+1.0f);
	_menuEnd.addMesh().addTexture("levelend_popup");

	offsetY = 0.0f;
	_menuEnd.addSubWidget("next", 2.5f, 0.75f, 6.5f, 2.0f+offsetY, kDepthHUD+1.1f).addMesh().addTexture("levelend_nextlevel");
	_menuEnd.lastKid()->setTextureForTouched("levelend_nextlevel_released");

	_menuEnd.addSubWidget("upgrade", 2.5f, 0.75f, 6.5f, 0.5f+offsetY, kDepthHUD+1.1f).addMesh().addTexture("levelend_upgrade");
	_menuEnd.lastKid()->setTextureForTouched("levelend_upgrade_released");

	_menuEnd.addSubWidget("restart", 2.5f, 0.75f, 6.5f, -1.0f+offsetY, kDepthHUD+1.1f).addMesh().addTexture("levelend_restart");
	_menuEnd.lastKid()->setTextureForTouched("levelend_restart_released");

	_menuEnd.addSubWidget("mainmenu", 2.5f, 0.75f, 6.5f, -2.5f+offsetY, kDepthHUD+1.1f).addMesh().addTexture("levelend_mainmenu");
	_menuEnd.lastKid()->setTextureForTouched("levelend_mainmenu_released");

	_menuEnd.addSubWidget("xpbar", 5.0f, 1.25f, -1.3f, -1.5f, kDepthHUD+1.1f).addMesh().addTexture("levelend_xpbar");
	_menuEnd.lastKid()->setTextureForTouched("levelend_xpbar");

	_menuEnd.addSubWidget("medal", 1.25f, 1.25f, -1.3f, -4.0f, kDepthHUD+1.11f).addMesh().addTexture("levelend_medal");
	_menuEnd.lastKid()->setTextureForTouched("levelend_medal");

	World::get()->SetGravity(b2Vec2(0.0f, -10.0f));

	// Basket and chain
	Mesh::preloadScene("basket.pod"); // Contains basket and chain

    if(payloadMission) {


		 // must be taken from level definition
			const GLfloat basketDensity = 7.01f; // heavier baskets are easier
		const int segments = 3;
		
		_chain = new Chain(.2f, 2.2f, segments, -.5f, -1.f);

        _basket = new Basket(1.f, 1.f, -.5f, -3.f, basketDensity);
        _basket->addMesh("container").
            addTexture("container_color.pvr").
			addTexture("container_nm.pvr");
        
        _chain->first()->createRevoluteJoint(0.f, 0.65f, _jet,
                                  -.5f, -.10f);

        _basket->createRevoluteJoint(0.f, .99 /* basket half height minus tiny bit */,
                                    _chain->last(),
                                    0.f, -.4f
			);
        _basket->adjJointLimit(180);
        _jet->adjJointLimit(180);
		_chain->last()->adjJointLimit(180);
		
        //_chain->first()->adjJointLimit(90);

        for(int ii=0;ii<MAXNESTLINGS;++ii) {
            m_nestlings[ii] = 0;
        }
        int nestlings = 3;
        assert(nestlings<=MAXNESTLINGS);
        for(int i=0;i<nestlings;++i) {
            m_nestlings[i] = new Nestling(.4f, .4f, -1.f, -3.f);
        }
    }
	glEnable(GL_CULL_FACE);
}

// Absence of leaks is our priority!
ActionRenderer::~ActionRenderer()
{
	if (_levelFactory) {
        delete _levelFactory; _levelFactory = 0;
    }
	World::release(); // This releases all allocated in the world
	Texture::release(); // Release all loaded textures
	Mesh::release(); // Release all loaded meshes and vbos

	if (_ground) {
        delete _ground; _ground = 0;
    }
	if (_jet) {
        delete _jet; _jet = 0;
    }
    for(int ii=0;ii<MAXNESTLINGS;++ii) {
        delete m_nestlings[ii];
    }
    delete _chain; _chain = 0;
    delete _basket; _basket=0;
}

void ActionRenderer::levelCompleted()
{
	_menuEnd.resetAnimation();
	
	int scorediff=0;
	if(payloadMission) {
		BOOL noneLost = YES;
		int survivorCount = 0;
		for(int ii=0;ii<MAXNESTLINGS;++ii) {
			if(m_nestlings[ii]) {
				GLfloat nestlingX=m_nestlings[ii]->posX(),
				nestlingY=m_nestlings[ii]->posY();
				GLfloat basketX=_basket->posX(), basketY=_basket->posY();
				
				GLfloat xdiff=nestlingX-basketX;
				GLfloat ydiff=nestlingY-basketY;
				GLfloat distanceSquared = xdiff*xdiff+ydiff*ydiff;
				
				NSLog(@"basketX %f nestlingX %f diffY %f %d ds %f",
					  basketX, nestlingX,
					  ydiff, (int)m_nestlings[ii]->isOn(),
					  distanceSquared);
				// I could conceivably just check fabs(xdiff)
				if(distanceSquared>.99f) {
					scorediff -= 10;
					noneLost =NO;
					// for all or nothing mission add instant failure
				}else{
					++survivorCount;
				}
			}
		}
		if(survivorCount<1) {
			scorediff = -_score;
			//implement("all nestlings are gone. level failed");
		}
			if(noneLost) {
				scorediff += 100; // bonus for no nestlings lost
			}
	}
	NSLog(@"animate score change %d (bonus/penalty)", scorediff);
	StateController::get()->setState(eStateActionCompleted);

}

// Timer each 0.2, update LevelManager with current position within a level
// TODO: Adjust if proves infrequent - 0.2s seems ok
void ActionRenderer::beat()
{
//	printf("Beat 0.2s, covered: %0.1f, speed: %0.1f m/s\n", _metersGone, _speed);
//	return ;

	if (StateController::get()->state() == eStateAction)
	{
		// If we've flown entire level, indicate we're done
		if (_metersGone > _levelFactory->getLevelLength())
		{
			levelCompleted();
			return;
		}

		_score += 1; // TODO: Do a proper point count
		_levelFactory->update(_metersGone);
	}
}

void ActionRenderer::frame()
{
	Renderer::preframe(); // Perform certain predrawing

	drawBack(); // Draw background

	_ground->push().ddraw().pop(); // Visualise ground surface, only for debugging

	// Moving section, this section will scroll as we fly
	MatrixManager::get()->pushMatrix();

	MatrixManager::get()->rotate(-5.0f, 0.0f, 1.0f, 0.0f);
	MatrixManager::get()->rotate(10.0f, 1.0f, 0.0f, 0.0f);

	// This must be done before scroll.

	// Move camera according to:
	// either the airplane position (airplane is moveless on screen)
//	MatrixManager::get()->translate(-_jet->posX(), 0.0f, 0.0f);
	// or meters covered (airplane is slightly moving within screen)
	MatrixManager::get()->translate(-_metersGone, 0.0f, 0.0f);

	_jet->push().draw().pop();
//	_jet->push().ddraw().pop();

	drawPool();

//	Chain::get()->draw();
//	float x = _jet->posX(), y = _jet->posY();
//	emitter.Update(0.000625);
//	static int frame = 0;
//	for (int i = 0; i < 4; i++)
//		emitter.EmitPoint(false, PVRTVec4(x - _metersGone + 3, y + 0.5, 0.0, 1.0), PVRTVec4(8, +2.0 * (float)rand() / RAND_MAX, 0.0, 1.0));

//	MatrixManager::get()->pushMatrix();
//		MatrixManager::get()->translate(+_metersGone, 0.0f, 0.0f);
//		emitter.Draw();
//	MatrixManager::get()->popMatrix();

	_basket->push().place().spinZ().draw(false).pop();
    
	_chain->draw(false, true);

	//_basket->push().ddraw(true, true).pop();
    for(int ii=0;ii<MAXNESTLINGS;++ii) {
        if(m_nestlings[ii]) {
            m_nestlings[ii]->push().place().spinZ().draw(false).pop();
            //m_nestlings[ii]->push().ddraw().pop();
        }
    }


	MatrixManager::get()->popMatrix();

	// Moveless section, draw HUD, etc here
	drawWidgets();
	drawScore();
	drawTime();

	if (StateController::get()->state() == eStateAction)
	{
		// The suggested iteration count for Box2D is 10 for both velocity and position
		World::get()->Step(1.0f/kTargetFPS, 10, 10);
//		World::get()->Step(1.0f/kTargetFPS, 1, 1);

		// TODO: We're under risk of counting wrong meters here, as it's unlikely we'd have
		// constant kTargetFPS throughout the action
		_speedPerFrame = _speed/kTargetFPS;
		_metersGone += _speedPerFrame; // As we're firing 60 times per sec

		_jet->setPosX(_metersGone); // Place here, to avoid skrewed motion when pause/unpause
		_jet->force(_speed*10.0f);
	}
	else if (StateController::get()->state() == eStateActionPaused)
	{
		drawMenuPause();
	}
	else if (StateController::get()->state() == eStateActionCompleted)
	{
		drawMenuCompletion();
	}
}

inline
void ActionRenderer::drawWidgets()
{
	glEnable(GL_BLEND); // All HUDs require blending =(

	ShaderManager::get()->useProgram(eShaderBasicTexture);
	_hp[eHPButton].push().draw();

	ShaderManager::get()->useProgram(eShaderBasicTextureColored);
	setHPColor(_jet->health()); _hp[eHPFuselage].draw(false);
	setHPColor((*_jet)[Airplane::eJetPropeller]->health()); _hp[eHPPropeller].draw(false);
	setHPColor((*_jet)[Airplane::eJetWings]->health()); _hp[eHPWings].draw(false);
	setHPColor((*_jet)[Airplane::eJetTail]->health());_hp[eHPTail].draw(false);
	_hp[eHPFrame].draw(false).pop();

	ShaderManager::get()->useProgram(eShaderBasicTexture);
	_joystick[eJoystickHeight].push().draw().pop();
	_joystick[eJoystickSlider].push().spinZ().draw().pop();

	_fireButton[eFireButtonSpinLayer].push().place().spinZ(false, 1.0f, true).draw(false).pop();
	_fireButton[eFireButtonBaseLayer].push().draw().pop();

	_pauseButton.push().draw().pop();

	_speedometer[eSpeedometer].push().draw();
	_speedometer[eSpeedometerArrow].spinZ().push().draw(false).pop().pop();

	_legend[eLegendHighscore].push().draw().pop();
	_legend[eLegendScore].push().draw().pop();

	glDisable(GL_BLEND);
}

// Add min(color, 1.0f) to clamp all > 1, if this works bad
inline
GLvoid ActionRenderer::setHPColor(float health)
{
	glUniform4f(ShaderManager::get()->program()->uniforms[uniLightColor], (100.0f-health)*0.02f, health*0.02f, 0.0f, (GLfloat)(health>0.0f));
}

// TODO: Think about efficient releasing  of the drawing pool!
inline
void ActionRenderer::drawPool()
{
//	ShaderManager::get()->useProgram(eShaderNormalReflectMapping);
	ShaderManager::get()->useProgram(eShaderNormalMapping);
	setLightColor();
	setLightPos();
	BodyBox2d * body = 0;
//	for (byte i = 0; i < _levelFactory->drawCount(); ++i)
	for (byte i = 0; i < 50; ++i) // TODO: We still traverse entire array!
	{
		body = _levelFactory->drawPool(i);
		if (body && body->isOn())
		{
			body->push().
			place();
			MatrixManager::get()->rotate(15.0f, 1.0f, 1.0f, 0.0f);
			(body)->spin().draw(false).
			pop();
		}
	}
}

// TODO: Derive separate Background class, which has all bg parts preloaded, so we don't
// search entire tex map upon each tex part swap!
inline
void ActionRenderer::drawBack()
{
	// Divide speed by kTargetFPS, as we're drawing 1/kTargetFPS, but speed is in m/s
	if (StateController::get()->state() == eStateAction)
	{
		for (byte i = 0; i < eNumBackParts; ++i) _back[i].adjPosX(-_speedPerFrame*0.7f); // Back should move a bit slower

		// Scroll-Reset calculations
		if (_back[eBackLeft].posX() < -kSceneWidth)
		{ // If texture part has gone left out of screen, reset it from the right
			if (++bgTexCounter > _levelFactory->numBackTex()-1) { bgTexCounter = 0; }
			_back[eBackLeft].setPosX(kSceneWidth + _back[eBackRight].posX() - _speedPerFrame). // Important to subtract the speed!
			setTexture(_levelFactory->backTex(bgTexCounter), true);
		}
		else if (_back[eBackRight].posX() < -kSceneWidth)
		{
			if (++bgTexCounter > _levelFactory->numBackTex()-1) { bgTexCounter = 0; }
			_back[eBackRight].setPosX(kSceneWidth + _back[eBackLeft].posX()).
			setTexture(_levelFactory->backTex(bgTexCounter), true);
		}
	}

	ShaderManager::get()->useProgram(eShaderBasicTexture);
	for (byte i = 0; i < eNumBackParts; ++i) _back[i].push().draw().pop();
}

inline
void ActionRenderer::drawTime()
{
	static char buf[10];
	CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
	CFGregorianUnits t = CFAbsoluteTimeGetDifferenceAsGregorianUnits(now, _renderStarted, NULL, (kCFGregorianUnitsMinutes | kCFGregorianUnitsSeconds));

	sprintf(buf, (t.seconds<9.5f)?"%.0f:0%.0f":"%.0f:%.0f", (GLfloat)t.minutes, (GLfloat)t.seconds);
	printer.Print3D(-0.7f, 6.5f, 2.0f, 0xFFFFFFFF, buf);

	// TODO: Really its not a place for this
	sprintf(buf, "%.1f", _metersGone);
	printer.Print3D(-kSceneWidth/2.0f+0.3f, kSceneHeight/2.0f-1.5f, 1.0f, 0xFFFFFFFF, buf);
}

inline
void ActionRenderer::drawScore()
{
	static char buf[10];
	sprintf(buf, "%d", _score);
	printer.Print3D(7.1f, 6.6f, 1.5f, 0xFFFFFFFF, "25530"); // Highscore
	printer.Print3D(7.1f, 5.6f, 1.5f, 0xFFFFFFFF, buf); // Score
	printer.Flush();
}

inline
void ActionRenderer::drawMenuPause()
{
	ShaderManager::get()->useProgram(eShaderBasicTexture);

	glEnable(GL_BLEND);
	_menuPause.drawAnimated();
	glDisable(GL_BLEND);
}

inline
void ActionRenderer::drawMenuCompletion()
{
	ShaderManager::get()->useProgram(eShaderBasicTexture);

	glEnable(GL_BLEND);
	_menuEnd.drawAnimated();
	glDisable(GL_BLEND);
}

// TODO: How do u know BodyA is always an airplane?? It's not!!!
// This is called when two fixtures begin to overlap.
// This is called for sensors and non-sensors.
// This event can only occur inside the time step.
void ActionRenderer::BeginContact(b2Contact * contact)
{
//	_score++;

	b2Fixture * fixture = 0;
	BodyBox2d * bodyA, * bodyB;

	fixture = contact->GetFixtureA();
	bodyA = (BodyBox2d *)fixture->GetBody()->GetUserData();

	fixture = contact->GetFixtureB();
	bodyB = (BodyBox2d *)fixture->GetBody()->GetUserData();

//	if (/*bodyA->shape() == eBodyShapeAirplane || bodyA->shape() == eBodyShapeComplex*/false)
//	{
//		bodyB->linearImpulse(1.0f, 1.0f);
		
//	}
//	else if (bodyB->shape() == eBodyShapeAirplane /*|| bodyA->shape() == eBodyShapeComplex*/)
//	{
//		bodyA->linearImpulse(1.0f, 1.0f);
//	
//	}


/*
	// Are we lucky, to guess the airplane?
	fixture = contact->GetFixtureA();
	body = (BodyBox2d *)fixture->GetBody()->GetUserData();

	if (!body->joint())
	{ // No =)

		
		fixture = contact->GetFixtureA();
		body = (BodyBox2d *)fixture->GetBody()->GetUserData();

		// This is not airplane at all
		if (!body->joint()) return ;
	}
	printf("Collide with plane!\n");

	// Decrease score if we've collided with something
	if (_score > 5) _score -= 5;

	body->adjHealth(-5.0f); // Decrease part health

	// Carefully here, once crashed:
	// In b2RevoluteJoint::SetLimits (this=0x327a4f8d, lower=-0.00999999978, upper=0.00999999978)
	body->adjJointLimit(0.01f); // Increase joint spinning angle
*/
    if(payloadMission) {
        if(bodyA == _ground || bodyB == _ground) {
            for(int ii=0;ii<MAXNESTLINGS;++ii) {
                if(bodyA == m_nestlings[ii] || bodyB == m_nestlings[ii]) {
                    TODO("start \"nestling is out of the basket\" animation");
                    // now it's all or nothing mission
                    //StateController::get()->setState(eStateMainMenu);
                }
            }
        }
    }
}

void ActionRenderer::touchesBegan(float touchX, float touchY)
{
	if (StateController::get()->state() == eStateAction)
	{
		if (_joystick[eJoystickHeight].isTouched(touchX, touchY))
		{
			// We have a 512p joystick widget texture placed on screen in a way,
			// that we have more place to move up, than down (-150.0f, +256.0f)
			// Hence, widen lower limit a bit (precalculated manually), so that both
			// up and down are of ~200p
			float localY = _joystick[eJoystickHeight].getLocalTouchY(touchY)-50.0f; // Widen lower limit a bit (precalculated manually)

			_jet->setPosY(localY * 2.0f * Settings::get()->meterFactor());
			_joystick[eJoystickSlider].setAngle(-localY * 0.15f);
		}
		else if (_fireButton[eFireButtonBaseLayer].isTouched(touchX, touchY))
		{
			_fireButton[eFireButtonBaseLayer].setTexture("strike_button_released");
		}
	}
	else if (StateController::get()->state() == eStateActionPaused)
	{
// TODO: Uncomment to allow pause dismissal by clicking on pause button again
//		if (_pauseButton->isTouched(touchX, touchY))
//		{
//			StateController::get()->setState(eStateAction);
//		}
		_menuPause.isKidTouched(touchX, touchY); // Just to highlight touched widget
	}
	else if (StateController::get()->state() == eStateActionCompleted)
	{
		_menuEnd.isKidTouched(touchX, touchY); // Just to highlight touched widget
	}
}

// TODO: Keep onMove event as short as possible
void ActionRenderer::touchesMoved(float touchX, float touchY)
{
	// Only allow moves for joystick, and when action is active
	if (StateController::get()->state() == eStateAction)
	{
		if (_joystick[eJoystickHeight].isTouched(touchX, touchY))
		{
			float localY = _joystick[eJoystickHeight].getLocalTouchY(touchY)-50.0f;

			_jet->setPosY(localY*2.0f * Settings::get()->meterFactor());
			_joystick[eJoystickSlider].setAngle(-localY*0.15f);
		}
	}
}

void ActionRenderer::touchesEnded(float touchX, float touchY)
{
	if (StateController::get()->state() == eStateAction)
	{
		if (_fireButton[eFireButtonBaseLayer].isTouched(touchX, touchY))
		{
			_fireButton[eFireButtonBaseLayer].setTexture("strike_button");
		}
		else if (_pauseButton.isTouched(touchX, touchY))
		{
			_menuPause.resetAnimation();
			StateController::get()->setState(eStateActionPaused);
		}
	}
	else if (StateController::get()->state() == eStateActionPaused)
	{
		Widget * widget = _menuPause.isKidUntouched(touchX, touchY);

		if (!widget) return; // If no kid touched, exit right away

		// Strings should be ok
		if (widget->tag() == "resume")
		{
			printf("Resume the Action - NOW\n");
			StateController::get()->setState(eStateAction); // Continue the action
		}
		else if (widget->tag() == "restart")
		{
			printf("Restart the Action - NOW\n");
			StateController::get()->setState(eStateActionNeedsRestart);
		}
		else if (widget->tag() == "mainmenu")
		{
			StateController::get()->setState(eStateMainMenu);
		}
		else if (widget->tag() == "settings")
		{
			printf("Goto Settings - NOW\n");
		}
	}
	else if (StateController::get()->state() == eStateActionCompleted)
	{
		Widget * widget = _menuEnd.isKidUntouched(touchX, touchY);
		if (!widget) return;

		if (widget->tag() == "next")
		{
			printf("Goto the next level - NOW\n");
//			StateController::get()->setState(eStateActionNeedsRestarted);
		}
		else if (widget->tag() == "upgrade")
		{
			printf("Goto the Garage - NOW\n");
			StateController::get()->setState(eStateGarage);
		}
		else if (widget->tag() == "restart")
		{
			printf("Restart the Action - NOW\n");
			StateController::get()->setState(eStateActionNeedsRestart);
		}
		else if (widget->tag() == "mainmenu")
		{
			StateController::get()->setState(eStateMainMenu);
		}
	}
}

void ActionRenderer::accel(float x, float y, float z)
{
	y = -y;

	const static float lower = 2.0f, upper = 15.0f;

	// These lockers are very reliable
	if ((_speed > lower && _speed < upper) || // Lock to allowed speed range
		(_speed <= lower && y > 0.0f || _speed >= upper && y < 0.0f)) // Lock to only change if inside of range
	{
		_speed += y*0.5f;
		_speedometer[eSpeedometerArrow].adjAngle(-y*30.0f);
	}
}
