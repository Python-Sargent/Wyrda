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
        local vel = player:get_velocity()
        local y = vel.y
        local yd = 0
        if y > 0 then yd = 15 - y else yd = 15 end
        player:add_velocity(vector.new(0, yd, 0))
        if message == "" then return false end -- (ditto)
        return true
    end,
    func2 = function(player, message, pos)
        local vel = player:get_look_dir()
        player:add_velocity(vector.multiply(vel, 15))
        if message == "" then return false end -- (ditto)
        return true
    end,
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
        end,
        func2 = function(player, message, pos)
            if core.get_node(vector.add(pos, player:get_look_dir())).name == "air" then
                core.set_node(vector.add(pos, player:get_look_dir()), {name="fire:basic_flame"})
            end
            if message == "" then return false end -- (ditto)
            return true
        end,
    })
end

wyrda.register_spell("disperim", {
    desc = "Disperse nearby entities",
    cost = 10,
    cooldown = 1,
    func = function(player, message, pos)
        if pos == nil then return false end
        local objs = core.get_objects_inside_radius(player:get_pos(), 5)
        for i, obj in pairs(objs) do
            if obj:get_player_name() ~= player:get_player_name() then
                obj:add_velocity(vector.offset(vector.multiply(vector.direction(player:get_pos(), obj:get_pos()), 5), 0, 5, 0))
            end
        end
        if message == "" then return false end -- (ditto)
        return true
    end,
    func2 = function(player, message, pos)
        if pos == nil then return false end
        local objs = core.get_objects_inside_radius(player:get_pos(), 5)
        for i, obj in pairs(objs) do
            if obj:get_player_name() ~= player:get_player_name() then
                obj:add_velocity(vector.offset(vector.multiply(vector.direction(player:get_pos(), obj:get_pos()), 5), 0, 10, 0))
            end
        end
        player:add_velocity(vector.multiply(player:get_look_dir(), 10))
        if message == "" then return false end -- (ditto)
        return true
    end,
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
    end,
    func2 = function(player, message, pos)
        local hp = player:get_hp()
        player:set_hp(math.min(20, hp + 4))
        local objs = core.get_objects_inside_radius(pos, 5)
        for i, obj in pairs(objs) do
            if obj:get_player_name() ~= player:get_player_name() then
                obj:set_hp(obj:get_hp() - 2)
            end
        end
        if message == "" then return false end -- (ditto)
        return true
    end,
})

if core.get_modpath("tnt") ~= nil then
    wyrda.register_spell("expol", {
        desc = "Emit a powerful explosion",
        cost = 6,
        cooldown = 1,
        func = function(player, message, pos)
            local pos = player:get_pos()
            player:set_pos(vector.offset(pos, 0, 100, 0)) -- tp the player to be out of range of the explosion damage
            tnt.boom(pos, {
                radius = 1,
                damage_radius = 5,
                explode_center = false,
                ignore_protection = false,
            })
            player:set_pos(pos)
            if message == "" then return false end -- (ditto)
            return true
        end,
        func2 = function(player, message, pos)
            local pos = player:get_pos()
            player:set_pos(vector.offset(pos, 0, 100, 0))
            tnt.boom(pos, {
                radius = 2,
                damage_radius = 6,
                explode_center = true,
                ignore_protection = false,
            })
            player:set_pos(pos)
            player:set_hp(player:get_hp() + 4)
            if message == "" then return false end -- (ditto)
            return true
        end,
    })
end

wyrda.register_spell("empty", {
    desc = "Empty Spell (does nothing)",
    cost = 0,
    cooldown = 0,
    func = function(player, message, pos)
        if message ~= nil and message ~= "" then core.chat_send_all(message) end
        return false
    end,
    func2 = function(player, message, pos)
        if message ~= nil and message ~= "" then core.chat_send_all(message) end
        return false
    end,
})