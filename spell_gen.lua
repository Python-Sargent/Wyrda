local colors = {
    ["repetim"] = "#888",
    ["risier"] = "#48F",
    ["fiera"] = "#F84",
    ["disperim"] = "#84F",
    ["sanium"] = "#F48",
    ["expol"] = "#F44",
    ["1"] = "#4F4", -- for spells later on
    ["2"] = "#44F",
    ["empty"] = "#FFF",
}

for i, spell in pairs(wyrda.spells) do
    wyrda.register_wand({
        itemname = "wyrda:basic_" .. spell.name .. "_wand",
        name = "Basic Wand (" .. spell.descname .. ")\n" .. core.colorize("#AFA", wyrda.spells[spell.name].desc),
        invimage = "wyrda_basic_wand.png",
        spellname = spell.name,
        groups = {wand = 1, not_in_creative_inventory = 1},
        cooldown = spell.cooldown,
    })

    wyrda.register_book({
        bookname = spell.descname,
        spellname = spell.name,
        color = colors[spell.name],
    })
end

--[[
-- WANDS    

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

-- BOOKS

wyrda.register_book({
    bookname = "Repetim",
    spellname = "repetim",
    color = "#888",
})

wyrda.register_book({
    bookname = "Risier",
    spellname = "risier",
    color = "#48F",
})

wyrda.register_book({
    bookname = "Fiera",
    spellname = "fiera",
    color = "#F84",
})

wyrda.register_book({
    bookname = "Dispersion",
    spellname = "disperim",
    color = "#84F",
})

wyrda.register_book({
    bookname = "Sanium",
    spellname = "sanium",
    color = "#F48",
})

wyrda.register_book({
    bookname = "Expol",
    spellname = "expol",
    color = "#F44",
})
})]]