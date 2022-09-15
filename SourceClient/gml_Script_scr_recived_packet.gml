buffer = argument0;
socket = argument1;

msgid = buffer_read(buffer, buffer_s16);

if (ds_map_size(global.Clients) == 0 && global.isHost) {
    return false;
}

if (global.isHost) {
    inst = ds_map_find_value(global.Clients, socket);
}

switch(msgid)
{
    case 0: // POS_CMD
        if (global.isHost) { 
            inst.x = buffer_read(buffer, buffer_s32);
            inst.y = buffer_read(buffer, buffer_s32);
	    	inst.hspeed = buffer_read(buffer, buffer_f32);
	    	inst.vspeed = buffer_read(buffer, buffer_f32);
	    	inst.inputxy = buffer_read(buffer, buffer_f32);
	    	inst.input_jump = buffer_read(buffer, buffer_u8);
	    	inst.room_id = buffer_read(buffer, buffer_u16);
            inst.isSpectator = buffer_read(buffer, buffer_bool);

            var serverBuff = buffer_create(256, buffer_grow, 1);

            buffer_seek(serverBuff, buffer_seek_start, 0);
            buffer_write(serverBuff, buffer_s16, 0);
            buffer_write(serverBuff, buffer_s32, inst.x);
            buffer_write(serverBuff, buffer_s32, inst.y);
	   	 	buffer_write(serverBuff, buffer_f32, inst.hspeed);
        	buffer_write(serverBuff, buffer_f32, inst.vspeed);
	    	buffer_write(serverBuff, buffer_f32, inst.inputxy); //input
	    	buffer_write(serverBuff, buffer_u8, inst.input_jump); //jumppressthing
	    	buffer_write(serverBuff, buffer_u16, inst.room_id); //room_id
            buffer_write(serverBuff, buffer_bool, inst.isSpectator);
            buffer_write(serverBuff, buffer_s16, socket);

            for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
            {
                network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
            }

            buffer_delete(serverBuff);

            break;
        }

        var nX = buffer_read(buffer, buffer_s32);
        var nY = buffer_read(buffer, buffer_s32);
		var nH = buffer_read(buffer, buffer_f32);
		var nV = buffer_read(buffer, buffer_f32);
		
		var nIXY = buffer_read(buffer, buffer_f32);
		var nJ = buffer_read(buffer, buffer_u8);
		var room_id_to_set = buffer_read(buffer, buffer_u16);
        var isSpectator = buffer_read(buffer, buffer_bool);
        // var hat_id = buffer_read(buffer, buffer_u16);
        
        var socketId = buffer_read(buffer, buffer_s16);

        // show_debug_message(socketId)

        plr = ds_map_find_value(global.Clients, socketId);

        if (is_undefined(plr) || !instance_exists(plr)) {
            break;
        }

        if (!isSpectator)
        {
            plr.x = nX;
            plr.y = nY;
        } else {
            plr.x = 9999;
            plr.y = 9999;
        }

        // plr.x = nX;
        // plr.y = nY;
		
		plr.hspeed = nH;
        plr.vspeed = nV;
		
		plr.inputxy = nIXY;
		plr.input_jump = nJ;
		
		plr.room_id = room_id_to_set;
		
        break;
    
    case 1: // INFO_CMD
        if(!variable_global_exists("oldDifficulty")) {
            break;
        }

        var newDifficulty = buffer_read(buffer, buffer_u16);

        if (global.oldDifficulty != newDifficulty) {
            scr_set_difficulty(newDifficulty);
        }

        global.oldDifficulty = newDifficulty;

        break;

    case 2: // PLRJOIN_CMD
        var inst = instance_create_layer(0,0,"Player",obj_mp_player);

        var sId = buffer_read(buffer, buffer_s16);

        ds_map_add(global.Clients, sId, inst);

        break;

    case 3: // PLRLEAVE_CMD
        var sId = buffer_read(buffer, buffer_s16);

        plr = ds_map_find_value(global.Clients, sId);

        with(plr) { instance_destroy(); }

        ds_map_delete(global.Clients, sId);

        break;

    case 4: // NEWPLR_DATA
        var inst = instance_create_layer(0,0,"Player",obj_mp_player);

        var sId = buffer_read(buffer, buffer_s16);

        inst.name = buffer_read(buffer, buffer_string);
        inst.team = buffer_read(buffer, buffer_string);
        inst.teamName = inst.team
        // inst.isSpectator = buffer_read(buffer, buffer_u8);

        ds_map_add(global.Clients, sId, inst);

        break;

    case 5: // LEVEL_SELECT
        var level = buffer_read(buffer, buffer_s16);

        scr_fade_to_room(level);

        break;

    case 6: // PLR_NAME
        if (global.isHost) { 
            inst.name = buffer_read(buffer, buffer_string);

            var serverBuff = buffer_create(256, buffer_grow, 1);

            buffer_seek(serverBuff, buffer_seek_start, 0);
            buffer_write(serverBuff, buffer_s16, 6);
            buffer_write(serverBuff, buffer_s16, socket);
            buffer_write(serverBuff, buffer_string, inst.name);

            for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
            {
                network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
            }

            break;
        }

        var sId = buffer_read(buffer, buffer_s16);
        var plr = ds_map_find_value(global.Clients, sId);

        if (is_undefined(plr) || !instance_exists(plr)) {
            break;
        }

        var plrName = buffer_read(buffer, buffer_string);

        plr.name = plrName;

        break;

    case 7: // BASKETBALL
        if (global.isHost) { 
            if (instance_exists(obj_ball)) {
                var bRoom = buffer_read(buffer, buffer_u16);
                var nX = buffer_read(buffer, buffer_f32);
                var nY = buffer_read(buffer, buffer_f32);
                var nH = buffer_read(buffer, buffer_f32);
                var nV = buffer_read(buffer, buffer_f32);
                var nS = buffer_read(buffer, buffer_f32);
                var nBX = buffer_read(buffer, buffer_s32);
                var nBY = buffer_read(buffer, buffer_s32);
                var nDir = buffer_read(buffer, buffer_s32);

                if (room == bRoom) {
                    obj_ball.x = nX;
                    obj_ball.y = nY;
                    obj_ball.hspeed = nH;
                    obj_ball.vspeed = nV;
                    obj_ball.speed = nS;
                    obj_ball.ballx_prev1 = nBX;
                    obj_ball.bally_prev1 = nBY;
                    obj_ball.direction = nDir;
                }

                var buff = buffer_create(256, buffer_grow, 1);

                buffer_seek(buff, buffer_seek_start, 0);

                buffer_write(buff, buffer_u16, bRoom);
                buffer_write(buff, buffer_s16, 7);
                buffer_write(buff, buffer_f32, nX);
                buffer_write(buff, buffer_f32, nY);
                buffer_write(buff, buffer_f32, nH);
                buffer_write(buff, buffer_f32, nV);
                buffer_write(buff, buffer_f32, nS);
                buffer_write(buff, buffer_s32, nBX);
                buffer_write(buff, buffer_s32, nBY);
                buffer_write(buff, buffer_s32, nDir);

                for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
                {
                    if (ds_list_find_value(global.socketlist, i) == socket) {
                        continue;
                    }
                    
                    network_send_packet(ds_list_find_value(global.socketlist, i), buff, buffer_tell(buff));
                }

                buffer_delete(buff);
            }
        } else {
            var bRoom = buffer_read(buffer, buffer_u16);

            if (!instance_exists(obj_ball))
                break;

            if (room != bRoom)
                break;

            /* if (!instance_exists(obj_player))
                break; */

            obj_ball.x = buffer_read(buffer, buffer_f32);
            obj_ball.y = buffer_read(buffer, buffer_f32);
            obj_ball.hspeed = buffer_read(buffer, buffer_f32);
            obj_ball.vspeed = buffer_read(buffer, buffer_f32);
            obj_ball.speed = buffer_read(buffer, buffer_f32);
            obj_ball.ballx_prev1 = buffer_read(buffer, buffer_s32);
            obj_ball.bally_prev1 = buffer_read(buffer, buffer_s32);
            obj_ball.direction = buffer_read(buffer, buffer_s32);
        }

        // show_debug_message("Ball x: " + string(obj_ball.x) + " y: " + string(obj_ball.x) + " hspeed: " + string(obj_ball.vspeed) + " vspeed: " + string(obj_ball.vspeed))
        
        break;

    case 8: // HAT
        var created_hat = undefined;

        if (global.isHost) { 
            var hatId = buffer_read(buffer, buffer_s8)

            with (obj_hat_parent)
            {
                if (!dead)
                {
                    if (object_index == obj_simple_hat) {
                        with (obj_simple_hat) {
                            if (variable_instance_exists(id,"custom_player")) {
                                if (custom_player == obj_player)
                                { 
                                    dead = 1
                                    powery = (13 + random(6))
                                    angle = ((global.temporary_stuff - 40) + random(80))
                                    xspeed = (random(6) - 3)
                                    yspeed = -5
                                }
                            }
                        }
                    }

                    if (object_index == obj_simple_hat_heart)
                    {
                        dead = 1
                        powery = (13 + random(6))
                        angle = ((global.temporary_stuff - 40) + random(80))
                        xspeed = (random(6) - 3)
                        yspeed = -5
                        dramatic_death = 1
                        yspeed = -8
                        sound = audio_play_sound(sou_teleport_a, 0.85, false)
                        audio_sound_gain_fx(sound, 0.4, 0)
                        audio_sound_pitch(sound, 0.4)
                    }
                }
            }

            // I love how gamemaker fails to detect that i just want to make a variable like i get it but its also kinda annoying and sometimes creates very stupid bugs
            switch hatId
            {
                case 0:
                    created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
                    created_hat.sprite_index = spr_hat_cylinder
                    break
                case 1:
                    created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
                    created_hat.sprite_index = spr_hat_shelly
                    break
                case 3:
                    created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat_rider)
                    created_hat.sprite_index = spr_hat_human
                    break
                case 2:
                    created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
                    created_hat.sprite_index = spr_hat_unicorn
                    created_hat.glued_to_hat = 1
                    break
                case 4:
                    created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
                    created_hat.sprite_index = spr_hat_winter
                    break
                case 5:
                    created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
                    created_hat.sprite_index = spr_hat_squid
                    created_hat.glued_to_hat = 1
                    break
                case 6:
                    created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
                    created_hat.sprite_index = spr_hat_poopoo
                    break
            }

            if (is_undefined(created_hat))
                break

            created_hat.custom_player = inst

            var buff = buffer_create(256, buffer_grow, 1);

            buffer_seek(buff, buffer_seek_start, 0);

            buffer_write(buff, buffer_s16, 8);
            buffer_write(buff, buffer_s8, hatId);
            buffer_write(buff, buffer_s16, socket);

            for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
            {
                if (ds_list_find_value(global.socketlist, i) == socket) {
                    continue;
                }
                
                network_send_packet(ds_list_find_value(global.socketlist, i), buff, buffer_tell(buff));
            }
        } else {
            var hatId = buffer_read(buffer, buffer_s8)

            switch hatId
            {
                case 0:
                    var created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
                    created_hat.sprite_index = spr_hat_cylinder
                    break
                case 1:
                    var created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
                    created_hat.sprite_index = spr_hat_shelly
                    break
                case 3:
                    var created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat_rider)
                    created_hat.sprite_index = spr_hat_human
                    break
                case 2:
                    var created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
                    created_hat.sprite_index = spr_hat_unicorn
                    created_hat.glued_to_hat = 1
                    break
                case 4:
                    var created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
                    created_hat.sprite_index = spr_hat_winter
                    break
                case 5:
                    var created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
                    created_hat.sprite_index = spr_hat_squid
                    created_hat.glued_to_hat = 1
                    break
                case 6:
                    var created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
                    created_hat.sprite_index = spr_hat_poopoo
                    break
            }

            if (is_undefined(created_hat))
                break

            var socketId = buffer_read(buffer, buffer_s16);

            plr = ds_map_find_value(global.Clients, socketId);

            if (is_undefined(plr) || !instance_exists(plr)) {
                break;
            }

            with (obj_hat_parent)
            {
                if (!dead)
                {
                    if (object_index == obj_simple_hat) {
                        with (obj_simple_hat) {
                            if (variable_instance_exists(id,"custom_player")) {
                                if (custom_player == obj_player)
                                { 
                                    dead = 1
                                    powery = (13 + random(6))
                                    angle = ((global.temporary_stuff - 40) + random(80))
                                    xspeed = (random(6) - 3)
                                    yspeed = -5
                                }
                            }
                        }
                    }

                    if (object_index == obj_simple_hat_heart)
                    {
                        dead = 1
                        powery = (13 + random(6))
                        angle = ((global.temporary_stuff - 40) + random(80))
                        xspeed = (random(6) - 3)
                        yspeed = -5
                        dramatic_death = 1
                        yspeed = -8
                        sound = audio_play_sound(sou_teleport_a, 0.85, false)
                        audio_sound_gain_fx(sound, 0.4, 0)
                        audio_sound_pitch(sound, 0.4)
                    }
                }
            }
                
            created_hat.custom_player = plr
        }

        break;

    case 9: // TEAM
        if (global.isHost)
        {
            inst.team = buffer_read(buffer, buffer_string);
            var hideTeam = buffer_read(buffer, buffer_string);

            if (hideTeam == obj_player.team)
                inst.teamName = "";
            else
                inst.teamName = inst.team

            var serverBuff = buffer_create(256, buffer_grow, 1);

            buffer_write(serverBuff, buffer_s16, 9);
            buffer_write(serverBuff, buffer_string, inst.team)
            buffer_write(serverBuff, buffer_string, hideTeam)
            buffer_write(serverBuff, buffer_s16, socket);
        }
        else
        {
            var funnyTeam = buffer_read(buffer, buffer_string)
            var hideTeam = buffer_read(buffer, buffer_string);

            var socketId = buffer_read(buffer, buffer_s16);

            var plr = ds_map_find_value(global.Clients, socketId);

            if (is_undefined(plr))
                break;
            if (is_undefined(obj_player))
                break;

            if (hideTeam == obj_player.team)
            {
                plr.team = funnyTeam;
                plr.teamName = "";

                // show_debug_message("Hiding team")
            }
            else
            {
                plr.team = funnyTeam;
                plr.teamName = funnyTeam;

                // show_debug_message("Setting team to: " + string(funnyTeam))
            }
        }

        break;

    default:
        if (global.isHost)
        {
            if (!is_undefined(ds_list_find_value(global.custom_packets, msgid)))
            {
                script_execute(ds_list_find_value(global.custom_packets_callbacks, msgid))
            }

            // global.custom_packets
        }
        else 
        {

        }

        break;
}