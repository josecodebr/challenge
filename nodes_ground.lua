-- nodes_ground.lua

local cores = {
    {"white", "#FFFFFF70"},
    {"red",   "#AA000070"},
    {"blue",  "#0000AA70"},
    {"green", "#00ff0070"},
}

for _, color_data in ipairs(cores) do
    local color_name = color_data[1]
    local color_hex  = color_data[2]

    minetest.register_node("challenge:ground_" .. color_name, {
        description = "Ground " .. color_name:sub(1,1):upper() .. color_name:sub(2),
        tiles = {"ground.png^[colorize:" .. color_hex},
        light_source = 5,
        walkable = true,
        paramtype = "light",
        is_ground_content = true,
        groups = {cracky = 2, oddly_breakable_by_hand = 2, soil = 1},

        after_place_node = function(pos, placer)
            local timer = minetest.get_node_timer(pos)
            timer:start(0.5) -- 0.5s já é extremamente responsivo e consome bem menos CPU que 0.2s
        end,

        on_timer = function(pos, node)
            local check_pos = vector.add(pos, vector.new(0, 1, 0))
            local objects = minetest.get_objects_inside_radius(check_pos, 0.8)

            for _, obj in ipairs(objects) do
                if obj:is_player() then
                    local player_name = obj:get_player_name()
                    local meta = minetest.get_meta(pos)

                    -- Atualiza o infotext apenas se for um jogador diferente (evita reescrever a meta sem necessidade)
                    local current_info = meta:get_string("infotext")
                    local new_info = "Checkpoint: " .. player_name

                    if current_info ~= new_info then
                        meta:set_string("infotext", new_info)
                        minetest.sound_play("catch2", {
                            pos = pos,
                            gain = 1.0,
                            max_hear_distance = 5
                        })
                    end

                    break -- Já encontrou um jogador, interrompe o loop
                end
            end

            return true -- Mantém o timer ativo no mesmo intervalo configurado
        end,
    })
end
