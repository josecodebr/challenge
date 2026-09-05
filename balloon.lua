-- balloon.lua
minetest.register_craftitem("challenge:balloon_item", {
    description = "Balloon Item",
    inventory_image = "ballon.png",
    stack_max = 99,
})

minetest.register_node("challenge:balloon_on_the_floor", {
    description = "Balloon Spawner",
    tiles = {"ballon.png"},
    light_source = 5,
    walkable = true,
    paramtype = "light",
    is_ground_content = true,
    groups = {cracky = 2, oddly_breakable_by_hand = 2, soil = 1},

    after_place_node = function(pos, placer)
        local timer = minetest.get_node_timer(pos)
        timer:start(10)
    end,

    on_timer = function(pos, node)
        local spawn_pos = vector.add(pos, vector.new(0, 1, 0))
        minetest.add_entity(spawn_pos, "challenge:balloon")
        return true -- Retornar true mantém o timer rodando a cada 10 segundos
    end,
})

minetest.register_entity("challenge:balloon", {
    hp_max = 1,
    physical = true,
    weight = 5,
    collide_with_objects = false,
    selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    visual = "mesh",
    mesh = "ballon.obj",
    visual_size = {x = 2, y = 2},
    textures = {"ballon2.png"},
    is_visible = true,
    backface_culling = false,
    automatic_rotate = 3,
    
    -- Propriedades customizadas
    v_speed = 1.5,
    max_height_offset = 25, -- Subirá 25 blocos acima do ponto de origem

    on_activate = function(self, staticdata, dtime_s)
        local pos = self.object:get_pos()
        if not pos then return end
        
        self.target_y = pos.y + self.max_height_offset
        self.object:set_velocity(vector.new(0, self.v_speed, 0))
    end,

    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        if not pos then return end

        -- Remove o balão se atingir a altura limite
        if pos.y >= self.target_y then
            self.object:remove()
            return
        end

        -- Checa colisão/proximidade com jogadores
        local objects = minetest.get_objects_inside_radius(pos, 1.5)
        for _, obj in ipairs(objects) do
            if obj:is_player() then
                minetest.sound_play("catch2", {
                    pos = pos, 
                    gain = 1.0, 
                    max_hear_distance = 5
                })
                self.object:remove()
                return
            end
        end
    end,
})
