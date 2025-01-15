wyrda.register_spell("repetim", {
    desc = "Speak without revealing yourself",
    cost = 1,
    cooldown = 0,
    func = function(player, message, pos)
        local msg = message:split("repetim")
        local mstr = ""
        for i, v in pairs(msg) do
            mstr = mstr .. msg[i] .. " "
        end
        core.chat_send_all(mstr)
        if message == "" then return false end -- makes sure we don't send empty strings
        return false
    end
})

wyrda.register_spell("risier", {
    desc = "Cause yourself to rise",
    cost = 9,
    cooldown = 1,
    func = function(player, message, pos)
        player:add_velocity(vector.new(0, 15, 0))
        if message == "" then return false end -- (ditto)
        return true
    end
})

if core.get_modpath("fire") ~= nil then
    wyrda.register_spell("fiera", {
        desc = "Burst into flames",
        cost = 5,
        cooldown = 0.1,
        func = function(player, message, pos)
            core.set_node(pos, {name="fire:basic_flame"})
            if message == "" then return false end -- (ditto)
            return true
        end
    })
end

wyrda.register_spell("disperim", {
    desc = "Disperse nearby entities",
    cost = 10,
    cooldown = 1,
    func = function(player, message, pos)
        if pos == nil then core.log("nopos") return false end
        local objs = core.get_objects_inside_radius(pos, 5)
        for i, obj in pairs(objs) do
            if obj:get_player_name() ~= player:get_player_name() then
                obj:add_velocity(vector.offset(vector.multiply(vector.direction(pos, obj:get_pos()), 5), 0, 5, 0))
            end
        end
        if message == "" then return false end -- (ditto)
        return true
    end
})

wyrda.register_spell("sanium", {
    desc = "Heal your injuries",
    cost = 10,
    cooldown = 1,
    func = function(player, message, pos)
        local hp = player:get_hp()
        player:set_hp(math.min(20, hp + 4))
        if message == "" then return false end -- (ditto)
        return true
    end
})

wyrda.register_spell("empty", {
    desc = "Empty Spell (does nothing)",
    cost = 0,
    cooldown = 0,
    func = function(player, message, pos)
        if message ~= nil and message ~= "" then core.chat_send_all(message) end
        return false
    end
})