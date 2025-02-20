local colors = {
    ["repetim"] = "#888",
    ["risier"] = "#48F",
    ["fiera"] = "#F84",
    ["disperim"] = "#84F",
    ["sanium"] = "#F48",
    ["expol"] = "#F44",
    ["hazum"] = "#Af0",
    ["flurra"] = "#8AF",
    ["fulst"] = "#FB4",
    ["empty"] = "#FFF",
}

for i, spell in pairs(wyrda.spells) do
    wyrda.register_wand({
        itemname = "wyrda:basic_" .. spell.name .. "_wand",
        name = "Basic Wand (" .. spell.descname .. ")\n" .. core.colorize("#AFA", wyrda.spells[spell.name].desc),
        invimage = "wyrda_basic_wand",
        spellname = spell.name,
        groups = {wand = 1, not_in_creative_inventory = 1},
        cooldown = spell.cooldown,
        color = colors[spell.name],
    })

    wyrda.register_book({
        bookname = spell.descname,
        spellname = spell.name,
        color = colors[spell.name],
    })

    wyrda.register_inscription_recipe({
        name = "basic_" .. spell.name .. "_wand",
        script = "wyrda:" .. spell.name .. "_spell_book",
        inscript = "wyrda:basic_wand",
        result = "wyrda:basic_" .. spell.name .. "_wand",
    })

    minetest.register_node("wyrda:" .. spell.name .. "_emblem", {
        description = spell.descname .. " Emblem",
        tiles = {"wyrda_nodes_carved_ghenstone.png^(wyrda_nodes_emblem_overlay.png^[colorize:" .. colors[spell.name] .. ":255)"},
        groups = {cracky = 3, emblem=1},
        light_source = 5,
    })

    --[[core.register_abm({ -- this is way to slow, ima use an entity instead
        label = spell.descname .. " Spell Emblem",
        nodenames = {"wyrda:" .. spell.name .. "_emblem"},
        interval = 0.1,
        chance = 1,
        catch_up = false,
        action = function(pos, node, active_object_count, active_object_count_wider)
            local objs = core.get_objects_inside_radius(pos, 1.5)
            for i, obj in pairs(objs) do
                if obj:is_player() then
                    wyrda.cast(wyrda.spells[spell.name], obj, "", pos, 1)
                end
            end
        end
    })]]
end

--[[

local objs = core.get_objects_inside_radius(pos, 1.5)
for i, obj in pairs(objs) do
    if obj:is_player() then
        wyrda.cast(spell.name, obj, "", pos, 1)
    end
end

]]