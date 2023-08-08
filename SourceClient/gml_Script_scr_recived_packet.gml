buffer = argument0;
socket = argument1;

if (buffer_get_size(buffer) < 256)
{
	debug_log("Discarding bad packet")
	return 0;
}

msgid = buffer_read(buffer, buffer_s16);

buffer_copy(buffer, 0, 256, global.currentPacketData, 0);

ds_list_add(global.lastPackets, msgid)

if (ds_list_size(global.lastPackets) > 20)
{
	ds_list_delete(global.lastPackets, 21)
}

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

        global.plr = ds_map_find_value(global.Clients, sId);

        with (obj_simple_hat)
        {
            if (!variable_instance_exists(id,"play_objc"))
                continue;

            if (is_undefined("play_objc"))
                continue;

            if (play_objc == global.plr)
            {
                instance_destroy();
            }
        }
		
		if (variable_global_exists("plr"))
		{
			if (global.plr != undefined && instance_exists(global.plr))
			{
				with(global.plr) { instance_destroy(); }
			}
		}

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

        show_debug_message("New player")

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
        
        if (!instance_exists(obj_player))
        	break;

        if (global.isHost) { 
            global.hatId = buffer_read(buffer, buffer_s8)

            with (obj_hat_parent)
            {
                if (!dead)
                {
                    if (object_index == obj_simple_hat) {
                        with (obj_simple_hat) {
                            if (variable_instance_exists(id,"custom_player")) {
                                if (custom_player == inst && global.hatId != hatId)
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
            switch global.hatId
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

            var buff = buffer_create(256, buffer_grow, 1);

            buffer_seek(buff, buffer_seek_start, 0);

            buffer_write(buff, buffer_s16, 8);
            buffer_write(buff, buffer_s8, global.hatId);
            buffer_write(buff, buffer_s16, socket);

            for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
            {
                if (ds_list_find_value(global.socketlist, i) == socket) {
                    continue;
                }
                
                network_send_packet(ds_list_find_value(global.socketlist, i), buff, buffer_tell(buff));
            }

            if (is_undefined(created_hat))
                break

            created_hat.hatId = global.hatId

            created_hat.custom_player = inst
        } else {
            global.hatId = buffer_read(buffer, buffer_s8)

            var socketId = buffer_read(buffer, buffer_s16);

            plr = ds_map_find_value(global.Clients, socketId);

            // show_debug_message("Starting hat packet")

            with (obj_hat_parent)
            {
                if (!dead)
                {
                    if (object_index == obj_simple_hat) {
                        with (obj_simple_hat) {
                            if (variable_instance_exists(id,"custom_player")) {
                                if (custom_player == plr && global.hatId != hatId)
                                { 
                                    // show_debug_message("Killing hat for player: " + string(plr.name))
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

            switch global.hatId
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

            // show_debug_message("Hat packet 2")

            if (is_undefined(plr) || !instance_exists(plr)) {
                break;
            }

            // show_debug_message("Editing hat for player: " + string(plr.name))

            created_hat.hatId = global.hatId
                
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

            for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
            {
                if (ds_list_find_value(global.socketlist, i) == socket) {
                    continue;
                }
                
                network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
            }

            buffer_delete(serverBuff)
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

    case 10: // sync room packet, or as I call it Hat sync 2: Electric bogaloo
        // update to sync players that are in room also so everyone has hats

        if (global.isHost)
        {
            global.roomId = buffer_read(buffer, buffer_s16)
            global.hatId = buffer_read(buffer, buffer_s8)

            var sBuff = buffer_create(256, buffer_grow, 1); // sync buffer

            buffer_write(sBuff, buffer_s16, 11);
            buffer_write(sBuff, buffer_s16, socket);

            for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
            {         
                if (ds_list_find_value(global.socketlist, i) == socket) {
                    continue;
                }

                network_send_packet(ds_list_find_value(global.socketlist, i), sBuff, buffer_tell(sBuff));
            }

            buffer_delete(sBuff)

            if (room != global.roomId)
            {
                var serverBuff = buffer_create(256, buffer_grow, 1);

                buffer_write(serverBuff, buffer_s16, 10);
                buffer_write(serverBuff, buffer_s16, global.roomId)
                buffer_write(serverBuff, buffer_s8, global.hatId)
                buffer_write(serverBuff, buffer_s16, socket);

                for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
                {         
                    if (ds_list_find_value(global.socketlist, i) == socket) {
                        continue;
                    }

                    network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
                }

                buffer_seek(serverBuff, buffer_seek_start, 0)

                buffer_write(serverBuff, buffer_s16, 10);
                buffer_write(serverBuff, buffer_s16, room)
                buffer_write(serverBuff, buffer_s8, -1)
                buffer_write(serverBuff, buffer_s16, 0);

                network_send_packet(socket, serverBuff, buffer_tell(serverBuff))

                buffer_delete(serverBuff)

                break
            }

            with(inst)
            {
                if (room == global.roomId)
                {
                    var created_hat = undefined;

                    switch global.hatId
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

                    if (!is_undefined(created_hat))
                        created_hat.custom_player = inst
                }
            }

            var serverBuff = buffer_create(256, buffer_grow, 1);

            buffer_write(serverBuff, buffer_s16, 10);
            buffer_write(serverBuff, buffer_s16, global.roomId)
            buffer_write(serverBuff, buffer_s8, global.hatId)
            buffer_write(serverBuff, buffer_s16, socket);

            for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
            {       
                if (ds_list_find_value(global.socketlist, i) == socket) {
                    continue;
                }

                network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
            }

            buffer_seek(serverBuff, buffer_seek_start, 0)

            buffer_write(serverBuff, buffer_s16, 10);
            buffer_write(serverBuff, buffer_s16, room)
            buffer_write(serverBuff, buffer_s8, global.save_equipped_hat)
            buffer_write(serverBuff, buffer_s16, 0);

            network_send_packet(socket, serverBuff, buffer_tell(serverBuff))

            buffer_delete(serverBuff)
        }
        else
        {
            global.roomId = buffer_read(buffer, buffer_s16)
            global.hatId = buffer_read(buffer, buffer_s8)

            var socketId = buffer_read(buffer, buffer_s16);

            plr = ds_map_find_value(global.Clients, socketId);

            if (room != global.roomId)
                break

            if (socketId == 0)
            {
                var buff = buffer_create(256, buffer_grow, 1);

                buffer_seek(buff, buffer_seek_start, 0);

                buffer_write(buff, buffer_s16, 11);
                buffer_write(buff, buffer_s16, room);
                buffer_write(buff, buffer_s8, global.save_equipped_hat);
                buffer_write(buff, buffer_s16, 1337);
                buffer_write(buff, buffer_bool, true); // skip it cause we just want to spawn it on the host and not relay it

                network_send_packet(global.clientTCP, buff, buffer_get_size(buff));

                buffer_delete(buff);
            }

            with(plr)
            {
                if (room == global.roomId)
                {
                    var created_hat = undefined;

                    switch global.hatId
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

                    if (!is_undefined(created_hat))
                        created_hat.custom_player = plr
                }
            }
        }

        break;

    case 11: // look mom more hat sync (hat query)
        if (global.isHost)
        {
            // send player socket, hat id, and room basically send a room sync with every player
            global.roomId = buffer_read(buffer, buffer_s16)
            global.hatId = buffer_read(buffer, buffer_s8)

            var target = buffer_read(buffer, buffer_s16); // target

            var skip = buffer_read(buffer, buffer_bool)

            // plr = ds_map_find_value(global.Clients, socketId);

            if (room == global.roomId && skip)
            {
                with(inst)
                {
                    if (room == global.roomId)
                    {
                        var created_hat = undefined;

                        switch global.hatId
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

                        if (!is_undefined(created_hat))
                            created_hat.custom_player = inst
                    }
                }

                break
            }

            var serverBuff = buffer_create(256, buffer_grow, 1);

            buffer_write(serverBuff, buffer_s16, 10);
            buffer_write(serverBuff, buffer_s16, global.roomId)
            buffer_write(serverBuff, buffer_s8, global.hatId)
            buffer_write(serverBuff, buffer_s16, socket);

            network_send_packet(target, serverBuff, buffer_tell(serverBuff))

            buffer_delete(serverBuff)
        }
        else
        {
            var target = buffer_read(buffer, buffer_s16);

            var buff = buffer_create(256, buffer_grow, 1);

            buffer_seek(buff, buffer_seek_start, 0);

            buffer_write(buff, buffer_s16, 11);
            buffer_write(buff, buffer_s16, room);
            buffer_write(buff, buffer_s8, global.save_equipped_hat);
            buffer_write(buff, buffer_s16, target);
            buffer_write(buff, buffer_bool, false);

            network_send_packet(global.clientTCP, buff, buffer_get_size(buff));

            buffer_delete(buff);
        }

        break;

    case 12:
        switch (buffer_read(buffer, buffer_s16))
        {
            case 0: // add
                var buff = buffer_create(256, buffer_grow, 1);

                var type = buffer_read(buffer, buffer_string)

                var layer = buffer_read(buffer, buffer_string)
                
                if (!asset_get_index(type) > -1)
                {
                	type = "obj_wall"
                }
                if (!layer_exists(layer))
                {
                	layer = "Walls"
                }

                var createdObj = instance_create_layer(0, 0, layer, asset_get_index(type))

                createdObj.x = buffer_read(buffer, buffer_s32);
                createdObj.y = buffer_read(buffer, buffer_s32);
                createdObj.image_xscale = buffer_read(buffer, buffer_f32)
                createdObj.image_yscale = buffer_read(buffer, buffer_f32)

                buffer_seek(buff, buffer_seek_start, 0);

                buffer_write(buff, buffer_s16, 12);

                buffer_write(buff, buffer_s32, createdObj.id);

                network_send_packet(global.clientTCP, buff, buffer_get_size(buff));

                buffer_delete(buff);

                break;

            case 1: // remove
                with (buffer_read(buffer, buffer_s32))
                {
                    instance_destroy();
                }

                break;

            case 2: // move
                global.Nx = buffer_read(buffer, buffer_s32);
                global.Ny = buffer_read(buffer, buffer_s32);
                with (buffer_read(buffer, buffer_s32))
                {
                    x = global.Nx
                    y = global.Ny
                }

                break;

            case 4:
                global.Nx = buffer_read(buffer, buffer_f32);
	    	    global.Ny = buffer_read(buffer, buffer_f32);

                with (buffer_read(buffer, buffer_s32))
                {
                    image_xscale = global.Nx
                    image_yscale = global.Ny
                }
                break;

            case 5:
                var Cx = buffer_read(buffer, buffer_s32)
                var Cy = buffer_read(buffer, buffer_s32)
                var Ctext = buffer_read(buffer, buffer_string)
                var Cxscale = buffer_read(buffer, buffer_f32)
	    	    var Cyscale = buffer_read(buffer, buffer_f32)
                var Cangle = buffer_read(buffer, buffer_s32)
                var Cstay = buffer_read(buffer, buffer_f32)

                var data = buffer_create(256, buffer_grow, 1);

                buffer_write(data, buffer_s32, Cx)
                buffer_write(data, buffer_s32, Cy)
                buffer_write(data, buffer_f32, Cxscale)
                buffer_write(data, buffer_f32, Cyscale)
                buffer_write(data, buffer_s32, Cangle)

                ds_list_add(global.hold, Cstay)
                ds_list_add(global.texts, Ctext)
                ds_list_add(global.datas, data)

                break;

            case 6:
                ds_list_clear(global.hold)
                ds_list_clear(global.texts)
                ds_list_clear(global.datas)

                break;

            case 7:
                room_goto(asset_get_index(buffer_read(buffer, buffer_string)))
                break;
            case 8:
                var dtype = buffer_read(buffer, buffer_s8)
                var data = undefined

                switch (dtype)
                {
                    case 0:
                        data = buffer_read(buffer, buffer_bool)
                        break;
                    case 1:
                        data = buffer_read(buffer, buffer_text)
                        break;
                    case 2:
                        data = buffer_read(buffer, buffer_s32)
                        break;
                    case 3:
                        data = buffer_read(buffer, buffer_f32)
                        break;
                }

                variable_global_set(buffer_read(buffer, buffer_text), data)
                break;
            case 9:
                var roomAsset = asset_get_index(buffer_read(buffer, buffer_text))
                room_set_width(roomAsset, buffer_read(buffer, buffer_s32))
                room_set_height(roomAsset, buffer_read(buffer, buffer_s32))
                break;
            case 10:
                var dtype = buffer_read(buffer, buffer_s8)
                global.data = undefined
                global.setVar = buffer_read(buffer, buffer_text)

                switch (dtype)
                {
                    case 0:
                        global.data = buffer_read(buffer, buffer_bool)
                        break;
                    case 1:
                        global.data = buffer_read(buffer, buffer_text)
                        break;
                    case 2:
                        global.data = buffer_read(buffer, buffer_s32)
                        break;
                    case 3:
                        global.data = buffer_read(buffer, buffer_f32)
                        break;
                }

                variable_instance_set(instance_id_get(buffer_read(buffer, buffer_s32)), global.setVar, global.data)
                break;
            case 11:
                obj_player.x = buffer_read(buffer, buffer_f32)
                obj_player.y = buffer_read(buffer, buffer_f32)
                break;
            case 12:
                scr_split_walls()
				scr_create_wall_lines()
				break;
        }

        break;

    case 14:
        if (room != buffer_read(buffer, buffer_u16))
            break;

        var obj = instance_find(asset_get_index(buffer_read(buffer, buffer_string)), buffer_read(buffer, buffer_s16))
        obj.x = buffer_read(buffer, buffer_s16)
        obj.y = buffer_read(buffer, buffer_s16)
        obj.hspeed = buffer_read(buffer, buffer_f32)
        obj.vspeed = buffer_read(buffer, buffer_f32)
        break;

    case 210:
	debug_log("两百一十");
	break;

    default:
        if (global.isHost)
        {
            if (!is_undefined(ds_list_find_value(global.custom_packets, msgid)))
            {   
                var types = ds_list_create();
                var data = ds_list_create();

                for (var i = 0; i > buffer_read(buffer, buffer_s16); ++i;)
                {
                    ds_list_add(types, buffer_read(buffer, buffer_s16));
                }

                for (var i = 0; i > ds_list_size(types); ++i;)
                {
                    switch ds_list_find_value(types, i)
                    {
                        case 1:
                            ds_list_add(data, buffer_read(buffer, buffer_string))
                            break;

                        case 2:
                            ds_list_add(data, buffer_read(buffer, buffer_s32))
                            break;

                        case 3:
                            ds_list_add(data, buffer_read(buffer, buffer_bool))
                            break;
                    }
                }

                script_execute(ds_list_find_value(global.custom_packets_callbacks, msgid), data)
            }
        }
        else 
        {

        }

        break;
}
