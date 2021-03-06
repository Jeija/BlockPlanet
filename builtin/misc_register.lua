-- Minetest: builtin/misc_register.lua

--
-- Make raw registration functions inaccessible to anyone except this file
--

local register_item_raw = minetest.register_item_raw
minetest.register_item_raw = nil

local register_alias_raw = minetest.register_alias_raw
minetest.register_item_raw = nil

--
-- Item / entity / ABM registration functions
--

minetest.registered_abms = {}
minetest.registered_entities = {}
minetest.registered_items = {}
minetest.registered_nodes = {}
minetest.registered_craftitems = {}
minetest.registered_tools = {}
minetest.registered_aliases = {}
minetest.registered_crafts = {}
minetest.registered_fuels = {}
minetest.registered_smeltables = {}
minetest.registered_clones = {}

-- For tables that are indexed by item name:
-- If table[X] does not exist, default to table[minetest.registered_aliases[X]]
local function set_alias_metatable(table)
	setmetatable(table, {
		__index = function(name)
			return rawget(table, minetest.registered_aliases[name])
		end
	})
end
set_alias_metatable(minetest.registered_items)
set_alias_metatable(minetest.registered_nodes)
set_alias_metatable(minetest.registered_craftitems)
set_alias_metatable(minetest.registered_tools)

-- These item names may not be used because they would interfere
-- with legacy itemstrings
local forbidden_item_names = {
	MaterialItem = true,
	MaterialItem2 = true,
	MaterialItem3 = true,
	NodeItem = true,
	node = true,
	CraftItem = true,
	craft = true,
	MBOItem = true,
	ToolItem = true,
	tool = true,
}

local function check_modname_prefix(name)
	if name:sub(1,1) == ":" then
		-- Escape the modname prefix enforcement mechanism
		return name:sub(2)
	else
		-- Modname prefix enforcement
		local expected_prefix = minetest.get_current_modname() .. ":"
		if name:sub(1, #expected_prefix) ~= expected_prefix then
			error("Name " .. name .. " does not follow naming conventions: " ..
				"\"modname:\" or \":\" prefix required")
		end
		local subname = name:sub(#expected_prefix+1)
		if subname:find("[^abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_]") then
			error("Name " .. name .. " does not follow naming conventions: " ..
				"contains unallowed characters")
		end
		return name
	end
end

function minetest.register_abm(spec)
	-- Add to minetest.registered_abms
	minetest.registered_abms[#minetest.registered_abms+1] = spec
end

function minetest.register_entity(name, prototype)
	-- Check name
	if name == nil then
		error("Unable to register entity: Name is nil")
	end
	name = check_modname_prefix(tostring(name))

	prototype.name = name
	prototype.__index = prototype  -- so that it can be used as a metatable

	-- Add to minetest.registered_entities
	minetest.registered_entities[name] = prototype
end

function minetest.register_item(name, itemdef)
	-- Check name
	if name == nil then
		error("Unable to register item: Name is nil")
	end
	name = check_modname_prefix(tostring(name))
	if forbidden_item_names[name] then
		error("Unable to register item: Name is forbidden: " .. name)
	end
	itemdef.name = name

	-- Apply defaults and add to registered_* table
	if itemdef.type == "node" then
		setmetatable(itemdef, {__index = minetest.nodedef_default})
		minetest.registered_nodes[itemdef.name] = itemdef
	elseif itemdef.type == "craft" then
		setmetatable(itemdef, {__index = minetest.craftitemdef_default})
		minetest.registered_craftitems[itemdef.name] = itemdef
	elseif itemdef.type == "tool" then
		setmetatable(itemdef, {__index = minetest.tooldef_default})
		minetest.registered_tools[itemdef.name] = itemdef
	elseif itemdef.type == "none" then
		setmetatable(itemdef, {__index = minetest.noneitemdef_default})
	else
		error("Unable to register item: Type is invalid: " .. dump(itemdef))
	end

	-- Flowing liquid uses param2
	if itemdef.type == "node" and itemdef.liquidtype == "flowing" then
		itemdef.paramtype2 = "flowingliquid"
	end

	-- BEGIN Legacy stuff
	if itemdef.cookresult_itemstring ~= nil and itemdef.cookresult_itemstring ~= "" then
		minetest.register_craft({
			type="cooking",
			output=itemdef.cookresult_itemstring,
			recipe=itemdef.name,
			cooktime=itemdef.furnace_cooktime
		})
	end
	if itemdef.furnace_burntime ~= nil and itemdef.furnace_burntime >= 0 then
		minetest.register_craft({
			type="fuel",
			recipe=itemdef.name,
			burntime=itemdef.furnace_burntime
		})
	end
	-- END Legacy stuff

	-- Disable all further modifications
	getmetatable(itemdef).__newindex = {}

	--minetest.log("Registering item: " .. itemdef.name)
	minetest.registered_items[itemdef.name] = itemdef
	minetest.registered_aliases[itemdef.name] = nil
	register_item_raw(itemdef)
end

function minetest.register_node(name, nodedef)
	nodedef.type = "node"
	minetest.registered_clones[name] = {}
	minetest.registered_clones[name][0] = name
	minetest.register_item(name, nodedef)
end

function minetest.register_craftitem(name, craftitemdef)
	craftitemdef.type = "craft"

	-- BEGIN Legacy stuff
	if craftitemdef.inventory_image == nil and craftitemdef.image ~= nil then
		craftitemdef.inventory_image = craftitemdef.image
	end
	-- END Legacy stuff

	minetest.register_item(name, craftitemdef)
end

function minetest.register_craft(craftdef)
	local tempcraftdef = craftdef
	if craftdef.recipe ~= nil and craftdef.output ~= nil then
		if craftdef.type == "cooking" then
			if minetest.registered_clones[craftdef.recipe] ~= nil then
				for i,v in ipairs(minetest.registered_clones[craftdef.recipe]) do
					tempcraftdef.recipe = v
					minetest.registered_smeltables[v] = craftdef.output
					minetest.register_craft_raw(tempcraftdef)
				end
			else
				minetest.registered_smeltables[craftdef.recipe] = craftdef.burntime
				minetest.register_craft_raw(craftdef)
			end
		elseif craftdef.type == "fuel" then
			if minetest.registered_clones[craftdef.recipe] ~= nil then
				for i,v in ipairs(minetest.registered_clones[craftdef.recipe]) do
					tempcraftdef.recipe = v
					minetest.registered_fuels[v] = craftdef.burntime
					minetest.register_craft_raw(tempcraftdef)
				end
			else
				minetest.registered_fuels[craftdef.recipe] = craftdef.burntime
				minetest.register_craft_raw(craftdef)
			end
		else
			for i,v in ipairs(craftdef.recipe) do
				for x,y in ipairs(v) do
					if minetest.registered_clones[y] ~= nil then
						for z,a in ipairs(minetest.registered_clones[y]) do
							tempcraftdef.recipe[v][y] = a
							minetest.registered_crafts[tempcraftdef.recipe] = craftdef.output
							minetest.register_craft_raw(tempcraftdef)
						end
					else
						minetest.registered_crafts[craftdef.recipe] = craftdef.output
						minetest.register_craft_raw(craftdef)
					end
				end
			end
		end
	end
end

function minetest.register_tool(name, tooldef)
	tooldef.type = "tool"
	tooldef.stack_max = 1

	-- BEGIN Legacy stuff
	if tooldef.inventory_image == nil and tooldef.image ~= nil then
		tooldef.inventory_image = tooldef.image
	end
	if tooldef.tool_capabilities == nil and
	   (tooldef.full_punch_interval ~= nil or
	    tooldef.basetime ~= nil or
	    tooldef.dt_weight ~= nil or
	    tooldef.dt_crackiness ~= nil or
	    tooldef.dt_crumbliness ~= nil or
	    tooldef.dt_cuttability ~= nil or
	    tooldef.basedurability ~= nil or
	    tooldef.dd_weight ~= nil or
	    tooldef.dd_crackiness ~= nil or
	    tooldef.dd_crumbliness ~= nil or
	    tooldef.dd_cuttability ~= nil) then
		tooldef.tool_capabilities = {
			full_punch_interval = tooldef.full_punch_interval,
			basetime = tooldef.basetime,
			dt_weight = tooldef.dt_weight,
			dt_crackiness = tooldef.dt_crackiness,
			dt_crumbliness = tooldef.dt_crumbliness,
			dt_cuttability = tooldef.dt_cuttability,
			basedurability = tooldef.basedurability,
			dd_weight = tooldef.dd_weight,
			dd_crackiness = tooldef.dd_crackiness,
			dd_crumbliness = tooldef.dd_crumbliness,
			dd_cuttability = tooldef.dd_cuttability,
		}
	end
	-- END Legacy stuff

	minetest.register_item(name, tooldef)
end

function minetest.register_alias(name, convert_to)
	if forbidden_item_names[name] then
		error("Unable to register alias: Name is forbidden: " .. name)
	end
	if minetest.registered_items[name] ~= nil then
		minetest.log("WARNING: Not registering alias, item with same name" ..
			" is already defined: " .. name .. " -> " .. convert_to)
	else
		--minetest.log("Registering alias: " .. name .. " -> " .. convert_to)
		minetest.registered_aliases[name] = convert_to
		register_alias_raw(name, convert_to)
	end
end

-- Alias the forbidden item names to "" so they can't be
-- created via itemstrings (e.g. /give)
local name
for name in pairs(forbidden_item_names) do
	minetest.registered_aliases[name] = ""
	register_alias_raw(name, "")
end

-- Clone a node, changing something
function minetest.register_node_clone(name, original_name, nodedefs)
	local newnodedef = minetest.registered_nodes[original_name]
	for ndn, nd in pairs(nodedefs) do
		newnodedef[ndn] = nd;
	end
	minetest.registered_clones[original_name][table.getn(minetest.registered_clones[original_name])+1] = name
	minetest.register_node(name, newnodedef)
end


-- Deprecated:
-- Aliases for minetest.register_alias (how ironic...)
--minetest.alias_node = minetest.register_alias
--minetest.alias_tool = minetest.register_alias
--minetest.alias_craftitem = minetest.register_alias

--
-- Built-in node definitions. Also defined in C.
--

minetest.register_item(":unknown", {
	type = "none",
	description = "Unknown Item",
	inventory_image = "unknown_item.png",
	on_place = minetest.item_place,
	on_drop = minetest.item_drop,
})

minetest.register_node(":air", {
	description = "Air (you hacker you!)",
	inventory_image = "unknown_block.png",
	wield_image = "unknown_block.png",
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	air_equivalent = true,
})

minetest.register_node(":ignore", {
	description = "Ignore (you hacker you!)",
	inventory_image = "unknown_block.png",
	wield_image = "unknown_block.png",
	drawtype = "airlike",
	paramtype = "none",
	sunlight_propagates = false,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true, -- A way to remove accidentally placed ignores
	air_equivalent = true,
})

-- The hand (bare definition)
minetest.register_item(":", {
	type = "none",
})

--
-- Creative inventory
--

minetest.creative_inventory = {}

minetest.add_to_creative_inventory = function(itemstring)
	table.insert(minetest.creative_inventory, itemstring)
end

--
-- Callback registration
--

local function make_registration()
	local t = {}
	local registerfunc = function(func) table.insert(t, func) end
	return t, registerfunc
end

minetest.registered_on_chat_messages, minetest.register_on_chat_message = make_registration()
minetest.registered_globalsteps, minetest.register_globalstep = make_registration()
minetest.registered_on_placenodes, minetest.register_on_placenode = make_registration()
minetest.registered_on_dignodes, minetest.register_on_dignode = make_registration()
minetest.registered_on_punchnodes, minetest.register_on_punchnode = make_registration()
minetest.registered_on_generateds, minetest.register_on_generated = make_registration()
minetest.registered_on_newplayers, minetest.register_on_newplayer = make_registration()
minetest.registered_on_dieplayers, minetest.register_on_dieplayer = make_registration()
minetest.registered_on_respawnplayers, minetest.register_on_respawnplayer = make_registration()
minetest.registered_on_joinplayers, minetest.register_on_joinplayer = make_registration()
minetest.registered_on_leaveplayers, minetest.register_on_leaveplayer = make_registration()


