-- move_tool.lua
-- Função auxiliar para trocar o item na mão do jogador e copiar/limpar os metadados
local function switch_tool(user, itemstack, new_tool_name, meta_data)
    local new_stack = ItemStack(new_tool_name)
    local meta = new_stack:get_meta()

    if meta_data then
        meta:set_string("stored_node", meta_data.node)
        meta:set_int("stored_param2", meta_data.param2)
        meta:set_string("stored_infotext", meta_data.infotext)
        meta:set_string("stored_owner", meta_data.owner)
        meta:set_string("description", "Move Tool (Carregando: " .. meta_data.node .. ")") -- Descrição dinâmica opcional (mostra qual bloco está guardado ao passar o mouse)
    end

    return new_stack
end

-- 1. FERRAMENTA VAZIA
minetest.register_tool("challenge:move_tool", {
    description = "Move Tool (Vazia)",
    inventory_image = "move_tool.png",
    wield_image = "move_tool.png",

    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then return itemstack end

        local player_name = user:get_player_name()
        local pos = pointed_thing.under
        local node = minetest.get_node(pos)

        if not node.name:find("^challenge:") then -- Verifica se o nó pertence ao mod 'challenge:'
            minetest.chat_send_player(player_name, "Esta ferramenta só pode mover blocos do mod Challenge!")
            return itemstack
        end

        local node_meta = minetest.get_meta(pos)
        -- Verifica se o jogador é o dono do bloco
        if node_meta:get_string("owner") ~= player_name then
            minetest.chat_send_player(player_name, "Você só pode mover seus próprios blocos!")
            return itemstack
        end

        -- Coleta as informações do bloco
        local meta_data = {
            node = node.name,
            param2 = node.param2,
            infotext = node_meta:get_string("infotext"),
            owner = node_meta:get_string("owner")
        }
        minetest.remove_node(pos) -- Remove o bloco do mundo
        minetest.chat_send_player(player_name, "Bloco coletado! Use novamente para posicioná-lo.")
        return switch_tool(user, itemstack, "challenge:move_tool_active", meta_data) -- Substitui a ferramenta na mão do jogador pela versão ativa
    end
})

-- 2. FERRAMENTA ATIVA (Com bloco guardado)
minetest.register_tool("challenge:move_tool_active", {
    description = "Move Tool (Ativa)",
    -- Imagem com algum detalhe visual ou brilho indicando que tem algo guardado
    inventory_image = "move_tool_active.png", 
    wield_image = "move_tool_active.png",
    groups = {not_in_creative_inventory = 1}, -- Oculta do inventário criativo

    on_use = function(itemstack, user, pointed_thing)
        local pos = user:get_pos()
        if not pos then return itemstack end

        local check_pos = vector.round(pos)
        local player_name = user:get_player_name()
        if minetest.get_node(check_pos).name == "air" then
            local item_meta = itemstack:get_meta()
            local node_name = item_meta:get_string("stored_node")
            local target_param2 = item_meta:get_int("stored_param2")

            -- Coloca o bloco de volta
            minetest.set_node(check_pos, {
                name = node_name,
                param2 = target_param2
            })
            -- Restaura os metadados do nó
            local meta = minetest.get_meta(check_pos)
            meta:set_string("infotext", item_meta:get_string("stored_infotext"))
            meta:set_string("owner", item_meta:get_string("stored_owner"))
            -- Reinicia o timer do nó se necessário
            local timer = minetest.get_node_timer(check_pos)
            timer:start(0.5)
            minetest.chat_send_player(player_name, "Bloco posicionado com sucesso!")
            -- Retorna para a Move Tool vazia
            return switch_tool(user, itemstack, "challenge:move_tool", nil)
        end

        return itemstack
    end
})
