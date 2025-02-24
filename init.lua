wyrda = {}

local modpath = core.get_modpath("wyrda")

wyrda.spells = {}

wyrda.register_spell = function(name, def)
    wyrda.spells[name] = def
end

wyrda.check_message = function(message)
    local words = message:split("[ %-_]+", false, -1, true)
    for i, v in pairs(words) do
        if wyrda.spells[v] then
            return {spell=wyrda.spells[v], words=words, i=i}
        end
    end
    return nil
end

if not core.settings:has("allow_cbv") then
    core.settings:set("allow_cbv", "true")
end

core.register_on_chat_message(function(name, message)
    if core.settings:get("allow_cbv") == "true" then
        local msgparams = wyrda.check_message(message)
        local contains = nil
        if msgparams ~= nil then contains = msgparams.spell else return false end
        local send_msg
        if contains ~= nil then
            send_msg = wyrda.cast(contains, core.get_player_by_name(name), message, core.get_player_by_name(name):get_pos(), 1)
        end
        local msg = "<" .. name .. "> "
        for i, v in pairs(msgparams.words) do
            if i == msgparams.i then
                msg = msg .. core.colorize("#88CCFF", msgparams.words[i]) .. " "
            else
                msg = msg .. msgparams.words[i] .. " "
            end 
        end
        if send_msg then minetest.chat_send_all(msg) end
        return true
    end
end)

wyrda.pointed_to_pos = function(pointed)
    if pointed ~= nil then
        if pointed.type == "node" then
            if pointed.above ~= nil then return pointed.above end
            if pointed.under ~= nil then return pointed.under end
        elseif pointed.type == "object" then
            if pointed.ref ~= nil and pointed.ref:get_pos() ~= nil then return pointed.ref:get_pos() end
        end
        return vector.new(0, 0, 0)
    else
        return vector.new(0, 0, 0)
    end
end

if not core.settings:has("use_energy") then
    core.settings:set("use_energy", "true")
end

if core.settings:get("use_energy") == "true" then
    dofile(modpath .. "/energy.lua")
end

local function take_energy(spell, player, type)
    if type == 1 and spell.cost ~= nil then
        if wyrda.energy.get_energy(player) > spell.cost then
            wyrda.energy.change_energy(player, -spell.cost)
            return true
        end
    elseif type == 2 and spell.cost2 ~= nil then
        if wyrda.energy.get_energy(player) > spell.cost2 then
            wyrda.energy.change_energy(player, -spell.cost2)
            return true
        end
    end
    return false
end

wyrda.cast = function(spell, player, message, pos, type)
    if spell == nil then return end
    if type == 1 then
        if core.settings:get("use_energy") == "true" then
            local has_energy = take_energy(spell, player, type)
            if has_energy then
                core.sound_play("wyrda_cast_spell", {pos = player:get_pos(), gain = 1, pitch = 2, max_hear_distance = 32}, true)
                return spell.func(player, message, pos)
            end
        else
            core.sound_play("wyrda_cast_spell", {pos = player:get_pos(), gain = 1, pitch = 2, max_hear_distance = 32}, true)
            return spell.func(player, message, pos)
        end
    elseif type == 2 then
        if core.settings:get("use_energy") == "true" then
            local has_energy = take_energy(spell, player, type)
            if has_energy then
                core.sound_play("wyrda_cast_spell", {pos = player:get_pos(), gain = 1, pitch = 1, max_hear_distance = 32}, true)
                return spell.func2(player, message, pos)
            end
        else
            core.sound_play("wyrda_cast_spell", {pos = player:get_pos(), gain = 1, pitch = 1, max_hear_distance = 32}, true)
            return spell.func2(player, message, pos)
        end
    end
end

dofile(modpath .. "/helper.lua")
dofile(modpath .. "/wands.lua")
dofile(modpath .. "/inscription.lua")
dofile(modpath .. "/spells.lua")
dofile(modpath .. "/books.lua")
dofile(modpath .. "/spell_gen.lua")
dofile(modpath .. "/crafting.lua")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/container.lua")
--dofile(modpath .. "/mapgen.lua")

local c = core.colorize

core.register_chatcommand("wyrda", {
    params = "settings <settings> <value>\n" ..
             "settings list\n" ..
             "help",
    description = "Change Wyrda's settings from console",
    privs = {},
    func = function(name, param)
        local params = param:split(" ")
		local privs = core.check_player_privs(name, {server = true})
        if params[1] == "settings" then
			if privs == true then
				local val = params[3]
                if params[2] ~= nil then
                    if params[2] == "list" then
                        core.chat_send_player(name, c("#8F8", "Wyrda Settings:\n") ..
                        c("#88F", "  allow_singularities") .. "       = " .. c("#FF8", "false ") .. c("#AAA", "(whether black holes should be allowed)\n") ..
                        c("#88F", "  singularity_size") .. "             = " .. c("#FF8", "50 ")    .. c("#AAA", "(size of black holes if allowed)\n") ..
                        c("#88F", "  allow_crafting_wands") .. "  = " .. c("#FF8", "true ")  .. c("#AAA", "(allow wands to be crafted)\n") ..
                        c("#88F", "  use_energy") .. "                    = " .. c("#FF8", "true ")  .. c("#AAA", "(requires restart for full effect)\n") ..
                        c("#88F", "  allow_cbv") .. "                       = " .. c("#FF8", "true ")  .. c("#AAA", "(Whether to scan chat for Cast by Voice)"))
                    else
                        if val ~= nil then core.settings:set(params[2], tostring(val)) end
                        core.chat_send_player(name, c("#4F8", "[WYRDA] Setting changed: " .. tostring(params[2]) .. " : " .. tostring(val)))
                        if params[2] == "use_energy" then
                            core.chat_send_player(name, c("#F00", "[WYRDA] CHANGES REQUIRE RESTART TO TAKE FULL EFFECT!"))
                        end
                    end
                else
                    core.chat_send_player(name, c("#F44", "Missing secondary parameter, try 'list' for a list of settings."))
                end
			else
				core.chat_send_player(name, c("#F44", "Denied: Missing required privs (server)"))
			end
        elseif params[1] == "help" then
            core.chat_send_player(name, c("#F44", "[WYRDA] Help menu is disabled"))
            return
        end
    end,
})