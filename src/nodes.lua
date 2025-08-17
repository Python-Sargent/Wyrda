local stone_sounds = nil

if core.get_modpath("default") ~= nil then
    stone_sounds = default.node_sound_stone_defaults()
end

minetest.register_node("wyrda:ghenstone", {
	description = "Ghenstone",
	tiles = {"wyrda_nodes_ghenstone.png"},
	groups = {cracky = 2, stone = 1},
	drop = "wyrda:shattered_ghenstone",
	sounds = stone_sounds,
    on_blast = function() end,
})

minetest.register_node("wyrda:shattered_ghenstone", {
	description = "Shattered Ghenstone",
	tiles = {"wyrda_nodes_shattered_ghenstone.png"},
	groups = {cracky = 3, stone = 1},
	sounds = stone_sounds,
})

minetest.register_node("wyrda:molding_ghenstone", {
	description = "Molding Ghenstone",
	tiles = {"wyrda_nodes_molding_ghenstone.png"},
	groups = {cracky = 2, stone = 1},
	drop = "wyrda:shattered_ghenstone",
	sounds = stone_sounds,
    on_blast = function() end,
})

minetest.register_node("wyrda:overgrown_ghenstone", {
	description = "Overgrown Ghenstone",
	tiles = {"wyrda_nodes_overgrown_ghenstone.png"},
	groups = {cracky = 2, stone = 1},
	drop = "wyrda:shattered_ghenstone",
	sounds = stone_sounds,
    on_blast = function() end,
})

minetest.register_node("wyrda:clean_ghenstone", {
	description = "Clean Ghenstone",
	tiles = {"wyrda_nodes_clean_ghenstone.png"},
	groups = {cracky = 3, stone = 1},
	sounds = stone_sounds,
    on_blast = function() end,
})

minetest.register_node("wyrda:smoothed_ghenstone", {
	description = "Smoothed Ghenstone",
	tiles = {"wyrda_nodes_smoothed_ghenstone.png"},
	groups = {cracky = 3, stone = 1},
	sounds = stone_sounds,
    on_blast = function() end,
})

minetest.register_node("wyrda:carved_ghenstone", {
	description = "Carved Ghenstone",
	tiles = {"wyrda_nodes_carved_ghenstone.png"},
	groups = {cracky = 3, stone = 1},
	sounds = stone_sounds,
    on_blast = function() end,
})

minetest.register_node("wyrda:tiled_ghenstone", {
	description = "Tiled Ghenstone",
	tiles = {"wyrda_nodes_tiled_ghenstone.png"},
	groups = {cracky = 3, stone = 1},
	sounds = stone_sounds,
    on_blast = function() end,
})

minetest.register_node("wyrda:darkened_ghenstone", {
	description = "Darkened Ghenstone",
	tiles = {"wyrda_nodes_darkened_ghenstone.png"},
	groups = {cracky = 3, stone = 1},
	sounds = stone_sounds,
    on_blast = function() end,
})

minetest.register_node("wyrda:ghenstone_bricks", {
	description = "Ghenstone Bricks",
	tiles = {"wyrda_nodes_ghenstone_bricks.png"},
	groups = {cracky = 3, stone = 1},
	sounds = stone_sounds,
    on_blast = function() end,
})

minetest.register_node("wyrda:clean_ghenstone_bricks", {
	description = "Clean Ghenstone Bricks",
	tiles = {"wyrda_nodes_clean_ghenstone_bricks.png"},
	groups = {cracky = 3, stone = 1},
	sounds = stone_sounds,
    on_blast = function() end,
})

minetest.register_node("wyrda:mold", {
	description = "Mold",
	tiles = {"wyrda_nodes_mold.png"},
	groups = {snappy = 2, stone = 1},
	sounds = stone_sounds,
})

minetest.register_node("wyrda:overgrowth", {
	description = "Overgrowth",
	tiles = {"wyrda_nodes_overgrowth.png"},
	groups = {snappy = 2, stone = 1},
	sounds = stone_sounds,
})

local function stair_slab(stairs, mat, name)
    stairs.register_stair_and_slab(
        mat,
        "wyrda:" .. mat,
        {cracky = 2},
        {"wyrda_nodes_" .. mat .. ".png"},
        name .. " Stair",
        name .. " Slab",
        stone_sounds,
        true)
end

local function ghenstone_variant_stairslab(stairs, variant, name)
    stair_slab(stairs, variant .. "ghenstone", name .. "Ghenstone")
end

local function ghenstone_bricks_variant_stairslab(stairs, variant, name)
    stair_slab(stairs, variant .. "ghenstone_bricks", name .. "Ghenstone Bricks")
end

if core.get_modpath("stairs") ~= nil then
    ghenstone_variant_stairslab(stairs, "", "")
    ghenstone_variant_stairslab(stairs, "overgrown_", "Overgrown ")
    ghenstone_variant_stairslab(stairs, "molding_", "Molding ")
    ghenstone_variant_stairslab(stairs, "smoothed_", "Smoothed ")
    ghenstone_variant_stairslab(stairs, "tiled_", "Tiled ")
    ghenstone_variant_stairslab(stairs, "clean_", "Clean ")
    ghenstone_variant_stairslab(stairs, "carved_", "Carved ")
    ghenstone_variant_stairslab(stairs, "darkened_", "Darkened ")
    ghenstone_variant_stairslab(stairs, "shattered_", "Shattered ")

    ghenstone_bricks_variant_stairslab(stairs, "", "")
    ghenstone_bricks_variant_stairslab(stairs, "clean_", "Clean ")
else
    local modpath = core.get_modpath("wyrda")
    dofile(modpath .. "/stairs.lua") -- use custom stairs library (stripped down version of stairs)
    ghenstone_variant_stairslab(wyrda, "", "")
    ghenstone_variant_stairslab(wyrda, "overgrown_", "Overgrown ")
    ghenstone_variant_stairslab(wyrda, "molding_", "Molding ")
    ghenstone_variant_stairslab(wyrda, "smoothed_", "Smoothed ")
    ghenstone_variant_stairslab(wyrda, "tiled_", "Tiled ")
    ghenstone_variant_stairslab(wyrda, "clean_", "Clean ")
    ghenstone_variant_stairslab(wyrda, "carved_", "Carved ")
    ghenstone_variant_stairslab(wyrda, "darkened_", "Darkened ")
    ghenstone_variant_stairslab(wyrda, "shattered_", "Shattered ")

    ghenstone_bricks_variant_stairslab(wyrda, "", "")
    ghenstone_bricks_variant_stairslab(wyrda, "clean_", "Clean ")
end