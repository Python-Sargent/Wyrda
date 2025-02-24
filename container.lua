wyrda.container = {}

local wood_sounds = nil

if core.get_modpath("default") ~= nil then
    wood_sounds = default.node_sound_stone_defaults()
end

function wyrda.container.get_container_formspec(pos)
	local spos = pos.x .. "," .. pos.y .. "," .. pos.z
	local formspec =
		"size[8,9]" ..
		"list[nodemeta:" .. spos .. ";main;0,0.3;8,4;]" ..
		"list[current_player;main;0,4.85;8,1;]" ..
		"list[current_player;main;0,6.08;8,3;8]" ..
		"listring[nodemeta:" .. spos .. ";main]" ..
		"listring[current_player;main]" ..
		default.get_hotbar_bg(0,4.85)
	return formspec
end

function wyrda.container.container_lid_obstructed(pos)
	local above = {x = pos.x, y = pos.y + 1, z = pos.z}
	local def = core.registered_nodes[core.get_node(above).name]
	-- allow ladders, signs, wallmounted things and torches to not obstruct
	if def and
			(def.drawtype == "airlike" or
			def.drawtype == "signlike" or
			def.drawtype == "torchlike" or
			(def.drawtype == "nodebox" and def.paramtype2 == "wallmounted")) then
		return false
	end
	return true
end

function wyrda.container.container_lid_close(pn)
	local container_open_info = wyrda.container.open_containers[pn]
	local pos = container_open_info.pos
	local sound = container_open_info.sound
	local swap = container_open_info.swap

	wyrda.container.open_containers[pn] = nil
	for k, v in pairs(wyrda.container.open_containers) do
		if vector.equals(v.pos, pos) then
			-- another player is also looking at the container
			return true
		end
	end

	local node = core.get_node(pos)
	core.after(0.2, function()
		local current_node = core.get_node(pos)
		if current_node.name ~= swap .. "_open" then
			-- the container has already been replaced, don't try to replace what's there.
			return
		end
		core.swap_node(pos, {name = swap, param2 = node.param2})
		core.sound_play(sound, {gain = 0.3, pos = pos,
			max_hear_distance = 10}, true)
	end)
end

wyrda.container.open_containers = {}

core.register_on_player_receive_fields(function(player, formname, fields)
	local pn = player:get_player_name()

	if formname ~= "wyrda:container" then
		if wyrda.container.open_containers[pn] then
			wyrda.container.container_lid_close(pn)
		end

		return
	end

	if not (fields.quit and wyrda.container.open_containers[pn]) then
		return
	end

	wyrda.container.container_lid_close(pn)

	return true
end)

core.register_on_leaveplayer(function(player)
	local pn = player:get_player_name()
	if wyrda.container.open_containers[pn] then
		wyrda.container.container_lid_close(pn)
	end
end)

local function get_inventory_drops(pos, inventory, drops) -- from mtg default mod, functions.lua
	local inv = core.get_meta(pos):get_inventory()
	local n = #drops
	for i = 1, inv:get_size(inventory) do
		local stack = inv:get_stack(inventory, i)
		if stack:get_count() > 0 then
			drops[n+1] = stack:to_table()
			n = n + 1
		end
	end
end

function wyrda.container.register_container(prefixed_name, d)
	local name = prefixed_name:sub(1,1) == ':' and prefixed_name:sub(2,-1) or prefixed_name
	local def = table.copy(d)
	def.drawtype = "mesh"
	def.visual = "mesh"
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.legacy_facedir_simple = true
	def.is_ground_content = false
    def.on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string("infotext", "Container")
        local inv = meta:get_inventory()
        inv:set_size("main", 8*4)
    end
    def.can_dig = function(pos,player)
        local meta = core.get_meta(pos);
        local inv = meta:get_inventory()
        return inv:is_empty("main")
    end
    def.on_rightclick = function(pos, node, clicker)
        local cn = clicker:get_player_name()

        if wyrda.container.open_containers[cn] then
            wyrda.container.container_lid_close(cn)
        end

        core.sound_play(def.sound_open, {gain = 0.3, pos = pos,
                max_hear_distance = 10}, true)
        if not wyrda.container.container_lid_obstructed(pos) then
            core.swap_node(pos, {
                    name = name .. "_open",
                    param2 = node.param2 })
        end
        core.after(0.2, core.show_formspec,
                cn,
                "wyrda:container", wyrda.container.get_container_formspec(pos))
        wyrda.container.open_containers[cn] = { pos = pos,
                sound = def.sound_close, swap = name }
    end
    def.on_blast = function(pos)
        local drops = {}
        get_inventory_drops(pos, "main", drops)
        drops[#drops+1] = name
        core.remove_node(pos)
        return drops
    end

	local def_opened = table.copy(def)
	local def_closed = table.copy(def)

	def_opened.mesh = "container_open.obj"
	for i = 1, #def_opened.tiles do
		if type(def_opened.tiles[i]) == "string" then
			def_opened.tiles[i] = {name = def_opened.tiles[i], backface_culling = true}
		elseif def_opened.tiles[i].backface_culling == nil then
			def_opened.tiles[i].backface_culling = true
		end
	end
	def_opened.drop = name
	def_opened.groups.not_in_creative_inventory = 1
	def_opened.selection_box = {
		type = "fixed",
		fixed = { -1/2, -1/2, -1/2, 1/2, 3/16, 1/2 },
	}
	def_opened.can_dig = function()
		return false
	end
	def_opened.on_blast = function() end

	def_closed.mesh = nil
	def_closed.drawtype = nil
	def_closed.tiles[6] = def.tiles[5] -- swap textures around for "normal"
	def_closed.tiles[5] = def.tiles[3] -- drawtype to make them match the mesh
	def_closed.tiles[3] = def.tiles[3].."^[transformFX"

	core.register_node(prefixed_name, def_closed)
	core.register_node(prefixed_name .. "_open", def_opened)

	-- convert old containers to this new variant
	if name == "wyrda:container" or name == "wyrda:container_locked" then
		core.register_lbm({
			label = "update containers to opening containers",
			name = "wyrda:upgrade_" .. name:sub(9,-1) .. "_v2",
			nodenames = {name},
			action = function(pos, node)
				local meta = core.get_meta(pos)
				meta:set_string("formspec", "")
				local inv = meta:get_inventory()
				local list = inv:get_list("wyrda:container")
				if list then
					inv:set_size("main", 8*4)
					inv:set_list("main", list)
					inv:set_list("wyrda:container", nil)
				end
			end
		})
	end

	-- close opened containers on load
	local modname, containername = prefixed_name:match("^(:?.-):(.*)$")
	core.register_lbm({
		label = "close opened containers on load",
		name = modname .. ":close_" .. containername .. "_open",
		nodenames = {prefixed_name .. "_open"},
		run_at_every_load = true,
		action = function(pos, node)
			node.name = prefixed_name
			core.swap_node(pos, node)
		end
	})
end

wyrda.container.register_container("wyrda:container", {
	description = "Container",
	tiles = {
		"wyrda_nodes_container_top.png",
		"wyrda_nodes_container_top.png",
		"wyrda_nodes_container_side.png",
		"wyrda_nodes_container_side.png",
		"wyrda_nodes_container_front.png",
		"wyrda_nodes_container_inside.png"
	},
	sounds = wood_sounds,
	sound_open = "wyrda_container_open",
	sound_close = "wyrda_container_close",
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
})
