wyrda.mapgen = {}

local function noise3d_integer(noise, pos)
	return math.abs(math.floor(noise:get_3d(pos) * 0x7fffffff))
end

local function random_sample(rand, list, count)
	local ret = {}
	for n = 1, count do
		local idx = rand:next(1, #list)
		table.insert(ret, list[idx])
		table.remove(list, idx)
	end
	return ret
end

wyrda.mapgen.registered_loot = {
	{name = "default:stick", chance = 0.6, count = {3, 6}},
	{name = "default:gold_ingot", chance = 0.5, count = {1, 3}},
	{name = "default:steel_ingot", chance = 0.4, count = {1, 6}},
	{name = "default:mese_crystal", chance = 0.1, count = {2, 3}},
    {name = "default:diamond", chance = 0.1, count = {1, 2}},
}

wyrda.mapgen.populate_container = function(pos, rand, item_list) -- PcgRandom(noise3d_integer(noise, pos))
    -- take random (partial) sample of all possible items
    local sample_n = math.min(#item_list, 8)
    item_list = random_sample(rand, item_list, sample_n)

    -- apply chances / randomized amounts and collect resulting items
    local items = {}
    for _, loot in ipairs(item_list) do
        if rand:next(0, 1000) / 1000 <= loot.chance then
            local itemdef = core.registered_items[loot.name]
            local amount = 1
            if loot.count ~= nil then
                amount = rand:next(loot.count[1], loot.count[2])
            end

            if not itemdef then
                core.log("warning", "[WYRDA] Registered loot item " .. loot.name .. " does not exist")
            elseif itemdef.tool_capabilities then
                for n = 1, amount do
                    local wear = rand:next(0.20 * 65535, 0.75 * 65535) -- 20% to 75% wear
                    table.insert(items, ItemStack({name = loot.name, wear = wear}))
                end
            elseif itemdef.stack_max == 1 then
                -- not stackable, add separately
                for n = 1, amount do
                    table.insert(items, loot.name)
                end
            else
                table.insert(items, ItemStack({name = loot.name, count = amount}))
            end
        end
    end

    -- place items at random places in chest
    local inv = core.get_meta(pos):get_inventory()
    local listsz = inv:get_size("main")
    assert(listsz >= #items)
    for _, item in ipairs(items) do
        local index = rand:next(1, listsz)
        if inv:get_stack("main", index):is_empty() then
            inv:set_stack("main", index, item)
        else
            inv:add_item("main", item) -- space occupied, just put it anywhere
        end
    end
end

wyrda.mapgen.structures = {}

wyrda.mapgen.levels = {
    "structure",
    "path",
    "segment",
    "room",
    "feature"
}

for i in ipairs(wyrda.mapgen.levels) do
    wyrda.mapgen.structures[wyrda.mapgen.levels[i]] = {}
end

wyrda.mapgen.parse_schem = function(schem)
    if type(schem) == type("") then -- if schem is a filename
        --load the schematic from file as a lua schematic
    end
    return schem
end

wyrda.mapgen.register_structure = function(name, def)
    wyrda.mapgen.structures[def.level][name] = {
        name = def.name,
        desc = def.desc,
        schem = wyrda.mapgen.parse_schem(def.schem),
    }
end

wyrda.mapgen.unpack_schematic = function(schem)
    local data = {}
    data.path_points = wyrda.mapgen.search_for_node_in_schematic(schem, "wyrda:mapgen_marker_path")
    data.feature_points = wyrda.mapgen.search_for_node_in_schematic(schem, "wyrda:mapgen_marker_path")
    return data
end

wyrda.mapgen.place_schematic = function(schem, pos)
    --place the schematic
    return schem -- return schematic so that the path can be contniued, i.e. structure continuation points
end

wyrda.mapgen.load_structure = function(name, level)
    return wyrda.mapgen.structures[level][name].schem
end

wyrda.mapgen.place_center = function(name, pos)
    return wyrda.mapgen.place_schematic(wtrda.mapgen.load_structure(name), pos)
end

wyrda.mapgen.place_room_in_path = function(pos, name, max_depth) end

wyrda.mapgen.place_room_in_path = function(pos, name, depth)
    local schem = wyrda.mapgen.place_room(pos, name)
    local schem_data = wyrda.mapgen.unpack_schematic(schem)
    depth = depth - 1
    for k, v in pairs(schem_data.path_points) do -- for compatability, there should always be only one though
        wyrda.mapgen.place_room_in_path(v, name, depth)
    end
end

wyrda.mapgen.start_path = function(pos, name, max_depth)
    local final_depth = wyrda.mapgen.place_room_in_path(pos, name, max_depth)
end

wyrda.mapgen.place_structure = function(name, pos, level)
    if level == "structure" then
        local schem = wyrda.mapgen.place_center(name, pos)
        local schem_data = wyrda.mapgen.unpack_schematic(schem)
        for k, v in pairs(schem_data.path_points) do
            wyrda.mapgen.start_path(v, name)
        end
    elseif level == "path" then
        wyrda.mapgen.start_path(pos, name)
    elseif level == "room" then
        wyrda.mapgen.place_room(pos, name)
    elseif level == "feature" then
        wyrda.mapgen.place_feature(pos, name)
    end
end

wyrda.mapgen.spawn_structure = function(name, pos, level)
    core.log("Trying to spawn " .. name .. " at " .. core.pos_to_string(pos) .. ", schem type " .. level)
    wyrda.mapgen.place_structure(name, pos, level)
end

local function list_structures(level)
    local list = "Structures in level '" .. level .. "': \n"
    for k, v in pairs(wyrda.mapgen.structures[level]) do
        list = list .. tostring(v.name) .. "\n"
    end
    return list
end

wyrda.mapgen.register_structure("test1", {
    name = "test",
    desc = "A test structure",
    schem = {},
    level = "structure",
})

wyrda.mapgen.register_structure("test", {
    name = "test",
    desc = "A test room",
    schem = {},
    level = "room",
})

core.register_chatcommand("mapgen", {
    params = "spawn structure|path|segment|room|feature <name> <x y z>\n" ..
             "list structure|path|segment|room|feature\n" ..
             "help",
    description = "Generate wyrda structures from console",
    privs = {},
    func = function(name, param)
        local params = param:split(" ")
		local privs = core.check_player_privs(name, {server = true})
        if params[1] == "spawn" then
			if privs == true then
				local struct_name = params[3]
                local x = params[4]
                local y = params[5]
                local z = params[6]
                if params[2] ~= nil and struct_namename ~= nil and (x ~= nil and y ~= nil and z ~= nil) then
                    wyrda.mapgen.spawn_structure(struct_name, params[2], core.string_to_pos("("..x..","..y..","..z..")"))
                else
                    core.chat_send_player(name, core.colorize("#F44", "Missing secondary parameter, try /mapgen help"))
                end
			else
				core.chat_send_player(name, core.colorize("#F44", "Denied: Missing required privs (server)"))
			end
        elseif params[1] == "list" then
            if params[2] ~= nil then
                core.chat_send_player(name, list_structures(params[2]))
            else
                core.chat_send_player(name, core.colorize("#F44", "Missing secondary parameter, try /mapgen help"))
            end
        elseif params[1] == "help" then
            core.chat_send_player(name, core.colorize("#F44", "Help is not available"))
            return
        else
            core.chat_send_player(name, core.colorize("#F44", "Emtpy Command"))
            return false, "Please enter a parameter"
        end
    end,
})

