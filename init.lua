--[[
	Mod PQD_World para Minetest
	Copyright (C) 2021 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicializador de scripts
  ]]

-- Tabela global
pqd_world = {}

-- Versão do projeto
pqd_world.versao = "1.0"

-- Versoes compativeis
pqd_world.versao_comp = {
}

-- Configurações / Settings
pqd_world.var = {}

-- Raio minimo de distancia do alvo para teleportar
pqd_world.var.PQD_WORLD_TP_MIN_RADIUS = tonumber(minetest.setting_get("pqd_world_tp_min_radius") or 1000)

-- Raio máximo de distancia do alvo para teleportar
pqd_world.var.PQD_WORLD_TP_MAX_RADIUS = tonumber(minetest.setting_get("pqd_world_tp_max_radius") or 2000)

-- Tempo (em segundos) para verificar waypoints do servidor (padrão é 60)
pqd_world.var.WP_CHECK_TIMER = 60

-- Tempo (em segundos) para waypoints de cada jogador (padrão é 600)
pqd_world.var.WP_MAX_TIME = 600

-- Notificador de Inicializador
local notificar = function(msg)
	if minetest.setting_get("log_mods") then
		minetest.debug("[PQD_World]"..msg)
	end
end

-- Modpath
local modpath = minetest.get_modpath("pqd_world")

-- Carregar scripts
notificar("Carregando...")
-- Metodos gerais
--dofile(modpath.."/tradutor.lua")
-- Nodes
dofile(modpath.."/way_points.lua")
-- API
dofile(modpath.."/api.lua")
-- Nodes
dofile(modpath.."/pqd_box.lua")
notificar("[OK]!")
