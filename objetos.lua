-- objetos.lua
local colors = {
    {"black",  "#00000070"},
    {"white",  "#FFFFFF70"},
    {"red",    "#AA000070"},
    {"blue",   "#0000AA70"},
    {"green",  "#00ff0070"},
    {"yellow", "#ffff0070"},
}

local itens = {
    {"challenge_circle_tool", "challenge_circle_closed", "challenge_circle_open"},
}

for _, item_data in ipairs(itens) do
    local tool_base   = item_data[1]
    local closed_base = item_data[2]
    local open_base   = item_data[3]

    for _, color_data in ipairs(colors) do
        local color_name = color_data[1]
        local color_hex  = color_data[2]

        local tool_name   = "challenge:" .. tool_base .. "_" .. color_name
        local closed_name = "challenge:" .. closed_base .. "_" .. color_name
        local open_name   = "challenge:" .. open_base .. "_" .. color_name

        -- Registrar Ferramenta/Item
        minetest.register_craftitem(tool_name, {
            description = tool_base .. "_" .. color_name,
            inventory_image = tool_base .. ".png^[multiply:" .. color_hex,
            stack_max = 1,

            on_use = function(itemstack, user, pointed_thing)
                local pos = user:get_pos()
                if not pos then return itemstack end

                local node = minetest.get_node(pos)
                if node.name == "air" then
                    minetest.add_entity(pos, open_name)
                    itemstack:take_item(1)
                end
                return itemstack
            end,
        })

        -- Entidade: Círculo Fechado
        minetest.register_entity(closed_name, {
            hp_max = 50,
            physical = true,
            weight = 5,
            collide_with_objects = false,
            selectionbox = {-1, -1, -1, 1, 1, 1},
            visual = "upright_sprite",
            textures = {closed_base .. ".png^[multiply:" .. color_hex},
            visual_size = {x = 2, y = 2},
            is_visible = true,
            automatic_rotate = 1,
            backface_culling = false,

            on_step = function(self, dtime)
                local pos = self.object:get_pos()
                if not pos then return end

                local objects = minetest.get_objects_inside_radius(pos, 2)
                for _, obj in ipairs(objects) do
                    if obj:is_player() then
                        local player_name = obj:get_player_name()

                        minetest.sound_play("catch2", {
                            pos = pos,
                            gain = 1.0,
                            max_hear_distance = 5
                        })

                        local open_entity = minetest.add_entity(pos, open_name)
                        if open_entity then
                            open_entity:set_properties({
                                infotext = player_name,
                            })
                        end

                        self.object:remove()
                        return
                    end
                end
            end,
        })

        -- Entidade: Círculo Aberto
        minetest.register_entity(open_name, {
            hp_max = 50,
            physical = true,
            weight = 5,
            collide_with_objects = false,
            selectionbox = {-1, -1, -1, 1, 1, 1},
            visual = "upright_sprite",
            textures = {open_base .. ".png^[multiply:" .. color_hex},
            visual_size = {x = 2, y = 2},
            is_visible = true,
            automatic_rotate = 1,
            backface_culling = false,

            on_activate = function(self, staticdata, dtime_s)
                minetest.after(5, function()
                    -- Garante que a entidade ainda existe antes de tentar transformar
                    if not self.object or not self.object:get_pos() then return end
                    
                    local pos = self.object:get_pos()
                    minetest.sound_play("catch2", {
                        pos = pos,
                        gain = 1.0,
                        max_hear_distance = 3
                    })

                    minetest.add_entity(pos, closed_name)
                    self.object:remove()
                end)
            end,
        })
    end
end

-- Ferramenta para remover entidades próximas
minetest.register_craftitem("challenge:challenge_remove_tool", {
    description = "Challenge Remove Tool",
    inventory_image = "challenge_remove_tool.png^[multiply:" .. colors[3][2],
    stack_max = 1,

    on_use = function(itemstack, user, pointed_thing)
        local pos = user:get_pos()
        if not pos then return end

        local objects = minetest.get_objects_inside_radius(pos, 5)
        for _, obj in ipairs(objects) do
            if not obj:is_player() then
                obj:remove()
            end
        end
        return itemstack
    end,
})
