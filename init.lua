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

wyrda.cast = function(spell, player, message)
    if spell == nil then return end
    spell.func(player, message)
end

core.register_on_chat_message(function(name, message)
    local msgparams = wyrda.check_message(message)
    local contains = msgparams.spell
    if contains ~= nil then
        wyrda.cast(contains, core.get_player_by_name(name), message)
    end
    local msg = "<" .. name .. "> "
    for i, v in pairs(msgparams.words) do
        if i == msgparams.i then
            msg = msg .. core.colorize("#88CCFF", msgparams.words[i]) .. " "
        else
            msg = msg .. msgparams.words[i] .. " "
        end 
    end
    minetest.chat_send_all(msg)
    return true
end)

dofile(modpath .. "/spells.lua")