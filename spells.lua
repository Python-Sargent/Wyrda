wyrda.register_spell("repetim", {
    desc = "Speak without revealing yourself",
    cost = 1,
    cooldown = 0,
    func = function(player, message)
        core.log(message)
    end
})

wyrda.register_spell("risier", {
    desc = "Cause yourself to rise",
    cost = 10,
    cooldown = 1,
    func = function(player, message)
        player:add_velocity(vector.new(0, 15, 0))
    end
})

if core.get_modpath("fire") ~= nil then
    wyrda.register_spell("fiera", {
        desc = "Burst into flames",
        cost = 7,
        cooldown = 0.1,
        func = function(player, message)
            core.set_node(player:get_pos(), {name="fire:basic_flame"})
        end
    })
end

wyrda.register_spell("disperim", {
    desc = "Disperse nearby entities",
    cost = 10,
    cooldown = 1,
    func = function(player, message)
        local objs = core.get_objects_inside_radius(player:get_pos(), 5)
        for i, obj in pairs(objs) do
            player:add_velocity(vector.multiply(vector.direction(player:get_pos(), obj:get_pos()), 5))
        end
    end
})
