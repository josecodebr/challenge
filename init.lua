-- init.lua
challenge = {}

local modpath = minetest.get_modpath(minetest.get_current_modname())
challenge.modpath = modpath
-- Carregamento dos módulos / arquivos
dofile(modpath .. "/flags/chekpoints.lua") 
dofile(modpath .. "/flags/flag_point.lua")
dofile(modpath .. "/flags/recipe.lua")

dofile(modpath .. "/nodes_ground.lua") 
dofile(modpath .. "/balloon.lua")


dofile(modpath .. "/tools/move_tool.lua")
