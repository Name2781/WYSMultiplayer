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

if (global.iteration < 3) {
    global.iteration = global.iteration + 1;

    return false;
}
else {
    global.iteration = 0;

    if(global.isHost && global.isReady) {
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

        for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
        {
            network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
        }

        buffer_delete(serverBuff);

        var diffBuff = buffer_create(256, buffer_grow, 1);
		
        buffer_seek(diffBuff, buffer_seek_start, 0);
        buffer_write(diffBuff, buffer_s16, 1); // INFO_CMD
        buffer_write(diffBuff, buffer_u16, global.save_difficulty); // difficulty

        for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
        {
            network_send_packet(ds_list_find_value(global.socketlist, i), diffBuff, buffer_tell(diffBuff));
        }

        buffer_delete(diffBuff);

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
            scr_send_position(obj_player.x, obj_player.y, obj_player.hspeed, obj_player.vspeed, global.input_x, global.input_jump, room, global.isSpectator);

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