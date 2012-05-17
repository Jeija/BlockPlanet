/*
Blockplanet
Copyright (C) 2010-2012 Jeija, Florian Euchner <norrepli@gmail.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

#ifndef PARTICLES_HEADER
#define PARTICLES_HEADER

#define DIGGING_PARTICLES_AMOUNT 10

#include "common_irrlicht.h"
#include <iostream>

class Particles : public scene::ISceneNode
{
public:
	Particles(
		IGameDef* gamedef,
		scene::ISceneManager* mgr,
		LocalPlayer *player,
		s32 id,
		v3f pos,
		v3f velocity,
		v3f acceleration,
		float expirationtime
	);

	~Particles();

	/*
		ISceneNode methods
	*/

	virtual void OnRegisterSceneNode();

	virtual void render();
	
	virtual const core::aabbox3d<f32>& getBoundingBox() const
	{
		return m_box;
	}

	virtual u32 getMaterialCount() const
	{
		return 1;
	}

	virtual video::SMaterial& getMaterial(u32 i)
	{
		return m_material;
	}
	/*
		Other stuff
	*/

	void step(float dtime);

	float timer;

	float expiration;

private:
	IGameDef *m_gamedef;
	core::aabbox3d<f32> m_box;
	video::SMaterial m_material;
	v3f m_pos;
	v3f m_velocity;
	v3f m_acceleration;
	int tex_x0;
	int tex_x1;
	int tex_y0;
	int tex_y1;
	LocalPlayer *m_player;
};

Particles *allparticles[400]= {NULL};

void addParticle(IGameDef* gamedef, scene::ISceneManager* smgr, LocalPlayer *player, v3f pos, v3f velocity, v3f acceleration, float expirationtime);
void addDiggingParticles(IGameDef* gamedef, scene::ISceneManager *smgr, LocalPlayer *player, v3f pos);

#endif

