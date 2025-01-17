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
    bookname = "Empty",
    spellname = "empty",
    color = "#FFF",
})