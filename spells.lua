local spell_particles = function(player, name)
    core.add_particlespawner({
        amount = 25,
        time = 0.2,
        vertical = false,
        --texture = "wyrda_spell_" .. name .. ".png",
        texture = {
            name = "wyrda_spell_" .. name .. ".png",
            alpha_tween = {1, 0},
            scale = 3,
            blend = "add",
        },
        --animation = {},
        glow = 10,
        --maxpos = {x = 0, y = 0, z = 0},
        --minpos = {x = 0, y = 0, z = 0},
        pos = {
            min = vector.offset(player:get_pos(), 0.75, 1.75, 0.75),
            max = vector.offset(player:get_pos(), -0.75, -0.75, -0.75),
        },
    })
end

-- repetim (grey)
-- risier (lightblue)
-- fiera (orange)
-- disperim (purple)
-- sanium (pink)
-- expol (red)

wyrda.register_spell("repetim", {
    name = "repetim",
    descname = "Repetim",
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
    name = "risier",
    descname = "Risier",
    desc = "Cause yourself to rise",
    cost = 9,
    cooldown = 6,
    func = function(player, message, pos)
        local vel = player:get_velocity()
        local y = vel.y
        local yd = 0
        if y > 0 then yd = 15 - y else yd = 15 end
        player:add_velocity(vector.new(0, yd, 0))
        spell_particles(player, "risier")
        if message == "" then return false end -- (ditto)
        return true
    end,
    func2 = function(player, message, pos)
        local vel = player:get_look_dir()
        player:add_velocity(vector.multiply(vel, 15))
        spell_particles(player, "risier")
        if message == "" then return false end -- (ditto)
        return true
    end,
})

if core.get_modpath("fire") ~= nil then
    wyrda.register_spell("fiera", {
        name = "fiera",
        descname = "Fiera",
        desc = "Burst into flames",
        cost = 5,
        cooldown = 2,
        func = function(player, message, pos)
            core.set_node(pos, {name="fire:basic_flame"})
            spell_particles(player, "fiera")
            if message == "" then return false end -- (ditto)
            return true
        end,
        func2 = function(player, message, pos)
            if core.get_node(vector.add(pos, player:get_look_dir())).name == "air" then
                core.set_node(vector.add(pos, player:get_look_dir()), {name="fire:basic_flame"})
                spell_particles(player, "rfiera")
            end
            if message == "" then return false end -- (ditto)
            return true
        end,
    })
end

wyrda.register_spell("disperim", {
    name = "disperim",
    descname = "Disperim",
    desc = "Disperse nearby entities",
    cost = 15,
    cooldown = 5,
    func = function(player, message, pos)
        if pos == nil then return false end
        local objs = core.get_objects_inside_radius(player:get_pos(), 5)
        for i, obj in pairs(objs) do
            if obj:get_player_name() ~= player:get_player_name() then
                obj:add_velocity(vector.offset(vector.multiply(vector.direction(player:get_pos(), obj:get_pos()), 5), 0, 5, 0))
            end
        end
        spell_particles(player, "disperim")
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
        spell_particles(player, "disperim")
        if message == "" then return false end -- (ditto)
        return true
    end,
})

wyrda.register_spell("sanium", {
    name = "sanium",
    descname = "Sanium",
    desc = "Heal your injuries",
    cost = 9,
    cooldown = 4,
    func = function(player, message, pos)
        local hp = player:get_hp()
        player:set_hp(math.min(20, hp + 4))
        spell_particles(player, "sanium")
        if message == "" then return false end -- (ditto)
        return true
    end,
    func2 = function(player, message, pos)
        local hp = player:get_hp()
        player:set_hp(math.min(20, hp + 4))
        local objs = core.get_objects_inside_radius(player:get_pos(), 5)
        for i, obj in pairs(objs) do
            if obj:get_player_name() ~= player:get_player_name() then
                obj:set_hp(obj:get_hp() - 2)
            end
        end
        spell_particles(player, "sanium")
        if message == "" then return false end -- (ditto)
        return true
    end,
})

if core.get_modpath("tnt") ~= nil then
    wyrda.register_spell("expol", {
        name = "expol",
        descname = "Expol",
        desc = "Emit a powerful explosion",
        cost = 19,
        cooldown = 10,
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
            spell_particles(player, "expol")
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
            player:set_hp(player:get_hp() - 8)
            spell_particles(player, "expol")
            if message == "" then return false end -- (ditto)
            return true
        end,
    })
end

wyrda.register_spell("empty", {
    name = "empty",
    descname = "Empty",
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