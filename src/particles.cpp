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

Particles::Particles(
		scene::ISceneNode* parent,
		scene::ISceneManager* mgr,
		s32 id
):
	scene::ISceneNode(parent, mgr, id),
	m_time(0)
{
	m_material.setFlag(video::EMF_LIGHTING, false);
	//m_material.setFlag(video::EMF_BACK_FACE_CULLING, false);
	m_material.setFlag(video::EMF_BACK_FACE_CULLING, true);
	m_material.setFlag(video::EMF_BILINEAR_FILTER, false);
	m_material.setFlag(video::EMF_FOG_ENABLE, true);
	m_material.setFlag(video::EMF_ANTI_ALIASING, true);
	//m_material.MaterialType = video::EMT_TRANSPARENT_VERTEX_ALPHA;
	m_material.MaterialType = video::EMT_TRANSPARENT_ALPHA_CHANNEL;
	m_box = core::aabbox3d<f32>(0,0,0,
			BS/10,BS/10,BS/10);
}

Particles::~Particles()
{
}

void Particles::OnRegisterSceneNode()
{
	SceneManager->registerNodeForRendering(this, scene::ESNRP_TRANSPARENT);
	//SceneManager->registerNodeForRendering(this, scene::ESNRP_SOLID);

	ISceneNode::OnRegisterSceneNode();
}

#define MYROUND(x) (x > 0.0 ? (int)x : (int)x - 1)

void Particles::render()
{
	video::IVideoDriver* driver = SceneManager->getVideoDriver();

	if(SceneManager->getSceneNodeRenderPass() != scene::ESNRP_TRANSPARENT)
	//if(SceneManager->getSceneNodeRenderPass() != scene::ESNRP_SOLID)
		return;

	driver->setTransform(video::ETS_WORLD, AbsoluteTransformation);
	driver->setMaterial(m_material);

	video::SColor c(255, 255, 255, 255);

	video::S3DVertex particle[4] =
	{
		video::S3DVertex(0,0,0, 0,0,0, c, 1, 1),
		video::S3DVertex(BS/10,0,0, 0,0,0, c, 0, 1),
		video::S3DVertex(0,0,BS/10, 0,0,0, c, 0, 1),
		video::S3DVertex(BS/10,0,BS/10, 0,0,0, c, 0, 0)
	};

	
	u16 indices[] = {0,1,2,2,3,0};
	driver->drawVertexPrimitiveList(particle, 4, indices, 2,
			video::EVT_STANDARD, scene::EPT_TRIANGLES, video::EIT_16BIT);
}

void Particles::step(float dtime)
{
	m_time += dtime;
}
