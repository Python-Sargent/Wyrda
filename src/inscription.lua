local create_formspec = function()
    local formspec = "formspec_version[6]" ..
                     "size[10.5,10]" ..
                     "list[current_player;main;0.4,4.9;8,4;]" ..
                     "image[2.9,0.3;4.7,4.3;wyrda_inscription_table_bg.png]" ..
                     "list[context;result;6.1,1.9;1,1;0]" ..
                     "list[context;inscript;3.5,2.9;1,1;0]" ..
                     "list[context;script;3.5,0.8;1,1;0]"
    return formspec
end

wyrda.inscription_recipes = {}

wyrda.register_inscription_recipe = function(def)
    wyrda.inscription_recipes[def.name] = {
        script = def.script,
        inscript = def.inscript,
        result = def.result,
    }
end

wyrda.inscription_recipe = function(script, inscript)
    local result
    for i, v in pairs(wyrda.inscription_recipes) do
        if v.script == script and v.inscript == inscript then result = v.result end
    end
    return result
end

core.register_node("wyrda:inscription_table", {
    description = "Inscription Table",
    tiles = {
        "wyrda_inscription_table_top.png",
        "wyrda_inscription_table_bottom.png",
        "wyrda_inscription_table_side.png",
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 2},
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string("infotext", "Inscription Table")
        meta:set_string("formspec", create_formspec())
        local inv = meta:get_inventory()
        inv:set_size("script", 1*1)
        inv:set_size("inscript", 1*1)
        inv:set_size("result", 1*1)
    end,
    --[[on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		core.show_formspec(clicker:get_player_name(), "inscription_table", create_formspec())
	end,]]
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        if to_list == "result" then return 0 end
        return count
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if listname == "result" then return 0 end
        return stack:get_count()
    end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
        if listname == "script" or listname == "inscript" then
            local meta = core.get_meta(pos)
            local inv = meta:get_inventory()
            local result = wyrda.inscription_recipe(inv:get_stack("script", 1):get_name(), inv:get_stack("inscript", 1):get_name())
            if result ~= nil then
                inv:set_stack("result", 1, result)
            end
        end
    end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        if listname == "script" or listname == "inscript" then
            --if inv:get_stack("result", 1) ~= nil then
                --inv:take_item(inv:get_stack("result", 1))
            --end
            inv:set_stack("result", 1, "")
        elseif listname == "result" then
            inv:set_stack("script", 1, "")
            inv:set_stack("inscript", 1, "")
        end
    end,
    can_dig = function(pos, player)
        local meta = core.get_meta(pos);
        local inv = meta:get_inventory()
        return inv:is_empty("script") and inv:is_empty("inscript") and inv:is_empty("result")
    end,
})