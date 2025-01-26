if core.get_modpath("default") ~= nil then
    minetest.register_craft({
        output = "wyrda:empty_spell_book",
        recipe = {
            {"default:gold_ingot", "default:steel_ingot", "default:gold_ingot"},
            {"default:paper", "default:book", "default:paper"},
            {"default:gold_ingot", "default:steel_ingot", "default:gold_ingot"},
        }
    })


end
