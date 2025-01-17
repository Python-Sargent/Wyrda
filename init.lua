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

core.register_on_chat_message(function(name, message)
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

dofile(modpath .. "/energy.lua")

local function take_energy(spell, player)
    if wyrda.energy.get_energy(player) > spell.cost then
        wyrda.energy.change_energy(player, -spell.cost)
        return true
    end
    return false
end

wyrda.cast = function(spell, player, message, pos, type)
    if spell == nil then return end
    if type == 1 then
        local has_energy = take_energy(spell, player)
        if has_energy then return spell.func(player, message, pos) end
    elseif type == 2 then
        local has_energy = take_energy(spell, player)
        if has_energy then return spell.func2(player, message, pos) end
    end
end

dofile(modpath .. "/spells.lua")
dofile(modpath .. "/wands.lua")
dofile(modpath .. "/books.lua")
dofile(modpath .. "/inscription.lua")