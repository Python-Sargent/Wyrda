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
end
