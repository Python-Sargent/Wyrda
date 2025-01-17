wyrda.register_book = function(params)
    core.register_craftitem("wyrda:" .. params.spellname .. "_spell_book", {
        description = "Spell Book (" .. params.bookname .. ")\n" ..
                      core.colorize("#FDA", wyrda.spells[params.spellname].desc),
        inventory_image = "wyrda_spell_book.png^(wyrda_spell_book_overlay.png^[colorize:" .. params.color .. ":255)",
        --inventory_image = "wyrda_spell_book.png^wyrda_spell_book_overlay.png",
        stack_max = 1,
        groups = {},
    })
end

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

wyrda.register_book({
    bookname = "Empty",
    spellname = "empty",
    color = "#FFF",
})