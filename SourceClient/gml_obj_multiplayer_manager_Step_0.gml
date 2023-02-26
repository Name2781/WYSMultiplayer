// show_debug_message(global.save_equipped_hat)

if(!variable_global_exists("isReady")) {
    return false;
}

if(!variable_global_exists("iteration")) {
    return false;
}

if(!instance_exists(obj_player)) {
    return false;
}

if(!variable_global_exists("isSpectator")) {
    return false;
}

if (global.isSpectator && variable_global_exists("spectating")) {
    if keyboard_check_pressed(vk_ralt) {
        global.spectating = global.spectating + 1;

        if (global.spectating > ds_map_size(global.Clients)) {
            global.spectating = 0;
        }
    }

    if keyboard_check_pressed(vk_lalt) {
        global.spectating = global.spectating - 1;

        if (global.spectating < 0) {
            global.spectating = ds_map_size(global.Clients);
        }
    }
}

if (keyboard_check_pressed(vk_control))
{
	if (keyboard_check_pressed(vk_shift))
	{
		if (keyboard_check_pressed(ord("d")))
		{
		    debug_log("Replaying saved packet")
		    show_debug_message("Replaying saved packet")
			var badPacket = buffer_load("packet.bin")
			scr_recived_packet(badPacket, 0)
		}
	}
}

if (global.iteration < 3) {
    global.iteration = global.iteration + 1;

    return false;
}
else {
    global.iteration = 0;

    if(global.isHost && global.isReady) {
        /*for (var i = 0; i < instance_number(obj_squasher); ++i;)
        {
            var serverBuff = buffer_create(256, buffer_grow, 1);

            buffer_write(serverBuff, buffer_s16, 14);
            buffer_write(serverBuff, buffer_u16, room)
            buffer_write(serverBuff, buffer_string, "obj_squasher");
            buffer_write(serverBuff, buffer_s16, i);
            buffer_write(serverBuff, buffer_s16, instance_find(obj_squasher, i).x);
            buffer_write(serverBuff, buffer_s16, instance_find(obj_squasher, i).y);
            buffer_write(serverBuff, buffer_f32, instance_find(obj_squasher, i).hspeed);
            buffer_write(serverBuff, buffer_f32, instance_find(obj_squasher, i).vspeed);

            for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
            {
                network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
            }

            buffer_delete(serverBuff);
        }*/

        if (obj_player.x != global.oldx || obj_player.y != global.oldy)
        {
            var serverBuff = buffer_create(256, buffer_grow, 1);

            buffer_seek(serverBuff, buffer_seek_start, 0);
            buffer_write(serverBuff, buffer_s16, 0);
            buffer_write(serverBuff, buffer_s32, obj_player.x); //x
            buffer_write(serverBuff, buffer_s32, obj_player.y); //y
            buffer_write(serverBuff, buffer_f32, obj_player.hspeed); //hspeed
            buffer_write(serverBuff, buffer_f32, obj_player.vspeed); //vspeed
            buffer_write(serverBuff, buffer_f32, global.input_x); //inputxy
            buffer_write(serverBuff, buffer_u8, global.input_jump); //inputjump
            buffer_write(serverBuff, buffer_u16, room); //room
            buffer_write(serverBuff, buffer_bool, global.isSpectator); // isSpectator
            
            buffer_write(serverBuff, buffer_s16, 0);

            global.oldx = obj_player.x;
            global.oldy = obj_player.y;

            for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
            {
                network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
            }

            buffer_delete(serverBuff);
        }

        // scr_player_add_team(1, "Bozo", "Blind")
        // scr_player_add_team(obj_player, "Blind", "immajustsetthistoafaketeam")

        // show_debug_message(obj_player.team)

        var diffBuff = buffer_create(256, buffer_grow, 1);
		
        buffer_seek(diffBuff, buffer_seek_start, 0);
        buffer_write(diffBuff, buffer_s16, 1); // INFO_CMD
        buffer_write(diffBuff, buffer_u16, global.save_difficulty); // difficulty

        for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
        {
            network_send_packet(ds_list_find_value(global.socketlist, i), diffBuff, buffer_tell(diffBuff));
        }

        buffer_delete(diffBuff);

        if (global.oldHatId != global.save_equipped_hat) {
            var buff = buffer_create(256, buffer_grow, 1);

            buffer_seek(buff, buffer_seek_start, 0);

            buffer_write(buff, buffer_s16, 8);
            buffer_write(buff, buffer_s8, global.save_equipped_hat);
            buffer_write(buff, buffer_s16, 0);

            for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
            {
                network_send_packet(ds_list_find_value(global.socketlist, i), buff, buffer_tell(buff));
            }

            buffer_delete(buff);

            with obj_simple_hat
            {
                if (!dead)
                {
                    if (old == 1)
                    {
                        dead = 1
                        powery = (13 + random(6))
                        angle = ((global.temporary_stuff - 40) + random(80))
                        xspeed = (random(6) - 3)
                        yspeed = -5
                    }
                }
            }

            // show_debug_message(global.oldHatId)
            // show_debug_message(global.save_equipped_hat)

            global.oldHatId = global.save_equipped_hat;
        }

        if (global.isSpectator) {
            obj_player.visible = false;

            if(!variable_global_exists("spectating")) {
                return false;
            }

            plr = ds_map_find_value(global.Clients, global.spectating);

            if (is_undefined(plr)) {
                return false;
            }

            if(!instance_exists(plr)) {
                return false;
            }

            if (plr.isSpectator)
                return false;

            obj_player.x = plr.x;
            obj_player.y = plr.y;
        }
    } else {
        if (global.state == "inGame" && global.isReady) {
            // TODO: send if the player is jumping and spawn particles

            if (keyboard_check_pressed(ord("E")))
            {
                var buff = buffer_create(256, buffer_grow, 1);

                buffer_seek(buff, buffer_seek_start, 0);

                buffer_write(buff, buffer_s16, 13);

                network_send_packet(global.clientTCP, buff, buffer_get_size(buff));

                buffer_delete(buff);
            }

            if (obj_player.x != global.oldx || obj_player.y != global.oldy)
            {
                scr_send_position(obj_player.x, obj_player.y, obj_player.hspeed, obj_player.vspeed, global.input_x, global.input_jump, room, global.isSpectator);
                
                global.oldx = obj_player.x;
                global.oldy = obj_player.y;
            }

            if (global.oldHatId != global.save_equipped_hat) {
                var buff = buffer_create(256, buffer_grow, 1);

                buffer_seek(buff, buffer_seek_start, 0);

                buffer_write(buff, buffer_s16, 8);
                buffer_write(buff, buffer_s8, global.save_equipped_hat);

                network_send_packet(global.clientTCP, buff, buffer_get_size(buff));

                buffer_delete(buff);

                with obj_simple_hat
                {
                    if (!dead)
                    {
                        if (old == 1)
                        {
                            dead = 1
                            powery = (13 + random(6))
                            angle = ((global.temporary_stuff - 40) + random(80))
                            xspeed = (random(6) - 3)
                            yspeed = -5
                        }
                    }
                }

                // show_debug_message(global.oldHatId)
                // show_debug_message(global.save_equipped_hat)

                global.oldHatId = global.save_equipped_hat;
            }

            if (global.isSpectator) {
                obj_player.visible = false;

                if(!variable_global_exists("spectating")) {
                    return false;
                }

                plr = ds_map_find_value(global.Clients, global.spectating);

                if (is_undefined(plr)) {
                    return false;
                }
                if(!instance_exists(plr)) {
                    return false;
                }

                if (plr.isSpectator)
                    return false;

                obj_player.x = plr.x;
                obj_player.y = plr.y;
            }
        }
    }
}