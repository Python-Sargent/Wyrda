if not core.settings:has("singularity_size") then
    core.settings:set("singularity_size", 50)
end
if not core.settings:has("allow_singularities") then
    core.settings:set("allow_singularities", "false") --singularities must be turned on, the default is a nuke
end

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
            blend = "screen",
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

local frozen_entities = {}

local freeze_timer = 0

core.register_globalstep(function(dtime)
    freeze_timer = freeze_timer + dtime
    for i, v in pairs(frozen_entities) do
        if v then
            local obj = core.get_player_by_name(i)
            if v.timer == -1 then -- for init, '==' should prevent dtime lag from affecting
                v.timer = 3
                if obj ~= nil then obj:set_physics_override({ speed = 0.5, }) end
                local snow_overlay = obj:hud_add({
                    hud_elem_type = "image",
                    position  = {x = 0, y = 0},
                    offset    = {x = 0, y = 0},
                    text      = "wyrda_snow_overlay.png",
                    scale     = { x = 1, y = 1},
                    alignment = { x = 1, y = 1 },
                    z_index   = -400,
                })
                frozen_entities[i].hud_id = snow_overlay
            elseif v.timer > 0 then
                v.timer = v.timer - dtime
                if freeze_timer >= 1 then
                    obj:set_hp(obj:get_hp() - v.damage)
                    freeze_timer = 0
                end
            elseif v.timer <= 0  then
                if obj ~= nil then obj:set_physics_override({ speed = 1, }) end
                if frozen_entities[i].hud_id ~= nil then
                    obj:hud_remove(frozen_entities[i].hud_id)
                end
                frozen_entities[i] = nil
            end
        end
    end
end)

local electrified_entities = {}

local electrified_timer = 0

core.register_globalstep(function(dtime)
    electrified_timer = electrified_timer + dtime
    for i, v in pairs(electrified_entities) do
        if v then
            local obj = core.get_player_by_name(i)
            if v.timer == -1 then -- for init, '==' should prevent dtime lag from affecting
                v.timer = 3
                if obj ~= nil then obj:set_physics_override({ speed = 0.5, }) end
                local snow_overlay = obj:hud_add({
                    hud_elem_type = "image",
                    position  = {x = 0, y = 0},
                    offset    = {x = 0, y = 0},
                    text      = "wyrda_electric_overlay.png",
                    scale     = { x = 1, y = 1},
                    alignment = { x = 1, y = 1 },
                    z_index   = -400,
                })
                electrified_entities[i].hud_id = snow_overlay
            elseif v.timer > 0 then
                v.timer = v.timer - dtime
                if electrified_timer >= 1 then
                    obj:set_hp(obj:get_hp() - v.damage)
                    electrified_timer = 0
                end
            elseif v.timer <= 0  then
                if obj ~= nil then obj:set_physics_override({ speed = 1, }) end
                if electrified_entities[i].hud_id ~= nil then
                    obj:hud_remove(electrified_entities[i].hud_id)
                end
                electrified_entities[i] = nil
            end
        end
    end
end)

core.register_entity("wyrda:snowball", {
    initial_properties = {
        visual = "mesh",
        mesh = "snowball.obj",
        hp_max = 10,
        physical = true,
        collide_with_objects = true,
        collisionbox = { -0.25, -0.25, -0.25, 0.25, 0.25, 0.25 },
        selectionbox = { -0.25, -0.25, -0.25, 0.25, 0.25, 0.25, rotate = false },
        pointable = false,
        visual_size = {x = 5, y = 5, z = 5},
        textures = {"wyrda_snowball.png"},
        use_texture_alpha = false,
        is_visible = true,
        makes_footstep_sound = false,
        glow = 0,
        static_save = true,
        shaded = true,
        speed = 30,
        gravity = 10,
        lifetime = 60,
    },
    player_name = "",
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
        local collided_with_entity = moveresult.collisions[1] and moveresult.collisions[1].type == "object"

        if collided_with_node or collided_with_entity then
            local objs = core.get_objects_inside_radius(self.object:get_pos(), 4)
            for i, obj in pairs(objs) do
                if obj ~= self.object  and obj ~= core.get_player_by_name(self.player_name) then
                    if obj:is_player() and obj:get_player_name() ~= self.player_name then 
                        frozen_entities[obj:get_player_name()] = {
                            obj = obj:get_player_name(), timer = -1, damage = 0, hud_id = nil}
                    end
                end
            end

            core.add_particlespawner({
                amount = 300,
                time = 0.1,
                vertical = false,
                texture = {
                    name = "wyrda_spell_flurra_snow.png",
                    alpha_tween = {1, 0},
                    scale = 10,
                    blend = "screen",
                },
                glow = 0,
                pos_tween = {
                    style = "fwd",
                    reps = 1,
                    start = 0.0,
                    { min = vector.offset(self.object:get_pos(),  0.25,  0.25,  0.25),
                      max = vector.offset(self.object:get_pos(), -0.25, -0.25, -0.25), },
                    { min = vector.offset(self.object:get_pos(),  0.5,  0.5,  0.5),
                      max = vector.offset(self.object:get_pos(), -0.5, -0.25, -0.5), },
                    { min = vector.offset(self.object:get_pos(),  1,  1,  1),
                      max = vector.offset(self.object:get_pos(), -1, -0.25, -1), },
                    { min = vector.offset(self.object:get_pos(),  1.5,  1.5,  1.5),
                      max = vector.offset(self.object:get_pos(), -1.5, -0.25, -1.5), },
                    { min = vector.offset(self.object:get_pos(),  2,  2,  2),
                      max = vector.offset(self.object:get_pos(), -2, -0.25, -2), },
                    { min = vector.offset(self.object:get_pos(),  2.5,  2.5,  2.5),
                      max = vector.offset(self.object:get_pos(), -2.5, -0.25, -2.5), },
                    { min = vector.offset(self.object:get_pos(),  3,  3,  3),
                      max = vector.offset(self.object:get_pos(), -3, -0.25, -3), },
                    { min = vector.offset(self.object:get_pos(),  3.5,  3.5,  3.5),
                      max = vector.offset(self.object:get_pos(), -3.5, -0.25, -3.5), },
                    { min = vector.offset(self.object:get_pos(),  4,  4,  4),
                      max = vector.offset(self.object:get_pos(), -4, -0.25, -4), },
                },
            })
            self.object:remove()
        end
    end,
    get_staticdata = function(self) end,
})

core.register_entity("wyrda:icicle", {
    initial_properties = {
        visual = "mesh",
        mesh = "icicle.obj",
        hp_max = 20,
        physical = true,
        collide_with_objects = false,
        collisionbox = { -0.125, -0.5, -0.125, 0.125, 0.5, 0.125 },
        selectionbox = { -0.125, -0.5, -0.125, 0.125, 0.5, 0.125, rotate = true},
        pointable = true,
        visual_size = {x = 10, y = 10, z = 10},
        textures = {"wyrda_icicle.png"},
        use_texture_alpha = false,
        is_visible = true,
        makes_footstep_sound = false,
        glow = 0,
        static_save = true,
        shaded = true,
        lifetime = 20,
    },
    player_name = "",
    --timer = 0,
    on_activate = function(self, staticdata, dtime_s) 
        if not staticdata or not core.get_player_by_name(staticdata) then
            self.object:remove()
            return
        end
    
        self.player_name = staticdata
        local player = core.get_player_by_name(staticdata)
    
        core.after(self.initial_properties.lifetime, function() self.object:remove() end)
    end,
    on_deactivate = function(self, removal) end,
    on_step = function(self, dtime, moveresult)
        --self.timer = self.timer + dtime
        local objs = core.get_objects_inside_radius(self.object:get_pos(), 1)
        --[[if self.timer >= 1 then
            for i, obj in pairs(objs) do
                if obj ~= self.object and obj:get_player_name() ~= self.player_name then
                    if obj:is_player() then
                        obj:set_hp(obj:get_hp() - 1, core.get_player_by_name(self.player_name))
                    end
                end
            end
            self.timer = 0
        end]]
        for i, obj in pairs(objs) do
            if obj ~= self.object and obj ~= core.get_player_by_name(self.player_name) then
                if obj:is_player() then
                    if frozen_entities[obj:get_player_name()] == nil then frozen_entities[obj:get_player_name()] = {
                        obj = obj:get_player_name(), timer = -1, damage = 1, hud_id = nil} end
                end
            end
        end
        -- obj:set_hp(obj:get_hp() - 1, core.get_player_by_name(self.player_name))
    end,
    get_staticdata = function(self) end,
})

core.register_entity("wyrda:shield", {
    initial_properties = {
        visual = "mesh",
        mesh = "shield.obj",
        hp_max = 20,
        physical = true,
        collide_with_objects = true,
        collisionbox = { -0.5, -1, -0.5, 0.5, 1, 0.5 },
        selectionbox = { -0.5, -1, -0.5, 0.5, 1, 0.5, rotate = true},
        pointable = true,
        visual_size = {x = 10, y = 10, z = 10},
        textures = {"wyrda_shield.png"},
        use_texture_alpha = false,
        is_visible = true,
        makes_footstep_sound = false,
        glow = 0,
        static_save = true,
        shaded = true,
        lifetime = 10,
    },
    player_name = "",
    on_activate = function(self, staticdata, dtime_s) 
        if not staticdata or not core.get_player_by_name(staticdata) then
            self.object:remove()
            return
        end
    
        self.player_name = staticdata
        local player = core.get_player_by_name(staticdata)
        local dir = vector.dir_to_rotation(vector.direction(player:get_pos(), self.object:get_pos()))
        self.object:set_rotation(vector.new(0, dir.y, 0))
    
        core.after(self.initial_properties.lifetime, function() self.object:remove() end)
    end,
    on_deactivate = function(self, removal) end,
    on_step = function(self, dtime, moveresult) end,
    get_staticdata = function(self) end,
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
        core.add_particlespawner({
            amount = 10,
            time = 0.05,
            vertical = false,
            --texture = "wyrda_spell_" .. name .. ".png",
            texture = {
                name = "wyrda_spell_sanium_block.png",
                alpha_tween = {1, 0},
                scale = 10,
                blend = "screen",
            },
            --animation = {},
            glow = 0,
            --maxpos = {x = 0, y = 0, z = 0},
            --minpos = {x = 0, y = 0, z = 0},
            pos = {
                min = vector.offset(self.object:get_pos(), 0.5, 1., 0.5),
                max = vector.offset(self.object:get_pos(), -0.5, -1, -0.5),
            },
        })
    end,
})

core.register_entity("wyrda:fireball", {
    initial_properties = {
        visual = "mesh",
        mesh = "fireball.obj",
        hp_max = 10,
        physical = true,
        collide_with_objects = true,
        collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        selectionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5, rotate = false},
        pointable = false,
        visual_size = {x = 15, y = 15, z = 15},
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
    player_name = "",
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
        local collided_with_entity = moveresult.collisions[1] and moveresult.collisions[1].type == "object"

        if collided_with_node or collided_with_entity then
            
            if core.get_modpath("tnt") then tnt.boom(moveresult.collisions[1].node_pos, {radius = 2, damage_radius = 2}) end
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
        selectionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5, rotate = false },
        pointable = false,
        visual_size = {x = 5, y = 5, z = 5},
        textures = {"wyrda_bomb.png"},
        use_texture_alpha = false,
        is_visible = true,
        makes_footstep_sound = false,
        glow = 0,
        static_save = true,
        shaded = true,
        speed = 10,
        gravity = 10,
        lifetime = 20,
    },
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
        local collided_with_entity = moveresult.collisions[1] and moveresult.collisions[1].type == "object"

        if collided_with_node or collided_with_entity then
            local pos = moveresult.collisions[1].node_pos or moveresult.collisions[1].object:get_pos()
            if core.get_modpath("tnt") then tnt.boom(pos, {radius = 2, damage_radius = 2}) end
            self.object:remove()
        end
    end,
    get_staticdata = function(self) end,
})

local function detach_nodes(pos, radius)
	pos = vector.round(pos)
	local voxel_manip1 = VoxelManip()
	local pos1 = vector.subtract(pos, 2)
	local pos2 = vector.add(pos, 2)
	local minpos, maxpos = voxel_manip1:read_from_map(pos1, pos2)
	local voxel_area = VoxelArea:new({MinEdge = minpos, MaxEdge = maxpos})
	local data = voxel_manip1:get_data()
	local c_air = core.CONTENT_AIR
	local c_ignore = core.CONTENT_IGNORE

	local voxel_manip = VoxelManip()
    math.randomseed(os.time())
	local pseudo_random = PseudoRandom(os.time())
	pos1 = vector.subtract(pos, radius)
	pos2 = vector.add(pos, radius)
	minpos, maxpos = voxel_manip:read_from_map(pos1, pos2)
	voxel_area = VoxelArea:new({MinEdge = minpos, MaxEdge = maxpos})
	data = voxel_manip:get_data()

    local nodes = {}
	for z = -radius, radius do
        for y = -radius, radius do
            local vi = voxel_area:index(pos.x + (-radius), pos.y + y, pos.z + z)
            for x = -radius, radius do
                local radius2 = vector.length(vector.new(x, y, z))
                if (radius * radius) / (radius2 * radius2) >= (pseudo_random:next(80, 125) / 100) then
                    local content_id = data[vi]
                    local position = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
                    if content_id ~= c_air and content_id ~= c_ignore then
                        local rng = math.random(radius * (vector.distance(pos, position) * (vector.distance(pos, position) / 2)))
                        if rng == 1 then
                            local success, node = core.spawn_falling_node(position)
                            if success then table.insert(nodes, node) data[vi] = c_air end
                            --[[minetest.add_item(position, content_id)
                            core.set_node(position, {name="air"})]]
                        end
                    end
                end
                vi = vi + 1
            end
        end
	end

	voxel_manip:set_data(data)
	voxel_manip:write_to_map()
	voxel_manip:update_map()
	voxel_manip:update_liquids()

    return nodes
end

local function consume(se, obj)
    if obj:is_player() then
        core.chat_send_all(obj:get_player_name() .. " was consumed by a singularity.")
    end
    se.size = math.min(se.size + 1, tonumber(core.settings:get("singularity_size")) or 50) -- consuming entities enlarges the singularity
    local s = 0.5 + (se.size / 10) * 0.5
    local new_properties = {
        collisionbox = { -s, -s, -s, s, s, s },
        selectionbox = { -s, -s, -s, s, s, s, rotate = true},
    }
    new_properties.visual_size = {x=se.size, y=se.size}
    se.object:set_properties(new_properties)
end

core.register_entity("wyrda:black_hole", {
    initial_properties = {
        visual = "mesh",
        mesh = "black_hole.obj",
        hp_max = 1000,
        physical = true,
        collide_with_objects = false,
        collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        selectionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5, rotate = true},
        pointable = true,
        visual_size = {x = 10, y = 10, z = 10},
        textures = {"wyrda_darkness.png"},
        use_texture_alpha = false,
        is_visible = true,
        makes_footstep_sound = false,
        glow = 0,
        static_save = true,
        shaded = false,
        lifetime = 15,
    },
    player_name = "",
    tick_timer = 0,
    size = 10,
    on_activate = function(self, staticdata, dtime_s) 
        if not staticdata or not core.get_player_by_name(staticdata) then
            self.object:remove()
            return
        end
    
        self.player_name = staticdata
        self.tick_timer = 0
        local player = core.get_player_by_name(staticdata)

        core.after(self.initial_properties.lifetime, function() self.object:remove() end)
    end,
    on_deactivate = function(self, removal) end,
    on_step = function(self, dtime, moveresult)
        --self.object:set_velocity(vector.zero())
        self.tick_timer = self.tick_timer + dtime
        local objs = core.get_objects_inside_radius(self.object:get_pos(), self.size)
        for i, obj in pairs(objs) do
            if obj ~= self.object then
                local dist = vector.distance(self.object:get_pos(), obj:get_pos())
                if dist > 0.5 then
                    obj:add_velocity(vector.offset(vector.multiply(vector.direction(self.object:get_pos(), obj:get_pos()), -1 / (dist / dist)), 0, 0.2, 0))
                end
            end
        end
        if self.tick_timer >= 0.5 then
            for obj2 in core.objects_inside_radius(self.object:get_pos(), self.size / 10) do
                if obj2 ~= self.object then
                    local hp = obj2:get_hp()
                    local dmg = 4
                    if hp - dmg == 0 then
                        consume(self, obj2)
                    end
                    if hp >= 1 then obj2:set_hp(math.max(hp - dmg, 0), self.object) end
                end
            end
            --[[for i, node in pairs(nodes) do
                local objs = core.get_objects_inside_radius(node:get_pos(), 1)
                for i, obj in pairs(objs) do
                    if obj ~= node then
                        local le = obj:get_luaentity()
                        if le ~= nil and le.name == "item" then
                            obj:remove()
                        end
                    end
                end
            end]]
            self.tick_timer = 0
        end
        local nodes = detach_nodes(self.object:get_pos(), math.min(self.size / 10, tonumber(core.settings:get("singularity_size")) or 50))
        for obj in core.objects_inside_radius(self.object:get_pos(), self.size / 10) do
            if obj ~= self.object then
                local le = obj:get_luaentity()
                if le ~= nil and le.name == "__builtin:falling_node" then
                    consume(self, obj)
                    return obj:remove()
                end
            end
        end
        for obj3 in core.objects_inside_radius(self.object:get_pos(), 1) do
            if obj3 ~= self.object then
                local pos = self.object:get_pos()
                if vector.check(pos) and pos.x ~= false then
                    obj3:set_pos(self.object:get_pos())
                    obj3:set_velocity(vector.new(0, 0, 0))
                end
            end
        end
    end,
    get_staticdata = function(self) end,
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage) end,
})

--[[wyrda.plot_line = function(pos1, pos2)
    core.add_particlespawner({
        amount = 10000,
        time = 1,
        texture = {
            name = "wyrda_square.png",
            scale = 1,
        },
        pos = {
            min = pos1,
            max = pos2,
        },
    })
    core.add_particlespawner({
        amount = 100,
        time = 1,
        texture = {
            name = "wyrda_square_red.png",
            scale = 1,
        },
        pos = {
            min = vector.offset(pos1, 0.1, 0.1, 0.1),
            max = vector.offset(pos1, -0.1, -0.1, -0.1),
        },
    })
    core.add_particlespawner({
        amount = 100,
        time = 1,
        texture = {
            name = "wyrda_square_blue.png",
            scale = 1,
        },
        pos = {
            min = vector.offset(pos2, 0.1, 0.1, 0.1),
            max = vector.offset(pos2, -0.1, -0.1, -0.1),
        },
    })
end

core.register_entity("wyrda:lightning", {
    initial_properties = {
        visual = "mesh",
        mesh = "lightning.obj",
        hp_max = 20,
        physical = false,
        collide_with_objects = false,
        collisionbox = { -0, -0, -0, 0, 0, 0 },
        selectionbox = { -0, -0, -0, 0, 0, 0 },
        pointable = false,
        visual_size = {x = 10, y = 10, z = 10},
        textures = {
            "wyrda_lightning.png",
        },
        use_texture_alpha = true,
        is_visible = true,
        makes_footstep_sound = false,
        glow = 14,
        backface_culling = false,
        static_save = false,
        shaded = true,
        lifetime = 1,
    },
    player_name = "",
    timer = 1.1, -- to force it to damage on the first step
    on_activate = function(self, staticdata, dtime_s) 
        if not staticdata then
            self.object:remove()
            return
        end
    
        if staticdata ~= "" and not vector.check(core.string_to_pos(staticdata)) and core.get_player_by_name(staticdata) then
            self.player_name = staticdata
            local player = core.get_player_by_name(staticdata)
            local yaw = player:get_look_horizontal()
            local pitch = player:get_look_vertical()
            local dir = player:get_look_dir()

            self.object:set_pos((vector.add(self.object:get_pos(), vector.multiply(dir, 5))))
        
            self.object:set_rotation({x = -pitch, y = yaw, z = 0})
        elseif vector.check(core.string_to_pos(staticdata)) then
            local stp = core.string_to_pos(staticdata)
            local pitch = stp.x
            local yaw = stp.y
            self.object:set_rotation({x = -pitch, y = yaw, z = 0})
        end
    
        core.after(self.initial_properties.lifetime, function() self.object:remove() end)
    end,
    on_deactivate = function(self, removal) end,
    on_step = function(self, dtime, moveresult)
        self.timer = self.timer + dtime
        local r = self.object:get_rotation()
        local y = self.object:get_yaw()
        local rot = vector.new(r.x, y, r.z)
        local pos1 = vector.new(
            self.object:get_pos().x + math.cos(rot.x) * 5,
            self.object:get_pos().y + math.sin(rot.y) * 5,
            self.object:get_pos().z + math.cos(rot.z) * 5)
        local pos2 = vector.new(
            self.object:get_pos().x - math.cos(rot.x) * 5,
            self.object:get_pos().y - math.sin(rot.y) * 5,
            self.object:get_pos().z - math.cos(rot.z) * 5)
        if self.timer >= 1 then
            local ray = core.raycast(pos1, pos2, true, false)
            for pointed_thing in ray do
                if pointed_thing and pointed_thing.type == "object" then
                    local obj = pointed_thing.ref
                    if obj ~= self.object then -- and obj:get_player_name() ~= self.player_name
                        obj:set_hp(obj:get_hp() - 4)
                    end
                end
            end
            wyrda.plot_line(pos1, pos2)
            self.timer = 0
        end
        local ray = core.raycast(pos1, pos2, true, false)
        for pointed_thing in ray do
            if pointed_thing and pointed_thing.type == "object" then
                local obj = pointed_thing.ref
                if obj ~= self.object then -- and obj:get_player_name() ~= self.player_name
                    if electrified_entities[obj:get_player_name()] == nil then
                        electrified_entities[obj:get_player_name()] = {
                        obj = obj:get_player_name(), timer = -1, damage = 0, hud_id = nil}
                    end
                end
            end
        end
        wyrda.plot_line(pos1, pos2)
        self.timer = 0
    end,
    get_staticdata = function(self) end,
})

-- Function to create a rotation matrix from Euler angles (in radians)
local function rotationMatrix(pos)
    local cosX = math.cos(pos.x)
    local sinX = math.sin(pos.x)
    local cosY = math.cos(pos.y)
    local sinY = math.sin(pos.y)
    local cosZ = math.cos(pos.z)
    local sinZ = math.sin(pos.z)

    local matrix = {
        {cosY * cosZ, cosX * sinZ + sinX * sinY * cosZ, sinX * sinZ - cosX * sinY * cosZ},
        {-cosY * sinZ, cosX * cosZ - sinX * sinY * sinZ, sinX * cosZ + cosX * sinY * sinZ},
        {sinY, -sinX * cosY, cosX * cosY}
    }
    return matrix
end

-- Function to multiply a matrix and a vector
local function matrixVectorMultiply(matrix, vector)
    local x = matrix[1][1] * vector[1] + matrix[1][2] * vector[2] + matrix[1][3] * vector[3]
    local y = matrix[2][1] * vector[1] + matrix[2][2] * vector[2] + matrix[2][3] * vector[3]
    local z = matrix[3][1] * vector[1] + matrix[3][2] * vector[2] + matrix[3][3] * vector[3]
    return vector.new(x, y, z)
end

local function calculate_points(center, rot, d)
    -- Baseline vector
    local baselineVector = vector.new(1, 0, 0)

    -- Create rotation matrix
    local rotation = rotationMatrix(rot)

    -- Apply rotation to baseline vector
    local rotatedVector = matrixVectorMultiply(rotation, baselineVector)

    -- Create rotated vector with inverse rotation
    local inverseRotation = rotationMatrix(-rot)
    local rotatedVector2 = matrixVectorMultiply(inverseRotation, baselineVector)

    -- Calculate points
    local x1 = center.x + d * rotatedVector[1]
    local y1 = center.y + d * rotatedVector[2]
    local z1 = center.z + d * rotatedVector[3]

    local x2 = center.x + d * rotatedVector2[1]
    local y2 = center.y + d * rotatedVector2[2]
    local z2 = center.z + d * rotatedVector2[3]

    return vector.new(x1, y1, z1), vector.new(x2, y2, z2)
end

core.register_entity("wyrda:ball_lightning", {
    initial_properties = {
        visual = "mesh",
        mesh = "ball_lightning.obj",
        hp_max = 10,
        physical = true,
        collide_with_objects = false,
        collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        selectionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        pointable = false,
        visual_size = {x = 10, y = 10, z = 10},
        textures = {"wyrda_ball_lightning.png"},
        use_texture_alpha = true,
        backface_culling = false,
        is_visible = true,
        makes_footstep_sound = false,
        glow = 14,
        static_save = true,
        shaded = false,
        speed = 0,
        lifetime = 60,
    },
    player_name = "",
    timer = 0,
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
        --self.object:set_acceleration({x=dir.x*-4, y=0, z=dir.z*-4})
    
        core.after(self.initial_properties.lifetime, function() self.object:remove() end)
    end,
    on_deactivate = function(self, removal) end,
    on_step = function(self, dtime, moveresult)
        self.timer = self.timer + dtime
        if self.timer >= 1 then
            for obj in core.objects_inside_radius(self.object:get_pos(), 5) do
                if obj ~= self.object then
                    local rot_h = self.object:get_rotation()
                    local yaw = self.object:get_yaw()
                    --local dir = vector.rotate(self.object:get_pos(), vector.new(rot.x, yaw, rot.z))
                    local starting_pos = self.object:get_pos()

                    local rot = vector.new(rot_h.x, yaw, rot_h.y)
                    rot = vector.direction(self.object:get_pos(), -obj:get_pos())
                    local d = 5

                    local p1, p2 = calculate_points(starting_pos, rot, d)
                    local dir = vector.direction(p1, p2)

                    local lightning = core.add_entity(starting_pos, "wyrda:lightning", core.pos_to_string(dir))
                    core.add_particlespawner({
                        amount = 100,
                        time = 1,
                        vertical = false,
                        texture = {
                            name = "wyrda_spell_fulst_sparks.png",
                            alpha_tween = {1, 0},
                            scale = 3,
                            blend = "screen",
                        },
                        glow =14,
                        attached = lightning,
                        pos = {
                            min = vector.new(0.25, 0.25, 5),
                            max = vector.new(-0.25, -0.25, -5),
                        },
                    })
                    --obj:set_hp(obj:get_hp() - 2)
                end
            end
            self.timer = 0
        end
    end,
    get_staticdata = function(self) end,
})]]--

-- Spells

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
    cost2 = 12,
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
        cost2 = 9,
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
            local throw_starting_pos = vector.offset(player:get_pos(), 0, 1.5, 0)
            local fireball = core.add_entity(throw_starting_pos, "wyrda:fireball", player:get_player_name())
            core.add_particlespawner({
                amount = 10000,
                time = 20,
                vertical = false,
                texture = {
                    name = "wyrda_spell_fiera_smoke.png",
                    alpha_tween = {1, 0},
                    scale = 4,
                    blend = "screen",
                },
                --animation = {},
                glow = 10,
                --maxpos = {x = 0, y = 0, z = 0},
                --minpos = {x = 0, y = 0, z = 0},
                attached = fireball,
                pos = {
                    min = vector.new(0.75, 0.75, 0.75),
                    max = vector.new(-0.75, -0.75, -0.75),
                },
            })
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
    cost = 10,
    cost2 = 17,
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
        local positions = {}
        for i, obj in pairs(objs) do
            if obj:get_player_name() ~= player:get_player_name() then
                obj:add_velocity(vector.offset(vector.multiply(vector.direction(player:get_pos(), obj:get_pos()), 5), 0, 10, 0))
                table.insert(positions, obj)
            end
        end
        for i, obj in pairs(positions) do
            local pos = obj:get_pos()
            obj:set_pos(player:get_pos())
            player:set_pos(pos)
        end
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
    cost2 = 14,
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
        local pos = player:get_pos()
        local positions = {}
        local num_points = 6
        local radius = 2
        local inc = 2 * math.pi / num_points
        for i in range{num_points} do
            local angle = i * inc
            local x = pos.x + radius * math.cos(angle)
            local z = pos.z + radius * math.sin(angle)
            table.insert(positions, {x = x, y = pos.y + 1, z = z})
        end
        local shields = {}
        for i, v in pairs(positions) do
            shields[i] = core.add_entity(v, "wyrda:shield", player:get_player_name())
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
        cost = 14,
        cost2 = 19,
        cooldown = 10,
        func = function(player, message, pos)
            local throw_starting_pos = vector.offset(player:get_pos(), 0, 1.5, 0)
            local bomb = core.add_entity(throw_starting_pos, "wyrda:bomb", player:get_player_name())
            core.add_particlespawner({
                amount = 5000,
                time = 20,
                vertical = false,
                texture = {
                    name = "wyrda_spell_expol_flame.png",
                    alpha_tween = {1, 0},
                    scale = 3,
                    blend = "screen",
                },
                --animation = {},
                glow = 10,
                --maxpos = {x = 0, y = 0, z = 0},
                --minpos = {x = 0, y = 0, z = 0},
                attached = bomb,
                pos = {
                    min = vector.new(0.5, 0.5, 0.5),
                    max = vector.new(-0.5, -0.5, -0.5),
                },
            })
            spell_particles(player, "expol")
            if message == "" then return false end -- (ditto)
            return true
        end,
        func2 = function(player, message, pos)
            if core.settings:get("allow_singularities") == "true" then
                local dir = vector.multiply(player:get_look_dir(), 5)
                local start = vector.offset(player:get_pos(), dir.x, 0, dir.z)
                local black_hole = core.add_entity(start, "wyrda:black_hole", player:get_player_name())
            else
                -- nuke
            end
            spell_particles(player, "expol")
            if message == "" then return false end -- (ditto)
            return true
        end,
    })
end

wyrda.register_spell("flurra", {
    name = "flurra",
    descname = "Flurra",
    desc = "Freeze your enemies",
    cost = 9,
    cost2 = 12,
    cooldown = 6,
    func = function(player, message, pos)
        -- snowball (damage, knockback, freezing)
        local throw_starting_pos = vector.offset(player:get_pos(), 0, 1.5, 0)
        local snowball = core.add_entity(throw_starting_pos, "wyrda:snowball", player:get_player_name())
        core.add_particlespawner({
            amount = 10000,
            time = 60,
            vertical = false,
            texture = {
                name = "wyrda_spell_flurra_snow.png",
                alpha_tween = {1, 0},
                scale = 3,
                blend = "screen",
            },
            --animation = {},
            glow = 0,
            --maxpos = {x = 0, y = 0, z = 0},
            --minpos = {x = 0, y = 0, z = 0},
            attached = snowball,
            pos = {
                min = vector.new(0.25, 0.25, 0.25),
                max = vector.new(-0.25, -0.25, -0.25),
            },
        })
        spell_particles(player, "flurra")
        if message == "" then return false end -- (ditto)
        return true
    end,
    func2 = function(player, message, pos)
        -- icicle minefield (damage, freezing)
        local pos = player:get_pos()
        local positions = {}
        local num_points = 30
        local radius = 2
        local inc = 2 * math.pi / num_points
        for i in range{num_points} do
            local dx = math.random(-10, 10) / 5
            local dz = math.random(-10, 10) / 5
            table.insert(positions, vector.offset(pos, dx, 0.5, dz))
        end
        local icicles = {}
        for i, v in pairs(positions) do
            icicles[i] = core.add_entity(v, "wyrda:icicle", player:get_player_name())
        end
        spell_particles(player, "flurra")
        if message == "" then return false end -- (ditto)
        return true
    end,
})

--[[wyrda.register_spell("fulst", {
    name = "fulst",
    descname = "Fulst",
    desc = "Spark with electric power",
    cost = 12,
    cost2 = 14,
    cooldown = 6,
    func = function(player, message, pos)
        -- focused storm (lightning bolt)
        local starting_pos = vector.offset(player:get_pos(), 0, 1.5, 0)
        local lightning = core.add_entity(starting_pos, "wyrda:lightning", player:get_player_name())
        core.add_particlespawner({
            amount = 100,
            time = 1,
            vertical = false,
            texture = {
                name = "wyrda_spell_fulst_sparks.png",
                alpha_tween = {1, 0},
                scale = 3,
                blend = "screen",
            },
            --animation = {},
            glow =14,
            --maxpos = {x = 0, y = 0, z = 0},
            --minpos = {x = 0, y = 0, z = 0},
            attached = lightning,
            pos = {
                min = vector.new(0.25, 0.25, 5),
                max = vector.new(-0.25, -0.25, -5),
            },
        })
        spell_particles(player, "fulst")
        if message == "" then return false end -- (ditto)
        return true
    end,
    func2 = function(player, message, pos)
        -- ball lightning (spark grenade)
        local throw_starting_pos = vector.offset(player:get_pos(), 0, 1.5, 0)
        local ball_lightning = core.add_entity(throw_starting_pos, "wyrda:ball_lightning", player:get_player_name())
        core.add_particlespawner({
            amount = 600,
            time = 60,
            vertical = false,
            texture = {
                name = "wyrda_spell_fulst_sparks.png",
                alpha_tween = {1, 0},
                scale = 3,
                blend = "screen",
            },
            --animation = {},
            glow = 14,
            --maxpos = {x = 0, y = 0, z = 0},
            --minpos = {x = 0, y = 0, z = 0},
            attached = ball_lightning,
            pos_tween = {
                style = "fwd",
                reps = 1,
                start = 0.0,
                { min = vector.new(0.25,  0.25,  0.25),
                  max = vector.new(-0.25,  -0.25,  -0.25), },
                { min = vector.new(0.35,  0.35,  0.35),
                  max = vector.new(-0.35,  -0.35,  -0.35), },
                { min = vector.new(0.45,  0.45,  0.45),
                  max = vector.new(-0.45,  -0.45,  -0.45), },
                { min = vector.new(0.5,  0.5,  0.5),
                  max = vector.new(-0.5,  -0.5,  -0.5), },
            },
        })
        spell_particles(player, "fulst")
        if message == "" then return false end -- (ditto)
        return true
    end,
})

wyrda.register_spell("hazum", {
    name = "hazum",
    descname = "Hazum",
    desc = "Biohazardous",
    cost = 12,
    cost2 = 14,
    cooldown = 6,
    func = function(player, message, pos)
        -- corrosive puddle
        spell_particles(player, "hazum")
        if message == "" then return false end -- (ditto)
        return true
    end,
    func2 = function(player, message, pos)
        -- acid rain
        spell_particles(player, "hazum")
        if message == "" then return false end -- (ditto)
        return true
    end,
})]]

wyrda.register_spell("empty", {
    name = "empty",
    descname = "Empty",
    desc = "Empty Spell (does nothing)",
    cost = 0,
    cost2 = 0,
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