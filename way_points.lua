--[[
	Mod PQD_world para Minetest
	Copyright (C) 2021 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Way points
  ]]

--local S = pqd_world.S

-- Variavel global de waypoints
local waypoints = {}

-- Definir Waypoint
pqd_world.set_waypoint = function(player_name, pos)
	local player = minetest.get_player_by_name(player_name)
	
	-- Remove old waypoint if is online
	if waypoints[player_name] and waypoints[player_name].id and player then 
		player:hud_remove(waypoints[player_name].id)
		waypoints[player_name].id = nil
	end
	
	-- Set waypoint control
	waypoints[player_name] = {
		
		-- Tempo restante
		time_remaining = pqd_world.var.WP_MAX_TIME,
		
		-- Coordenada alvo
		pos = {x=pos.x, y=pos.y, z=pos.z},
		
		-- ID no HUD
		id = nil,
	}
	
	-- Add on hud if is online
	if player then
		waypoints[player_name].id = player:hud_add({
			hud_elem_type = "waypoint",
			name = "Coordenada alvo do PQD",
			number = "16747520",
			world_pos = pos
		})
	end
	
end

-- Remover waypoint do jogador
local remove_waypoint = function(player_name)
	local player = minetest.get_player_by_name(player_name)
	
	-- Remove waypoint if is online
	if waypoints[player_name] and waypoints[player_name].id and player then 
		player:hud_remove(waypoints[player_name].id) 
	end
	
	-- Remove da tabela de waypoints ativos
	waypoints[player_name] = nil
end


-- Verificar Waypoints ativos
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	
	-- Executa a verificação a cada 60 segundos
	if timer >= pqd_world.var.WP_CHECK_TIMER then
		timer = 0
		
		-- Verifica todos os jogadores listados
		for player_name, data in pairs(waypoints) do
			
			-- Verifica se ainda deve manter o waypoint e atualiza o tempo restante
			if data.time_remaining > pqd_world.var.WP_CHECK_TIMER then
				waypoints[player_name].time_remaining = waypoints[player_name].time_remaining - pqd_world.var.WP_CHECK_TIMER
				
			-- Encerrado o tempo, remover o waypoint
			else
				-- Remove o waypoint
				remove_waypoint(player_name)
			end
		end
		
	end
end)


-- Restaura o waypoint dos jogadores que reconectam
minetest.register_on_joinplayer(function(player)
	if not player then return end -- Evitar erro de conexão
	
	local player_name = player:get_player_name()
	
	if waypoints[player_name] then
		waypoints[player_name].id = player:hud_add({
			hud_elem_type = "waypoint",
			name = "Coordenada alvo do PQD",
			number = "16747520",
			world_pos = waypoints[player_name].pos
		})
	end
end)



