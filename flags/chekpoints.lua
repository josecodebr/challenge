-- flags/chekpoints.lua
local colors = {
    {"white",  "#FFFFFF70"},
    {"black",  "#00000070"},
    {"red",    "#AA000070"},
    {"blue",   "#0000AA70"},
    {"green",  "#00ff0070"},
    {"yellow", "#ffff0070"},
}

local itens = {
    {"challenge_circle_open", "challenge_circle.png", "challenge_circle_open.obj"},
}

-- Registro de escuta do Formspec globalmente (Apenas uma vez no topo do arquivo)
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "challenge:checkpoint_form" then return false end

    local player_name = player:get_player_name()
    
    -- Verifica se a posição foi enviada pelo Formspec
    if not fields.pos_x or not fields.pos_y or not fields.pos_z then return true end
    local pos = {
        x = tonumber(fields.pos_x), 
        y = tonumber(fields.pos_y), 
        z = tonumber(fields.pos_z)
    }

    local meta = minetest.get_meta(pos)
    local owner = meta:get_string("owner")

    if owner ~= player_name then
        minetest.chat_send_player(player_name, "This block is not yours!")
        return true
    end

    if fields.save or fields.key_enter then
        local new_name = fields.name
        if not new_name or new_name == "" then
            new_name = "Checkpoint by " .. player_name
        end

        meta:set_string("infotext", new_name)
        minetest.chat_send_player(player_name, "Checkpoint name changed to: " .. new_name)
    end

    return true
end)

for _, item_data in ipairs(itens) do
    local item_id   = item_data[1]
    local texture   = item_data[2]
    local mesh_file = item_data[3]

    for _, color_data in ipairs(colors) do
        local color_name = color_data[1]
        local color_hex  = color_data[2]

        local tool_name = "challenge:tool_" .. item_id .. "_" .. color_name
        local node_name = "challenge:" .. item_id .. "_" .. color_name

        -- Ferramenta de criação
        minetest.register_craftitem(tool_name, {
            description = "Tool " .. item_id .. " (" .. color_name .. ")",
            inventory_image = "challenge_circle_open.png^[multiply:" .. color_hex,
            stack_max = 1,

            on_use = function(itemstack, user, pointed_thing)
                local pos = user:get_pos()
                if not pos then return itemstack end

                local player_name = user:get_player_name()
                local check_pos = vector.round(pos)

                if minetest.get_node(check_pos).name == "air" then
                    -- 1. Pega a direção que o jogador está olhando e converte para facedir
                    local dir = user:get_look_dir()
                    local facedir = minetest.dir_to_facedir(dir)

                    -- 2. Define o nó já passando a rotação param2
                    minetest.set_node(check_pos, {
                        name = node_name,
                        param2 = facedir
                    })
                    
                    local meta = minetest.get_meta(check_pos)
                    meta:set_string("infotext", "Checkpoint by " .. player_name)
                    meta:set_string("owner", player_name)

                    local timer = minetest.get_node_timer(check_pos)
                    timer:start(0.5)

                    itemstack:take_item(1)
                end
                return itemstack
            end,
        })

        -- Nó do Checkpoint
        minetest.register_node(node_name, {
            description = item_id .. "_" .. color_name,
            light_source = 5,
            walkable = false,
            use_texture_alpha = "clip",
            sunlight_propagates = true,
            paramtype = "light",
            paramtype2 = "facedir",
            drawtype = "mesh",
            mesh = mesh_file,
            tiles = {texture .. "^[multiply:" .. color_hex},
            inventory_image = item_id .. ".png^[multiply:" .. color_hex,
            wield_image = item_id .. ".png^[multiply:" .. color_hex,
            drop = tool_name,
            groups = {cracky = 3, oddly_breakable_by_hand = 3, torch = 1, not_in_creative_inventory = 1},
            selection_box = {type = "fixed", fixed = {-0.5, 0, -0.5, 0.5, 1, 0.5}},
            collision_box = {type = "fixed", fixed = {-0.5, 0, -0.5, 0.5, 1, 0.5}},

            after_place_node = function(pos, placer)
                if placer and placer:is_player() then
                    local player_name = placer:get_player_name()

                    local dir = placer:get_look_dir()
                    local facedir = minetest.dir_to_facedir(dir)

                    minetest.swap_node(pos, {
                        name = minetest.get_node(pos).name,
                        param2 = facedir
                    })

                    local meta = minetest.get_meta(pos)
                    meta:set_string("owner", player_name)
                    meta:set_string("infotext", "Checkpoint por " .. player_name)
                end

                local timer = minetest.get_node_timer(pos)
                timer:start(0.5)
            end,

            on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
                local meta = minetest.get_meta(pos)
                local player_name = clicker:get_player_name()
                local owner = meta:get_string("owner")

                if owner ~= player_name then
                    minetest.chat_send_player(player_name, "This block is not yours!")
                    return itemstack
                end

                local current_title = meta:get_string("infotext")
                
                -- Formspec otimizado usando coordenadas ocultas da posição do bloco
                local formspec = "formspec_version[5]size[6,6]" ..
                    "field[0,0;0,0;pos_x;; " .. pos.x .. "]" ..
                    "field[0,0;0,0;pos_y;; " .. pos.y .. "]" ..
                    "field[0,0;0,0;pos_z;; " .. pos.z .. "]" ..
                    "field[1,2;4,0.8;name;Checkpoint Name:;" .. minetest.formspec_escape(current_title) .. "]" ..
                    "button_exit[2,4;2,0.8;save;Save]"

                minetest.show_formspec(player_name, "challenge:checkpoint_form", formspec)
                return itemstack
            end,

            on_timer = function(pos, node)
                local objects = minetest.get_objects_inside_radius(pos, 1)

                for _, obj in ipairs(objects) do
                    if obj:is_player() then
                        minetest.sound_play("catch2", {
                            pos = pos,
                            gain = 1.0,
                            max_hear_distance = 5
                        })
                        break
                    end
                end

                return true
            end,
        })
    end
end
