mrmin = -5
mrmax = 5

function activate_if_tnt(nname, np, tnt_np, tntr)
    if nname == "experimental:tnt" or nname == "nuke:hardcore_iron_tnt" or nname == "nuke:hardcore_mese_tnt" then
        local e = minetest.env:add_entity(np, nname)
        e:setvelocity({x=(np.x - tnt_np.x)*3+(tntr / 4), y=(np.y - tnt_np.y)*3+(tntr / 3), z=(np.z - tnt_np.z)*3+(tntr / 4)})
     else if nname == "nuke:iron_tnt" then
      gop = "nuke:iron_tnt2"
      local e = minetest.env:add_entity(np, gop)
      e:setvelocity({x=(np.x - tnt_np.x)*1+(tntr / 4), y=(np.y - tnt_np.y)*1+(tntr / 3), z=(np.z - tnt_np.z)*1+(tntr / 4)})
    else if nname == "nuke:mese_tnt" then
      gop2 = "nuke:mese_tnt2"
      local e = minetest.env:add_entity(np, gop2)
      e:setvelocity({x=(np.x - tnt_np.x)*1+(tntr / 4), y=(np.y - tnt_np.y)*1+(tntr / 3), z=(np.z - tnt_np.z)*1+(tntr / 4)})
    else if nname == "nuke:tnt" then
     gop2 = "nuke:tnt2"
     local e = minetest.env:add_entity(np, gop2)
     e:setvelocity({x=(np.x - tnt_np.x)*1+(tntr / 4), y=(np.y - tnt_np.y)*1+(tntr / 3), z=(np.z - tnt_np.z)*1+(tntr / 4)})
    end
end
end
end
end

function do_tnt_physics(tnt_np,tntr)
    local objs = minetest.env:get_objects_inside_radius(tnt_np, tntr)
    for k, obj in pairs(objs) do
        local oname = obj:get_entity_name()
        local v = obj:getvelocity()
        local p = obj:getpos()
        if oname == "nuke:tnt" or oname == "nuke:iron_tnt" or oname == "nuke:mese_tnt" or oname == "nuke:hardcore_iron_tnt" or oname == "nuke:hardcore_mese_tnt" then
            obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 2) + v.x, y=(p.y - tnt_np.y) + tntr + v.y, z=(p.z - tnt_np.z) + (tntr / 2) + v.z})
        else
            if v ~= nil then
                obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 4) + v.x, y=(p.y - tnt_np.y) + (tntr / 2) + v.y, z=(p.z - tnt_np.z) + (tntr / 4) + v.z})
            else
                if obj:get_player_name() ~= nil then
                    obj:set_hp(obj:get_hp() - 1)
                end
            end
        end
    end
end

-- Normal TNT
minetest.register_craft({
	output = 'node "nuke:tnt" 4',
	recipe = {
		{'craft "gun_powder:gun_powder" 1','node "default:sand" 1','craft "gun_powder:gun_powder" 1'},
		{'node "default:sand" 1','craft "gun_powder:gun_powder" 1','node "default:sand" 1'},
		{'craft "gun_powder:gun_powder" 1','node "default:sand" 1','craft "gun_powder:gun_powder" 1'}
	}
})
minetest.register_node("nuke:tnt", {
	tile_images = {"tnt_top.png", "tnt_bottom.png",
			"tnt_side.png", "tnt_side.png",
			"tnt_side.png", "tnt_side.png"},
	inventory_image = minetest.inventorycube("tnt_top.png",
			"tnt_side.png", "tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Iron TNT",
})

minetest.register_on_punchnode(function(p, node)
	if node.name == "nuke:tnt" then
		minetest.env:remove_node(p)
		minetest.env:add_entity(p, "nuke:tnt")	
			end
		--minetest.env:add_entity(p, "nuke:iron_tnt2") <-in case you forget
		nodeupdate(p)
end)

local TNT_RANGE = 8
local TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"tnt_top.png", "tnt_bottom.png",
			"tnt_side.png", "tnt_side.png",
			"tnt_side.png", "tnt_side.png"},
	-- Initial value for our timer
	timer = 0,
	-- Number of punches required to defuse
	health = 1,
	blinktimer = 0,
	blinkstatus = true,
}
function TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
	
end

function TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 8 then
	minetest.sound_play("nuke_tnt",
	{pos = pos, gain = 0.3, max_hear_distance = 32,})
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)
        do_tnt_physics(pos, TNT_RANGE)
        if minetest.env:get_node(pos).name == "default:water_source" or minetest.env:get_node(pos).name == "default:water_flowing" then
            -- Cancel the Explosion
            self.object:remove()
            return
        end
        for x=-TNT_RANGE,TNT_RANGE do
        for y=-TNT_RANGE,TNT_RANGE do
        for z=-TNT_RANGE,TNT_RANGE do
            if x*x+y*y+z*z <= (TNT_RANGE + math.floor(math.random(mrmin,mrmax))) * (TNT_RANGE + math.floor(math.random(mrmin,mrmax))) + (TNT_RANGE + math.floor(math.random(mrmin,mrmax))) then
                local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
                local n = minetest.env:get_node(np)
                if n.name ~= "air" then
                    minetest.env:remove_node(np)
                end
                activate_if_tnt(n.name, np, pos, TNT_RANGE)
            end
        end
        end
        end
		self.object:remove()
	end
end
minetest.register_entity("nuke:tnt", TNT)

----- ACTIVATED BY OTHER TNT
local TNT2_RANGE = 8
local TNT2 = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"tnt_top.png", "tnt_bottom.png",
			"tnt_side.png", "tnt_side.png",
			"tnt_side.png", "tnt_side.png"},
	-- Initial value for our timer
	timer = 9,
	-- Number of punches required to defuse
	health = 1,
	blinktimer = 9,
	blinkstatus = true,
}
function TNT2:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
	
end

function TNT2:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 8 then
	minetest.sound_play("nuke_tnt",
	{pos = pos, gain = 0.3, max_hear_distance = 32,})
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)
        do_tnt_physics(pos, TNT_RANGE)
        if minetest.env:get_node(pos).name == "default:water_source" or minetest.env:get_node(pos).name == "default:water_flowing" then
            -- Cancel the Explosion
            self.object:remove()
            return
        end
        for x=-TNT_RANGE,TNT_RANGE do
        for y=-TNT_RANGE,TNT_RANGE do
        for z=-TNT_RANGE,TNT_RANGE do
            if x*x+y*y+z*z <= (TNT_RANGE + math.floor(math.random(mrmin,mrmax))) * (TNT_RANGE + math.floor(math.random(mrmin,mrmax))) + (TNT_RANGE + math.floor(math.random(mrmin,mrmax))) then
                local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
                local n = minetest.env:get_node(np)
                if n.name ~= "air" then
                    minetest.env:remove_node(np)
                end
                activate_if_tnt(n.name, np, pos, TNT_RANGE)
            end
        end
        end
        end
		self.object:remove()
	end
end
minetest.register_entity("nuke:tnt2", TNT2)

-- Iron TNT

minetest.register_craft({
	output = 'node "nuke:iron_tnt" 4',
	recipe = {
		{'','node "default:steel_ingot" 1',''},
		{'craft "default:steel_ingot" 1','craft "nuke:tnt" 1','craft "default:steel_ingot" 1'},
		{'','node "default:steel_ingot" 1',''}
	}
})
minetest.register_node("nuke:iron_tnt", {
	tile_images = {"nuke_iron_tnt_top.png", "nuke_iron_tnt_bottom.png",
			"nuke_iron_tnt_side.png", "nuke_iron_tnt_side.png",
			"nuke_iron_tnt_side.png", "nuke_iron_tnt_side.png"},
	inventory_image = minetest.inventorycube("nuke_iron_tnt_top.png",
			"nuke_iron_tnt_side.png", "nuke_iron_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Iron TNT",
})

minetest.register_on_punchnode(function(p, node)
	if node.name == "nuke:iron_tnt" then
		minetest.env:remove_node(p)
		minetest.env:add_entity(p, "nuke:iron_tnt")
		--minetest.env:add_entity(p, "nuke:iron_tnt2") <-in case you forget
		nodeupdate(p)
	end
end)

local IRON_TNT_RANGE = 14
local IRON_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"nuke_iron_tnt_top.png", "nuke_iron_tnt_bottom.png",
			"nuke_iron_tnt_side.png", "nuke_iron_tnt_side.png",
			"nuke_iron_tnt_side.png", "nuke_iron_tnt_side.png"},
	-- Initial value for our timer
	timer = 0,
	-- Number of punches required to defuse
	health = 1,
	blinktimer = 0,
	blinkstatus = true,
	warning_played = false,
}

function IRON_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function IRON_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 8 then
	minetest.sound_play("nuke_irontnt",
	{pos = pos, gain = 0.3, max_hear_distance = 32,})
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)
        do_tnt_physics(pos, IRON_TNT_RANGE)
        if minetest.env:get_node(pos).name == "default:water_source" or minetest.env:get_node(pos).name == "default:water_flowing" then
            -- Cancel the Explosion
            self.object:remove()
            return
        end
        for x=-IRON_TNT_RANGE,IRON_TNT_RANGE do
        for y=-IRON_TNT_RANGE,IRON_TNT_RANGE do
        for z=-IRON_TNT_RANGE,IRON_TNT_RANGE do
            if x*x+y*y+z*z <= (IRON_TNT_RANGE + math.floor(math.random(mrmin,mrmax))) * (IRON_TNT_RANGE + math.floor(math.random(mrmin,mrmax))) + (IRON_TNT_RANGE + math.floor(math.random(mrmin,mrmax))) then
                local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
                local n = minetest.env:get_node(np)
                if n.name ~= "air" then
                    minetest.env:remove_node(np)
                end
                activate_if_tnt(n.name, np, pos, IRON_TNT_RANGE)
            end
        end
        end
        end
		self.object:remove()
	end
end
minetest.register_entity("nuke:iron_tnt", IRON_TNT)


minetest.register_on_punchnode(function(p, node)
	if node.name == "nuke:mese_tnt" then
		minetest.env:remove_node(p)
		minetest.env:add_entity(p, "nuke:mese_tnt")
		nodeupdate(p)
	end
end)






local IRON_TNT2_RANGE = 14
local IRON_TNT2 = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"nuke_iron_tnt_top.png", "nuke_iron_tnt_bottom.png",
			"nuke_iron_tnt_side.png", "nuke_iron_tnt_side.png",
			"nuke_iron_tnt_side.png", "nuke_iron_tnt_side.png"},
	-- Initial value for our timer
	timer = 9,
	-- Number of punches required to defuse
	health = 1,
	blinktimer = 9,
	blinkstatus = true,
}
	
function IRON_TNT2:on_activate(staticdata)
	self.object:setvelocity({x=0, y=0, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function IRON_TNT2:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 8 then
	minetest.sound_play("nuke_irontnt",
	{pos = pos, gain = 0.3, max_hear_distance = 32,})
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)
        do_tnt_physics(pos, IRON_TNT2_RANGE)
        if minetest.env:get_node(pos).name == "default:water_source" or minetest.env:get_node(pos).name == "default:water_flowing" then
            -- Cancel the Explosion
            self.object:remove()
            return
        end
        for x=-IRON_TNT2_RANGE,IRON_TNT2_RANGE do
        for y=-IRON_TNT2_RANGE,IRON_TNT2_RANGE do
        for z=-IRON_TNT2_RANGE,IRON_TNT2_RANGE do
            if x*x+y*y+z*z <= (IRON_TNT2_RANGE + math.floor(math.random(mrmin,mrmax))) * (IRON_TNT2_RANGE + math.floor(math.random(mrmin,mrmax))) + (IRON_TNT2_RANGE + math.floor(math.random(mrmin,mrmax))) then
                local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
                local n = minetest.env:get_node(np)
                if n.name ~= "air" then
                    minetest.env:remove_node(np)
                end
                activate_if_tnt(n.name, np, pos, IRON_TNT2_RANGE)
            end
        end
        end
        end
		self.object:remove()
	end
end
minetest.register_entity("nuke:iron_tnt2", IRON_TNT2)


local MESE_TNT_RANGE = 24
local MESE_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"nuke_mese_tnt_top.png", "nuke_mese_tnt_bottom.png",
			"nuke_mese_tnt_side.png", "nuke_mese_tnt_side.png",
			"nuke_mese_tnt_side.png", "nuke_mese_tnt_side.png"},
	-- Initial value for our timer
	timer = 0,
	-- Number of punches required to defuse
	health = 1,
	blinktimer = 0,
	blinkstatus = true,
	warning_played = false,
}

function MESE_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function MESE_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 8 then
	minetest.sound_play("nuke_mesetnt",
	{pos = pos, gain = 0.3, max_hear_distance = 32,})
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)
        do_tnt_physics(pos, MESE_TNT_RANGE)
        if minetest.env:get_node(pos).name == "default:water_source" or minetest.env:get_node(pos).name == "default:water_flowing" then
            -- Cancel the Explosion
            self.object:remove()
            return
        end
        for x=-MESE_TNT_RANGE,MESE_TNT_RANGE do
        for y=-MESE_TNT_RANGE,MESE_TNT_RANGE do
        for z=-MESE_TNT_RANGE,MESE_TNT_RANGE do
            if x*x+y*y+z*z <= (MESE_TNT_RANGE + math.floor(math.random(mrmin,mrmax))) * (MESE_TNT_RANGE + math.floor(math.random(mrmin,mrmax))) + (MESE_TNT_RANGE + math.floor(math.random(mrmin,mrmax))) then
                local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
                local n = minetest.env:get_node(np)
                if n.name ~= "air" then
                    minetest.env:remove_node(np)
                end
                activate_if_tnt(n.name, np, pos, MESE_TNT_RANGE)
            end
        end
        end
        end
		self.object:remove()
	end
end
minetest.register_entity("nuke:mese_tnt", MESE_TNT)

-- Mese TNT

minetest.register_craft({
	output = 'node "nuke:mese_tnt" 4',
	recipe = {
		{'','node "default:mese" 1',''},
		{'craft "default:mese" 1','craft "nuke:tnt" 1','craft "default:mese" 1'},
		{'','node "default:mese" 1',''}
	}
})
minetest.register_node("nuke:mese_tnt", {
	tile_images = {"nuke_mese_tnt_top.png", "nuke_mese_tnt_bottom.png",
			"nuke_mese_tnt_side.png", "nuke_mese_tnt_side.png",
			"nuke_mese_tnt_side.png", "nuke_mese_tnt_side.png"},
	inventory_image = minetest.inventorycube("nuke_mese_tnt_top.png",
			"nuke_mese_tnt_side.png", "nuke_mese_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Mese TNT",
})

local MESE_TNT2_RANGE = 24
local MESE_TNT2 = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"nuke_mese_tnt_top.png", "nuke_mese_tnt_bottom.png",
			"nuke_mese_tnt_side.png", "nuke_mese_tnt_side.png",
			"nuke_mese_tnt_side.png", "nuke_mese_tnt_side.png"},
	-- Initial value for our timer
	timer = 9,
	-- Number of punches required to defuse
	health = 1,
	blinktimer = 9,
	blinkstatus = true,
}

function MESE_TNT2:on_activate(staticdata)
	self.object:setvelocity({x=0, y=1, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function MESE_TNT2:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 8 then
	minetest.sound_play("nuke_mesetnt",
	{pos = pos, gain = 0.3, max_hear_distance = 32,})
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)
        do_tnt_physics(pos, MESE_TNT2_RANGE)
        if minetest.env:get_node(pos).name == "default:water_source" or minetest.env:get_node(pos).name == "default:water_flowing" then
            -- Cancel the Explosion
            self.object:remove()
            return
        end
        for x=-MESE_TNT2_RANGE,MESE_TNT2_RANGE do
        for y=-MESE_TNT2_RANGE,MESE_TNT2_RANGE do
        for z=-MESE_TNT2_RANGE,MESE_TNT2_RANGE do
            if x*x+y*y+z*z <= (MESE_TNT2_RANGE + math.floor(math.random(mrmin,mrmax))) * (MESE_TNT2_RANGE + math.floor(math.random(mrmin,mrmax))) + (MESE_TNT2_RANGE + math.floor(math.random(mrmin,mrmax))) then
                local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
                local n = minetest.env:get_node(np)
                if n.name ~= "air" then
                    minetest.env:remove_node(np)
                end
                activate_if_tnt(n.name, np, pos, MESE_TNT2_RANGE)
            end
        end
        end
        end
		self.object:remove()
	end
end
minetest.register_entity("nuke:mese_tnt2", MESE_TNT2)




-- Hardcore Iron TNT

minetest.register_craft({
	output = 'node "nuke:hardcore_iron_tnt" 1',
	recipe = {
		{'craft "gun_powder:gun_powder" 1','craft "gun_powder:gun_powder" 1','craft "gun_powder:gun_powder" 1'},
		{'craft "gun_powder:gun_powder" 1','node "nuke:iron_tnt" 1','craft "gun_powder:gun_powder" 1'},
		{'craft "gun_powder:gun_powder" 1','craft "gun_powder:gun_powder" 1','craft "gun_powder:gun_powder" 1'}
	}
})
minetest.register_node("nuke:hardcore_iron_tnt", {
	tile_images = {"nuke_iron_tnt_top.png", "nuke_iron_tnt_bottom.png",
			"nuke_hardcore_iron_tnt_side.png", "nuke_hardcore_iron_tnt_side.png",
			"nuke_hardcore_iron_tnt_side.png", "nuke_hardcore_iron_tnt_side.png"},
	inventory_image = minetest.inventorycube("nuke_iron_tnt_top.png",
			"nuke_hardcore_iron_tnt_side.png", "nuke_hardcore_iron_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Hardcore Iron TNT",
})

minetest.register_on_punchnode(function(p, node)
	if node.name == "nuke:hardcore_iron_tnt" then
		minetest.env:remove_node(p)
		minetest.env:add_entity(p, "nuke:hardcore_iron_tnt")
		nodeupdate(p)
	end
end)

local HARDCORE_IRON_TNT_RANGE = 6
local HARDCORE_IRON_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"nuke_iron_tnt_top.png", "nuke_iron_tnt_bottom.png",
			"nuke_hardcore_iron_tnt_side.png", "nuke_hardcore_iron_tnt_side.png",
			"nuke_hardcore_iron_tnt_side.png", "nuke_hardcore_iron_tnt_side.png"},
	-- Initial value for our timer
	timer = 0,
	-- Number of punches required to defuse
	health = 1,
	blinktimer = 0,
	blinkstatus = true,
	warning_played = false,
}

function HARDCORE_IRON_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function HARDCORE_IRON_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>7.5 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 8 then
	minetest.sound_play("nuke_mesetnt",
	{pos = pos, gain = 0.3, max_hear_distance = 32,})
	local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)
        for x=-HARDCORE_IRON_TNT_RANGE,HARDCORE_IRON_TNT_RANGE do
        for z=-HARDCORE_IRON_TNT_RANGE,HARDCORE_IRON_TNT_RANGE do
            if x*x+z*z <= HARDCORE_IRON_TNT_RANGE * HARDCORE_IRON_TNT_RANGE + HARDCORE_IRON_TNT_RANGE then
                local np={x=pos.x+x,y=pos.y,z=pos.z+z}
                minetest.env:add_entity(np, "nuke:iron_tnt")
            end
        end
        end
		self.object:remove()
	end
end
minetest.register_entity("nuke:hardcore_iron_tnt", HARDCORE_IRON_TNT)

-- Hardcore Mese TNT

minetest.register_craft({
	output = 'node "nuke:hardcore_mese_tnt" 1',
	recipe = {
		{'craft "gun_powder:gun_powder" 1','craft "gun_powder:gun_powder" 1','craft "gun_powder:gun_powder" 1'},
		{'craft "gun_powder:gun_powder" 1','node "nuke:mese_tnt" 1','craft "gun_powder:gun_powder" 1'},
		{'craft "gun_powder:gun_powder" 1','craft "gun_powder:gun_powder" 1','craft "gun_powder:gun_powder" 1'}
	}
})
minetest.register_node("nuke:hardcore_mese_tnt", {
	tile_images = {"nuke_mese_tnt_top.png", "nuke_mese_tnt_bottom.png",
			"nuke_hardcore_mese_tnt_side.png", "nuke_hardcore_mese_tnt_side.png",
			"nuke_hardcore_mese_tnt_side.png", "nuke_hardcore_mese_tnt_side.png"},
	inventory_image = minetest.inventorycube("nuke_mese_tnt_top.png",
			"nuke_hardcore_mese_tnt_side.png", "nuke_hardcore_mese_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Hardcore Mese TNT",
})

minetest.register_on_punchnode(function(p, node)
	if node.name == "nuke:hardcore_mese_tnt" then
		minetest.env:remove_node(p)
		minetest.env:add_entity(p, "nuke:hardcore_mese_tnt")
		nodeupdate(p)
	end
end)

local HARDCORE_MESE_TNT_RANGE = 6
local HARDCORE_MESE_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"nuke_mese_tnt_top.png", "nuke_mese_tnt_bottom.png",
			"nuke_hardcore_mese_tnt_side.png", "nuke_hardcore_mese_tnt_side.png",
			"nuke_hardcore_mese_tnt_side.png", "nuke_hardcore_mese_tnt_side.png"},
	-- Initial value for our timer
	timer = 0,
	-- Number of punches required to defuse
	health = 1,
	blinktimer = 0,
	blinkstatus = true,
	warning_played = false,
}

function HARDCORE_MESE_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function HARDCORE_MESE_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 8 then
	minetest.sound_play("nuke_mesetnt",
	{pos = pos, gain = 0.3, max_hear_distance = 32,})
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)
        for x=-HARDCORE_MESE_TNT_RANGE,HARDCORE_MESE_TNT_RANGE do
        for z=-HARDCORE_MESE_TNT_RANGE,HARDCORE_MESE_TNT_RANGE do
            if x*x+z*z <= HARDCORE_MESE_TNT_RANGE * HARDCORE_MESE_TNT_RANGE + HARDCORE_MESE_TNT_RANGE then
                local np={x=pos.x+x,y=pos.y,z=pos.z+z}
                minetest.env:add_entity(np, "nuke:mese_tnt")
            end
        end
        end
		self.object:remove()
	end
end
minetest.register_entity("nuke:hardcore_mese_tnt", HARDCORE_MESE_TNT)
