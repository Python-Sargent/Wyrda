local function setInt(meta, key, value)
    meta:set_int(key, value)
    local v = meta:get_int(key)
    core.log("cooldown (3): " .. tostring(v) .. "\n")
end

local wand_cast = function(itemstack, user, pointed_thing, params)
    local meta = itemstack:get_meta()
    local cd = meta:get_int("cd")
    if cd == 0 then core.log("cooldown (0): " .. tostring(cd)) meta:set_int("cd", 2) end
    cd = meta:get_int("cd")
    core.log("cooldown (1): " .. tostring(cd))
    if cd == 2 then
        core.log("cooldown (1a): " .. tostring(cd))
        wyrda.cast(wyrda.spells[params.spellname], user, "", wyrda.pointed_to_pos(pointed_thing))
        meta:set_int("cd", 1)
    else
        core.log("cooldown (1b): " .. tostring(cd))
    end
    cd = meta:get_int("cd")
    core.log("cooldown (2): " .. tostring(cd))
    if cd == 1 then core.after(params.cooldown, setInt, meta, "cd", 2) end
    return itemstack
end

wyrda.register_wand = function(params)
    core.register_craftitem(params.itemname, {
        description = params.name,
        inventory_image = params.invimage,
        stack_max = 1,
        groups = {},
        --[[on_place = function(itemstack, placer, pointed_thing)
            local meta = itemstack:get_meta()
            local cd = meta:get_int("cooldown")
            if cd == nil then meta:set_int("cooldown", 0) end
            if cd == 0 then
                wyrda.cast(wyrda.spells[params.spellname], placer, "", wyrda.pointed_to_pos(pointed_thing))
                meta:set_int("cooldown", 1)
            end
            core.after(params.cooldown, setInt, meta, "cooldown", 0)
        end,
        on_secondary_use = function(itemstack, user, pointed_thing)
            local meta = itemstack:get_meta()
            local cd = meta:get_int("cooldown")
            if cd == nil then meta:set_int("cooldown", 0) end
            if cd == 0 then
                wyrda.cast(wyrda.spells[params.spellname], user, "", wyrda.pointed_to_pos(pointed_thing))
                meta:set_int("cooldown", 1)
            end
            core.after(params.cooldown, setInt, meta, "cooldown", 0)
        end,]]
        on_use = function(itemstack, user, pointed_thing)
            return wand_cast(itemstack, user, pointed_thing, params)
        end,
    })
end

wyrda.register_wand({
    itemname = "wyrda:basic_wand",
    name = "Basic Wand (Disperim)\n" .. core.colorize("#AFA", wyrda.spells["disperim"].desc),
    invimage = "wyrda_basic_wand.png",
    spellname = "disperim", -- TODO: MOVE THIS TO META
    cooldown = 5,
})
