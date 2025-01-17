local function setInt(meta, key, value)
    meta:set_int(key, value)
    local v = meta:get_int(key)
    --return v
end

local wand_cast = function(itemstack, user, pointed_thing, params, type)
    local meta = itemstack:get_meta()
    local cd = meta:get_int("cd")
    if cd == 0 then meta:set_int("cd", 2) end
    cd = meta:get_int("cd")
    if cd == 2 then
        wyrda.cast(wyrda.spells[params.spellname], user, "", wyrda.pointed_to_pos(pointed_thing), type)
        --meta:set_int("cd", 1)
    end
    cd = meta:get_int("cd")
    if cd == 1 then core.after(params.cooldown, setInt, meta, "cd", 2) end -- TODO: THIS ISNT SAVING THE META
    return itemstack
end

local wand_on_place = function(params)
    if params.spellname ~= nil and params.spellname ~= "" then
        local rf = function(itemstack, placer, pointed_thing)
            return wand_cast(itemstack, placer, pointed_thing, params, 2)
        end
        return rf
    end
    return function() end
end

local wand_on_secondary_use = function(params)
    if params.spellname ~= nil and params.spellname ~= "" then
        local rf = function(itemstack, user, pointed_thing)
            return wand_cast(itemstack, user, pointed_thing, params, 2)
        end
        return rf
    end
    return function() end
end

local wand_on_use = function(params)
    if params.spellname ~= nil and params.spellname ~= "" then
        local rf = function(itemstack, user, pointed_thing)
            return wand_cast(itemstack, user, pointed_thing, params, 1)
        end
        return rf
    end
    return function() end
end

wyrda.register_wand = function(params)
    core.register_craftitem(params.itemname, {
        description = params.name,
        inventory_image = params.invimage,
        stack_max = 1,
        groups = params.groups,
        on_place = wand_on_place(params),
        on_secondary_use = wand_on_secondary_use(params),
        on_use = wand_on_use(params),
    })
end

wyrda.register_wand({
    itemname = "wyrda:basic_risier_wand",
    name = "Basic Wand (Risier)\n" .. core.colorize("#AFA", wyrda.spells["risier"].desc),
    invimage = "wyrda_basic_wand.png",
    spellname = "risier",
    groups = {wand = 1, not_in_creative_inventory = 1},
    cooldown = 6,
})

wyrda.register_wand({
    itemname = "wyrda:basic_fiera_wand",
    name = "Basic Wand (Fiera)\n" .. core.colorize("#AFA", wyrda.spells["fiera"].desc),
    invimage = "wyrda_basic_wand.png",
    spellname = "fiera",
    groups = {wand = 1, not_in_creative_inventory = 1},
    cooldown = 2,
})

wyrda.register_wand({
    itemname = "wyrda:basic_disperim_wand",
    name = "Basic Wand (Disperim)\n" .. core.colorize("#AFA", wyrda.spells["disperim"].desc),
    invimage = "wyrda_basic_wand.png",
    spellname = "disperim",
    groups = {wand = 1, not_in_creative_inventory = 1},
    cooldown = 5,
})

wyrda.register_wand({
    itemname = "wyrda:basic_sanium_wand",
    name = "Basic Wand (Sanium)\n" .. core.colorize("#AFA", wyrda.spells["sanium"].desc),
    invimage = "wyrda_basic_wand.png",
    spellname = "sanium",
    groups = {wand = 1, not_in_creative_inventory = 1},
    cooldown = 4,
})

wyrda.register_wand({
    itemname = "wyrda:basic_expol_wand",
    name = "Basic Wand (Expol)\n" .. core.colorize("#AFA", wyrda.spells["expol"].desc),
    invimage = "wyrda_basic_wand.png",
    spellname = "expol",
    groups = {wand = 1, not_in_creative_inventory = 1},
    cooldown = 10,
})

wyrda.register_wand({
    itemname = "wyrda:basic_wand",
    name = "Basic Wand",
    invimage = "wyrda_basic_wand.png",
    groups = {wand = 1},
})
