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

core.register_entity("wyrda:shield", {
    initial_properties = {
        visual = "mesh",
        mesh = "shield.obj",
        hp_max = 10,
        physical = true,
        collide_with_objects = true,
        collisionbox = { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 },
        selectionbox = { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5, rotate = true},
        pointable = true,
        visual_size = {x = 1, y = 1, z = 1},
        textures = {"wyrda_shield.png"},
        use_texture_alpha = false,
        is_visible = true,
        makes_footstep_sound = false,
        glow = 0,
        static_save = true,
        shaded = true,
        lifetime = 60,

        on_activate = function(self, staticdata, dtime_s) end,
        on_deactivate = function(self, removal) end,
        on_step = function(self, dtime, moveresult) end,
        get_staticdata = function(self) end,
    }
})

core.register_entity("wyrda:fireball", {
    initial_properties = {
        visual = "mesh",
        mesh = "fireball.obj",
        hp_max = 10,
        physical = true,
        collide_with_objects = true,
        collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        selectionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5, rotate = true},
        pointable = false,
        visual_size = {x = 25, y = 25, z = 25},
        textures = {"wyrda_fireball.png"},
        use_texture_alpha = false,
        is_visible = true,
        makes_footstep_sound = false,
        glow = 14,
        static_save = true,
        shaded = true,
        speed = 35,
        gravity = 1,
        lifetime = 60,
    },
    --player_name = "",
    on_activate = function(self, staticdata, dtime_s)
        if not staticdata or not core.get_player_by_name(staticdata) then
            self.object:remove()
            return
            end
        
            self.player_name = staticdata
            local player = core.get_player_by_name(staticdata)
            local yaw = player:get_look_horizontal()
            local pitch = player:get_look_vertical()
            local dir = player:get_look_dir()
        
            self.object:set_rotation({x = -pitch, y = yaw, z = 0})
            self.object:set_velocity({
                x=(dir.x * self.initial_properties.speed),
                y=(dir.y * self.initial_properties.speed),
                z=(dir.z * self.initial_properties.speed),
            })
            self.object:set_acceleration({x=dir.x*-4, y=-self.initial_properties.gravity, z=dir.z*-4})
        
            core.after(self.initial_properties.lifetime, function() self.object:remove() end)
    end,
    on_deactivate = function(self, removal) end,
    on_step = function(self, dtime, moveresult)
        local collided_with_node = moveresult.collisions[1] and moveresult.collisions[1].type == "node"
        local collided_with_entity = moveresult.collisions[1] and moveresult.collisions[1].type == "entity"

        if collided_with_node or collided_with_entity then
            
            if core.get_modpath("tnt") then tnt.boom(moveresult.collisions[1].node_pos, {radius = 5, damage_radius = 10}) end
            self.object:remove()
        end
    end,
    get_staticdata = function(self) end,
})

core.register_entity("wyrda:bomb", {
    initial_properties = {
        visual = "mesh",
        mesh = "bomb.obj",
        hp_max = 10,
        physical = true,
        collide_with_objects = true,
        collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        selectionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5, rotate = true},
        pointable = false,
        visual_size = {x = 1, y = 1, z = 1},
        textures = {"wyrda_bomb.png"},
        use_texture_alpha = false,
        is_visible = true,
        makes_footstep_sound = false,
        glow = 0,
        static_save = true,
        shaded = true,
        speed = 10,
        gravity = 9,
        lifetime = 20,

        on_activate = function(self, staticdata, dtime_s) end,
        on_deactivate = function(self, removal) end,
        on_step = function(self, dtime, moveresult) end,
        get_staticdata = function(self) end,
    }
})

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

if core.get_modpath("fire") ~= nil and core.get_modpath("tnt") ~= nil then
    wyrda.register_spell("fiera", {
        name = "fiera",
        descname = "Fiera",
        desc = "Burst into flames",
        cost = 5,
        cooldown = 2,
        func = function(player, message, pos)
            if core.get_node(vector.add(player:get_pos(), player:get_look_dir())).name == "air" then
                core.set_node(vector.add(player:get_pos(), player:get_look_dir()), {name="fire:basic_flame"})
                spell_particles(player, "fiera")
            end
            spell_particles(player, "fiera")
            if message == "" then return false end -- (ditto)
            return true
        end,
        func2 = function(player, message, pos)
            local throw_starting_pos = vector.offset(player:get_pos(), 0, 1, 0)
            local fireball = core.add_entity(throw_starting_pos, "wyrda:fireball", player:get_player_name())
            --core.sound_play("fireball_throw", {max_hear_distance = 15, pos = player:get_pos()})
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