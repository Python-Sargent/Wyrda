local function set_player_attribute(player, key, value)
	local meta = player:get_meta()
	if value == nil then
		meta:set_string(key, "")
	else
		meta:set_string(key, tostring(value))
	end
end

local function get_player_attribute(player, key)
	local meta = player:get_meta()
	return meta:get_string(key)
end

local hud_ids_by_player_name = {}

local function get_hud_id(player)
	return hud_ids_by_player_name[player:get_player_name()]
end

local function set_hud_id(player, hud_id)
	hud_ids_by_player_name[player:get_player_name()] = hud_id
end

wyrda.energy = {}

function wyrda.energy.get_energy(player)
	return tonumber(get_player_attribute(player, "wyrda:energy"))
end

function wyrda.energy.get_max_energy(player)
	return tonumber(get_player_attribute(player, "wyrda:max_energy"))
end

function wyrda.energy.get_energy_recharge(player)
	return tonumber(get_player_attribute(player, "wyrda:recharge_energy"))
end

function wyrda.energy.set_energy(player, level)
	set_player_attribute(player, "wyrda:energy", level)
	player:hud_change(
		get_hud_id(player),
		"number",
		math.min(wyrda.energy.get_max_energy(player) or 20, level)
	)
end

function wyrda.energy.set_max_energy(player, level)
	set_player_attribute(player, "wyrda:max_energy", level)
	wyrda.energy.set_energy(player, level)
end

function wyrda.energy.set_energy_recharge(player, level)
	set_player_attribute(player, "wyrda:recharge_energy", level)
end

wyrda.energy.registered_on_update_energy = {}
function wyrda.energy.register_on_update_energy(ph)
	table.insert(wyrda.energy.registered_on_update_energy, ph)
end

function wyrda.energy.update_energy(player, level)
	for _, callback in ipairs(wyrda.energy.registered_on_update_energy) do
		local result = callback(player, level)
		if result then
			return result
		end
	end

	local old = wyrda.energy.get_energy(player)

	if level == old then
		return
	end

	wyrda.energy.set_energy(player, level)
end

function wyrda.energy.change_energy(player, change)
    if player == nil then return end
	if not player:is_player() or not change or change == 0 then
		return false
	end
	local level = wyrda.energy.get_energy(player) + change
	level = math.max(level, 0)
	level = math.min(level, wyrda.energy.get_max_energy(player) or 20)
	wyrda.energy.update_energy(player, level)
	return true
end

function wyrda.energy.get_use_energy(player)
	return tonumber(get_player_attribute(player, "wyrda:use_energy"))
end

function wyrda.energy.set_use_energy(player, use_energy)
	set_player_attribute(player, "wyrda:use_energy", use_energy)
end

wyrda.energy.registered_on_use_energy_players = {}
function wyrda.energy.register_on_use_energy_player(fun)
	table.insert(wyrda.energy.registered_on_use_energy_players, fun)
end

function wyrda.energy.use_energy_player(player, change, cause)
	for _, callback in ipairs(wyrda.energy.registered_on_use_energy_players) do
		local result = callback(player, change, cause)
		if result then
			return result
		end
	end

	if player == nil then
		return
    elseif not player:is_player() then
        return
	end

	local use_energy = wyrda.energy.get_use_energy(player) or 0

	use_energy = use_energy + change

	if use_energy >= 160 then
		use_energy = use_energy - 160
		wyrda.energy.change_energy(player, -1)
	end

	wyrda.energy.set_use_energy(player, use_energy)
end

wyrda.energy_tick = function(player)
	--[[for _,player in ipairs(core.get_connected_players()) do
		local energy = wyrda.energy.get_energy(player)
        local max_energy = wyrda.energy.get_max_energy(player) or 20
		if energy < max_energy then
			wyrda.energy.update_energy(player, energy + 1)
		end
	end]]
    local energy = wyrda.energy.get_energy(player)
    local max_energy = wyrda.energy.get_max_energy(player) or 20
    if energy < max_energy then
        wyrda.energy.update_energy(player, energy + 1)
    end
end

local energy_timer = 0

local energy_globaltimer = function(dtime)
	energy_timer = energy_timer + dtime

    local recharge = 1

    for _,player in ipairs(core.get_connected_players()) do
		local recharge = wyrda.energy.get_energy_recharge(player) or 1
        if energy_timer > recharge then
            energy_timer = 0
            wyrda.energy_tick(player)
        end
	end
end

core.register_on_joinplayer(function(player)
	local level = wyrda.energy.get_energy(player) or wyrda.energy.get_max_energy(player) or 20
	local id = player:hud_add({
		name = "wyrda.energy",
		hud_elem_type = "statbar",
		position = {x = 0.5, y = 1},
		size = {x = 24, y = 24},
		text = "wyrda_energy_hud_fg.png",
		number = level,
		text2 = "wyrda_energy_hud_bg.png",
		item = wyrda.energy.get_max_energy(player) or 20,
		alignment = {x = -1, y = -1},
		offset = {x = -265, y = -128},
		max = 0,
	})
	set_hud_id(player, id)
	wyrda.energy.set_energy(player, level)
    if not wyrda.energy.get_max_energy(player) then wyrda.energy.set_max_energy(player, level) end
    if not wyrda.energy.get_energy_recharge(player) then wyrda.energy.set_energy_recharge(player, 1) end
	set_player_attribute(player, "wyrda.energy:hud_id", nil)
end)

core.register_on_leaveplayer(function(player)
	set_hud_id(player, nil)
end)

core.register_globalstep(energy_globaltimer)

core.register_on_respawnplayer(function(player)
	wyrda.energy.update_energy(player, 0)
end)
