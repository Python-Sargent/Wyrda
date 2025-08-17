if not core.settings:has("allow_crafting_wands") then
    core.settings:set("allow_crafting_wands", "true")
end

if core.settings:get("allow_crafting_wands") == "true" then
    core.register_craftitem("wyrda:basic_wand_staff", {
        description = "Basic Wand Staff",
        inventory_image = "wyrda_basic_staff.png",
    })

    --[[
    core.register_craftitem("wyrda:calibrated_gemstone", {
        description = "Calibrated Gemstone",
        inventory_image = "wyrda_calibrated_gemstone.png",
        groups = {},
    })

    core.register_craftitem("wyrda:stricken_gemstone", {
        description = "Stricken Gemstone",
        inventory_image = "wyrda_stricken_gemstone.png",
        groups = {},
    })

    core.register_craftitem("wyrda:augmented_gemstone", {
        description = "Augmented Gemstone",
        inventory_image = "wyrda_Augmented_gemstone.png",
        groups = {},
    })

    core.register_craftitem("wyrda:thwarted_gemstone", {
        description = "Thwarted Gemstone",
        inventory_image = "wyrda_thwarted_gemstone.png",
        groups = {},
    })

    core.register_craftitem("wyrda:deepened_gemstone", {
        description = "Deepened Gemstone",
        inventory_image = "wyrda_deepened_gemstone.png",
        groups = {},
    })

    core.register_craftitem("wyrda:corroupted_gemstone", {
        description = "Corroupted Gemstone",
        inventory_image = "wyrda_corroupted_gemstone.png",
        groups = {},
    })

    core.register_craftitem("wyrda:elegant_gemstone", {
        description = "Elegant Gemstone",
        inventory_image = "wyrda_elegant_gemstone.png",
        groups = {},
    })

    core.register_craftitem("wyrda:crude_gemstone", {
        description = "Crude Gemstone",
        inventory_image = "wyrda_crude_gemstone.png",
        groups = {},
    })

    core.register_craftitem("wyrda:distorted_gemstone", {
        description = "Distorted Gemstone",
        inventory_image = "wyrda_distorted_gemstone.png",
        groups = {},
    })


    core.register_craftitem("wyrda:hardened_wand_staff", {
        description = "Hardened Wand Staff",
        inventory_image = "wyrda_hardened_staff.png",
        groups = {},
    })
    ]] -- just some stuff that I might add sometime

    if core.get_modpath("default") ~= nil then

        minetest.register_craft({
            output = "wyrda:basic_wand",
            recipe = {
                {"", "", "wyrda:basic_gemstone"},
                {"", "wyrda:basic_wand_staff", ""},
            }
        })

        minetest.register_craft({
            output = "wyrda:basic_wand_staff",
            recipe = {
                {"", "default:gold_ingot", "default:stick"},
                {"default:gold_ingot", "default:stick", "default:gold_ingot"},
                {"default:stick", "default:gold_ingot", ""},
            }
        })
    end
end

core.register_craftitem("wyrda:basic_gemstone", {
    description = "Basic Gemstone",
    inventory_image = "wyrda_basic_gemstone.png",
})

core.register_craftitem("wyrda:energized_gemstone", {
    description = "Energized Gemstone",
    inventory_image = "wyrda_energized_gemstone.png",
})

if core.get_modpath("default") ~= nil then
    minetest.register_craft({
        output = "wyrda:basic_gemstone",
        recipe = {
            {"default:mese_crystal", "default:mese_crystal", "default:mese_crystal"},
            {"default:mese_crystal", "default:diamond", "default:mese_crystal"},
            {"default:mese_crystal", "default:mese_crystal", "default:mese_crystal"},
        }
    })

    minetest.register_craft({
        output = "wyrda:energized_gemstone",
        recipe = {
            {"default:mese_crystal", "default:diamond", "default:mese_crystal"},
            {"default:diamond", "wyrda:basic_gemstone", "default:diamond"},
            {"default:mese_crystal", "default:diamond", "default:mese_crystal"},
        }
    })

    minetest.register_craft({
        output = "wyrda:inscription_table",
        recipe = {
            {"", "default:book", ""},
            {"default:mese_crystal", "group:wood", "default:mese_crystal"},
            {"group:wood", "group:wood", "group:wood"},
        }
    })

    minetest.register_craft({
        output = "wyrda:empty_spell_book",
        recipe = {
            {"default:gold_ingot", "default:steel_ingot", "default:gold_ingot"},
            {"default:paper", "default:book", "default:paper"},
            {"default:gold_ingot", "default:steel_ingot", "default:gold_ingot"},
        }
    })
else
    minetest.register_craft({
        output = "wyrda:inscription_table", -- craft for if default mod is not available
        recipe = {
            {"", "wyrda:empty_spell_book", ""},
            {"wyrda:energized_gemstone", "group:wood", "wyrda:energized_gemstone"},
            {"group:wood", "group:wood", "group:wood"},
        }
    })
end