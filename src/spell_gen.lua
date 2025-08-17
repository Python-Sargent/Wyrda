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

local emblem_spells = {
    ["repetim"] = 1,
    ["risier"] = 1,
    ["fiera"] = 2,
    ["disperim"] = 2,
    ["sanium"] = 1,
    ["expol"] = 1,
    ["hazum"] = 2,
    ["flurra"] = 2,
    ["fulst"] = 1,
    ["empty"] = 1,
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

    core.register_entity("wyrda:" .. spell.name .. "_emblem_marker", {
        initial_properties = {
            visual = "mesh",
            mesh = "emblem_marker.obj",
            hp_max = 100000000000,
            physical = false,
            collide_with_objects = true,
            collisionbox = { -1, -0.5, -1, 1, 1, 1 },
            selectionbox = { -1, -0.5, -1, 1, 1, 1, rotate = false },
            pointable = false,
            visual_size = {x = 10, y = 10, z = 10},
            textures = {"wyrda_emblem_marker.png^[colorize:" .. colors[spell.name] .. ":alpha"},
            use_texture_alpha = true,
            backface_culling = false,
            is_visible = true,
            makes_footstep_sound = false,
            glow = 5,
            shaded = true,
        },
        nodepos = "",
        cooldown = 0,
        on_deactivate = function(self, removal)
            if removal ~= true then
                -- save data in staticdata
            end
        end,
        on_activate = function(self, staticdata, dtime_s)
            if not staticdata or not core.get_node(core.string_to_pos(staticdata)) then
                self.object:remove()
                return
            end
            
            self.nodepos = staticdata
        end,
        --on_deactivate = function(self, removal) end,
        on_step = function(self, dtime, moveresult)
            self.object:set_velocity(vector.zero())
            self.cooldown = self.cooldown - dtime
            local pos1 = vector.offset(core.string_to_pos(self.nodepos), -1, -0.5, -1)
            local pos2 = vector.offset(core.string_to_pos(self.nodepos), 1, 1.5, 1)
            for obj in core.objects_in_area(pos1, pos2) do
                if obj:is_player() then
                    if self.cooldown <= 0 then
                        self.cooldown = 1
                        local playername = obj:get_player_name() or ""
                        wyrda.cast(wyrda.spells[spell.name], obj, playername, obj:get_pos(), emblem_spells[spell.name])
                    end
                end
            end
        end,
        get_staticdata = function(self) return self.nodepos end,
    })

    local markers = {}

    local destruct = function(pos)
        local meta = core.get_meta(pos)
        local guid = meta:get_string("emk_guid")
        local obj = core.objects_by_guid[guid]
        if obj then
            obj:remove()
        end
    end

    local construct = function(pos)
        local starting_pos = vector.offset(pos, 0, 1, 0)
        local marker = core.add_entity(starting_pos, "wyrda:" .. spell.name .. "_emblem_marker", core.pos_to_string(pos))
        local guid = marker:get_guid()
        local meta = core.get_meta(pos)
        meta:set_string("emk_guid", guid)
    end

    minetest.register_node("wyrda:" .. spell.name .. "_emblem", {
        description = spell.descname .. " Emblem",
        tiles = {"wyrda_nodes_carved_ghenstone.png^(wyrda_nodes_emblem_overlay.png^[colorize:" .. colors[spell.name] .. ":255)"},
        groups = {cracky = 3, emblem=1},
        light_source = 5,
        on_construct = function(pos)
            construct(pos)
        end,
        on_destruct = function(pos)
            destruct(pos)
        end,
        on_blast = function() end,
    })

    minetest.register_craft({
        output = "wyrda:" .. spell.name .. "_emblem",
        recipe = {
            {"wyrda:carved_ghenstone", "wyrda:mese_crystal", "wyrda:carved_ghenstone"},
            {"wyrda:energized_gemstone", "wyrda:" .. spell.name .. "_spell_book", "wyrda:energized_gemstone"},
            {"wyrda:carved_ghenstone", "wyrda:mese_crystal", "wyrda:carved_ghenstone"},
        }
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