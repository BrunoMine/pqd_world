--[[
	Mod PQD_world para Minetest
	Copyright (C) 2021 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	PQD Box
  ]]

--local S = pqd_world.S

-- Acesar interface do jogador
local access_box = function(player)
	if not player then
		minetest.log("error", "[PQD_World] player == nil (access_box)")
		return false
	end
	
	-- Cria formspec
	local formspec = "size[8,4]"
		.."label[0,0;Escolha o tipo de destino]"
		
		-- Ir para coordenada
		.."field[0.485,1.795;2,1;coord_x;Coord. X;]"
		.."field[2.485,1.795;2,1;coord_z;Coord. Z;]"
		.."button_exit[4.285,1.5;3.485,1;to_coord;Ir para Coordenada]"
		
		-- Ir para jogador
		.."field[0.485,3.295;4,1;player_target;Jogador alvo;]"
		.."button_exit[4.285,3;3.485,1;to_player;Ir para Jogador]"
	
	-- Exibir formspec
	minetest.show_formspec(player:get_player_name(), "pqd_world:pqd_box", formspec)
end

-- Receber botoes
minetest.register_on_player_receive_fields(function(player, formname, fields)
	
	if formname == "pqd_world:pqd_box" then
		local player_name = player:get_player_name()
		
		-- Teleportar para uma coordenada X e Z
		if fields.to_coord then
			
			-- Verificar coordenadas
			if fields.coord_x == "" or fields.coord_z == ""
				or not tonumber(fields.coord_x) or not tonumber(fields.coord_z) 
			then
				
				minetest.chat_send_player(player_name, "Coordenadas invalidas.")
				return
				
			elseif tonumber(fields.coord_x) > 30000 or tonumber(fields.coord_x) < -30000
				or tonumber(fields.coord_z) > 30000 or tonumber(fields.coord_z) < -30000
			then
				minetest.chat_send_player(player_name, "As coordenadas X e Z devem estar entre -30.000 e 30.000")
				return
			else
				
				pqd_world.tp(player, {x=tonumber(fields.coord_x), y=20, z=tonumber(fields.coord_z)})
				return
			end
			
		
		-- Botão: teleportar para jogador
		elseif fields.to_player then
			
			-- Verificar se é si mesmo
			if fields.player_target == player_name then
				
				minetest.chat_send_player(player_name, "Não pode se teleportar para si mesmo.")
				return
			
			-- Verificar se jogador alvo está ativo	
			elseif fields.player_target == "" or not minetest.get_player_by_name(fields.player_target) then
				
				minetest.chat_send_player(player_name, "Jogador invalido.")
				return
				
			else
				
				local target_pos = minetest.get_player_by_name(fields.player_target):get_pos()
				pqd_world.tp(player, {x=target_pos.x, y=target_pos.y+2, z=target_pos.z})
				return
				
			end
			
		end
		
	end
	
end)


-- PQD Box
minetest.register_node("pqd_world:pqd_box", {
	description = "Caixa de PQD",
	tiles = {
		"default_chest_top.png^pqd_world_pqd_box.png", -- Cima
		"default_chest_top.png", -- Baixo
		"default_chest_side.png", -- Direita
		"default_chest_side.png", -- Esquerda
		"default_chest_side.png", -- Fundo
		"default_chest_front.png" -- Frente
	},
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_wood_defaults(),
	
	on_rightclick = function(pos, node, player)
		access_box(player)
	end,
	
	drop = "",
})
