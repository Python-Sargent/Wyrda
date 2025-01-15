local create_formspec = function()
    local formspec = "formspec_version[6]" ..
                     "size[10.5,10]" ..
                     "list[current_player;main;0.4,4.9;8,4;0]" ..
                     "image[2.9,0.3;4.7,4.3;wyrda_inscription_table_bg.png]" ..
                     "list[nodemeta;result;6.1,1.9;1,1;0]" ..
                     "list[nodemeta;inscript;3.5,2.9;1,1;0]" ..
                     "list[nodemeta;script;3.5,0.8;1,1;0]"
    return formspec
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
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Inscription Table")
        local inv = meta:get_inventory()
        inv:set_size("script", 1*1)
        inv:set_size("inscript", 1*1)
        inv:set_size("result", 1*1)
    end,
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		core.show_formspec(clicker:get_player_name(), "inscription_table", create_formspec())
	end,
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)

    end,
    -- Called when a player wants to move items inside the inventory.
    -- Return value: number of items allowed to move.

    allow_metadata_inventory_put = function(pos, listname, index, stack, player)

    end,
    -- Called when a player wants to put something into the inventory.
    -- Return value: number of items allowed to put.
    -- Return value -1: Allow and don't modify item count in inventory.

    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        
    end,
    -- Called when a player wants to take something out of the inventory.
    -- Return value: number of items allowed to take.
    -- Return value -1: Allow and don't modify item count in inventory.

    on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        
    end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
        
    end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
        
    end,
    can_dig = function(pos, player)
        local meta = core.get_meta(pos);
        local inv = meta:get_inventory()
        return inv:is_empty("script") and inv:is_empty("inscript") and inv:is_empty("result")
    end,
    on_blast = function(pos)
        if core.get_modpath("default") ~= nil then
            local drops = {}
            default.get_inventory_drops(pos, "main", drops)
            drops[#drops+1] = name
            minetest.remove_node(pos)
            return drops
        end
    end,
})