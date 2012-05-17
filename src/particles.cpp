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

#include "particles.h"
#include "constants.h"
#include "debug.h"
#include "main.h" // For g_profiler and g_settings
#include "settings.h"
#include "tile.h"
#include "gamedef.h"
#include <stdlib.h>

Particles::Particles(
	IGameDef *gamedef,
	scene::ISceneManager* smgr,
	LocalPlayer *player,
	s32 id,
	v3f pos,
	v3f velocity,
	v3f acceleration,
	float expirationtime
):
	scene::ISceneNode(smgr->getRootSceneNode(), smgr, id)
{
	m_material.setFlag(video::EMF_LIGHTING, false);
	//m_material.setFlag(video::EMF_BACK_FACE_CULLING, false);
	m_material.setFlag(video::EMF_BACK_FACE_CULLING, false);
	m_material.setFlag(video::EMF_BILINEAR_FILTER, false);
	//m_material.setFlag(video::EMF_FOG_ENABLE, true);
	//m_material.setFlag(video::EMF_ANTI_ALIASING, true);
	//m_material.MaterialType = video::EMT_TRANSPARENT_VERTEX_ALPHA;
	//m_material.MaterialType = video::EMT_TRANSPARENT_ALPHA_CHANNEL;
	m_box = core::aabbox3d<f32>(-BS/2, -BS/2, -BS/2, BS, BS, BS);
	m_pos = pos;
	m_velocity = velocity;
	m_acceleration = acceleration;
	m_gamedef = gamedef;

	AtlasPointer ap = m_gamedef->tsrc()->getTexture("default_wood.png");
	video::ITexture* texture = ap.atlas;
	m_material.setTexture(0, texture);
	tex_x0=ap.x0()+(ap.x1()-ap.x0())*rand()/2;
	tex_x1=ap.x1()+(ap.x1()-ap.x0())*rand();
	tex_y0=ap.y0()+(ap.y1()-ap.y0())*rand()/2;
	tex_y1=ap.y1()+(ap.y1()-ap.y0())*rand();
	expiration = expirationtime;
	timer = 0;
	m_player = player;
	printf("NEW PARTICLE\n");
	for (u16 i=0; i < 400; i++)
	{
		if (allparticles[i]==NULL)
		{
			allparticles[i] = this;
			break;
		}
	}
}

Particles::~Particles()
{
}

void Particles::OnRegisterSceneNode()
{
	//SceneManager->registerNodeForRendering(this, scene::ESNRP_TRANSPARENT);
	SceneManager->registerNodeForRendering(this, scene::ESNRP_SOLID);

	ISceneNode::OnRegisterSceneNode();
}

void Particles::render()
{
	video::IVideoDriver* driver = SceneManager->getVideoDriver();

	//if(SceneManager->getSceneNodeRenderPass() != scene::ESNRP_TRANSPARENT)
	if(SceneManager->getSceneNodeRenderPass() != scene::ESNRP_SOLID)
		return;

	AtlasPointer ap = m_gamedef->tsrc()->getTexture("default_wood.png");
	video::ITexture* texture = ap.atlas;
	m_material.setTexture(0, texture);

	driver->setTransform(video::ETS_WORLD, AbsoluteTransformation);
	driver->setMaterial(m_material);

	video::SColor c(255, 255, 255, 255);

	int s = BS/2;
	video::S3DVertex particle[4] =
	{
		video::S3DVertex(0,0,0, 0,0,0, c, 
		tex_x0, tex_y0),
		video::S3DVertex(s,0,0, 0,0,0, c, 
		tex_x1, tex_y0),
		video::S3DVertex(0,0,s, 0,0,0, c, 
		tex_x0, tex_y1),
		video::S3DVertex(s,0,s, 0,0,0, c, 
		tex_x1, tex_y1),
	};

	for(u16 i=0; i<4; i++)
	{
		particle[i].Pos.rotateYZBy(m_player->getPitch()+90);
		particle[i].Pos.rotateXZBy(m_player->getYaw());
		particle[i].Pos += m_pos*BS;
	}

	u16 indices[] = {0,1,2,2,3,0};
	driver->drawVertexPrimitiveList(particle, 4, indices, 2,
			video::EVT_STANDARD, scene::EPT_TRIANGLES, video::EIT_16BIT);
}

void Particles::step(float dtime)
{
	timer += dtime;
	m_velocity += m_acceleration * dtime;
	m_pos += m_velocity * dtime;
}

void addParticle(IGameDef* gamedef, scene::ISceneManager* smgr, LocalPlayer *player, v3f pos, v3f velocity, v3f acceleration, float expirationtime)
{
	Particles *particle;
	particle = new Particles(gamedef, smgr, player, time(0), pos, velocity, acceleration, expirationtime);
}

void addDiggingParticles(IGameDef* gamedef, scene::ISceneManager *smgr, LocalPlayer *player, v3s16 pos)
{
	v3f newpos(0,0,0);
	v3f velocity(0,0,0);
	v3f acceleration(0,0,0);

	for (u16 i=1; i<=DIGGING_PARTICLES_AMOUNT; i++)
	{
		newpos = v3f(
			(f32)pos.X + myrand_range(-50, 50)/100*BS,
			(f32)pos.Y + myrand_range(-25, 25)/100*BS,
			(f32)pos.Z + myrand_range(-50, 50)/100*BS
		);
		velocity = v3f(0, 6, 0);
		acceleration = v3f(0, -2, 0);

		addParticle(gamedef, smgr, player, newpos, velocity, acceleration, 10); 
	}
}
