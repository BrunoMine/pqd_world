--[[
	Mod PQD_World para Minetest
	Copyright (C) 2021 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicializador de scripts
  ]]


-- Tabela de jogadores em processo de teleporte
local tp_players = {}

-- Variavel indica processamento
local process = false

-- Tenta teleportar jogadres em processamento
pqd_world.try_tp = function()
	
	-- Variavel que verifica se ainda existem jogadores para teleportar
	local has_players = false
	
	-- Percorre todos os jogadores na tabela
	for player_name, data in pairs(tp_players) do
		has_players = true
		
		-- Verificações básicas
		if not minetest.get_player_by_name(player_name) -- Verifica se o jogador está online
			or not minetest.find_node_near(data.player_obj:get_pos(), 10, {"pqd_world:pqd_box"}) -- Verifica se está perto da caixa de PQD
		then
			if player_name and minetest.get_player_by_name(player_name) then
				minetest.chat_send_player(player_name, "Cancelando viagem de PQD.")
			end
			
			tp_players[player_name] = nil
		
		
		-- Caso tudo ok, continua normalmente
		else
			
			-- Verifica se já está tentando teleportar para um ponto
			if data.pos_arrange then
			
				-- Verifica se o espaço é aceitavel
				
				-- Procura terra superficial
				local nodes = minetest.find_nodes_in_area(
					{x=data.pos_arrange.x-50,y=1, z=data.pos_arrange.z-50}, 
					{x=data.pos_arrange.x+50,y=100, z=data.pos_arrange.z+50}, 
					{"group:spreading_dirt_type"})
				
				-- Verifica se encontrou uma terra superficial
				if table.maxn(nodes) > 0 then 
					
					-- Pegar uma coordenada
					local p = nodes[1]
					
					-- Verifica area protegida
					if minetest.is_protected({x=p.x, y=p.y+1, z=p.z}, player_name) == false then
						
						-- Teleporta jogador
						data.player_obj:set_pos({x=p.x, y=p.y+3, z=p.z})
						
						-- Para encerrar o processamento
						data.success = true
					end
					
				end
				
				-- Encerra essa coordenada
				data.pos_arrange = nil
			end
			
			-- Carrega um ponto no mapa para tentar teleportar no proximo loop
			if data.pos_arrange == nil and data.success == false then
				
				-- Calcula uma coordenada aleatória dentro dos limites
				
				-- Coordenada X (primeiro cateto)
				local x = math.random(0, pqd_world.var.PQD_WORLD_TP_MAX_RADIUS)
				
				-- Coordenada Z (segundo cateto)
				
				-- Valor máximo para Z
				local z_max = math.sqrt( math.pow(pqd_world.var.PQD_WORLD_TP_MAX_RADIUS, 2) - math.pow(x, 2) )
				
				-- Valor mínimo para Z
				local z_min = 0
				if x < pqd_world.var.PQD_WORLD_TP_MIN_RADIUS then
					z_min = math.sqrt( math.pow(pqd_world.var.PQD_WORLD_TP_MIN_RADIUS, 2) - math.pow(x, 2) )
				end
				
				local z = math.random(z_min, z_max)
				
				-- Inclui a possibilidade das coordenadas negativas
				if math.random(0, 1) == 1 then x = x * -1 end
				if math.random(2, 3) == 3 then z = z * -1 end
				
				-- Salva nova coordenada para gerar
				data.pos_arrange = {x=data.pos_target.x+x, y=50, z=data.pos_target.z+z}
				
				-- Inicia geração de mapa
				minetest.emerge_area(
					{x=data.pos_arrange.x-50,y=1, z=data.pos_arrange.z-50}, 
					{x=data.pos_arrange.x+50,y=100, z=data.pos_arrange.z+50})
			end
			
			-- Processamento concluido
			if data.success == true then
				
				-- Marco o waypoint
				pqd_world.set_waypoint(player_name, data.pos_target)
				
				-- Mensagem no chat
				minetest.chat_send_player(player_name, "Caindo de paraquedas. Coordenada alvo marcada.")
				
				-- Exclui dados
				tp_players[player_name] = nil
			end
		end
	end
	
	-- Verifica se pode encerrar processamento
	if has_players == false then 
		process = false
	else
		minetest.after(3, pqd_world.try_tp)
	end
end

-- Teleportar para uma coordenada
pqd_world.tp = function(player, pos)
	local player_name = player:get_player_name()
	-- Remove processo antigo se houver
	tp_players[player_name] = nil
	
	-- Insere na tabela em processo
	tp_players[player_name] = {
		
		-- Player
		player_obj = player,
		
		-- Coordenada alvo
		pos_target = {x=pos.x, y=pos.y, z=pos.z},
		
		-- Coordenada preparada
		pos_arrange = nil,
		
		-- Sucesso da operação
		success = false,
	}
	
	minetest.chat_send_player(player_name, "Buscando area para cair. Aguarde ao lado da Caixa de PQD ou afastesse dela para cancelar a viagem...")
	
	-- Inicia processamento se estiver parado
	if process == false then pqd_world.try_tp() end
end
