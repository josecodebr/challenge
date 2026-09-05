-- flags/recipe.lua
-- 1. Receitas Principais (Item Base Branco)
minetest.register_craft({
    output = "challenge:tool_flag_point_3d_white",
    recipe = {
        {"group:leaves", "group:leaves",          "group:leaves"},
        {"group:leaves", "default:mese_crystal", "group:leaves"},
        {"group:leaves", "group:leaves",          "group:leaves"},
    }
})

minetest.register_craft({
    output = "challenge:tool_challenge_circle_open_white",
    recipe = {
        {"group:leaves", "group:leaves",      "group:leaves"},
        {"group:leaves", "default:diamond",  "group:leaves"},
        {"group:leaves", "group:leaves",      "group:leaves"},
    }
})

-- 2. Tabela de Ingredientes de Tingimento por Cor
local color_ingredients = {
    black  = "default:coal_lump",
    red    = "flowers:rose",
    blue   = "flowers:geranium",
    green  = "default:cactus",
    yellow = "flowers:dandelion_yellow",
}

-- 3. Loop Automático para Gerar Receitas de Tingimento
local base_items = {
    "flag_point_3d",
    "challenge_circle_open"
}

for _, item_base in ipairs(base_items) do
    local white_item = "challenge:tool_" .. item_base .. "_white"

    for color, ingredient in pairs(color_ingredients) do
        local colored_item = "challenge:tool_" .. item_base .. "_" .. color

        minetest.register_craft({
            type = "shapeless",
            output = colored_item,
            recipe = {white_item, ingredient},
        })
    end
end
