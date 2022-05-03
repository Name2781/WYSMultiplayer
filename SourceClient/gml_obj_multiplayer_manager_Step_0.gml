if(!variable_global_exists("isReady")) {
    return false;
}

if(!variable_global_exists("iteration")) {
    return false;
}

if(!instance_exists(obj_player)) {
    return false;
}

if (global.iteration < 3) {
    global.iteration = global.iteration + 1;

    return false;
}
else {
    global.iteration = 0;

    if(global.isHost) {
        // TODO: server network logic
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
		
        buffer_write(serverBuff, buffer_s16, 0);

        for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
        {
            network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
        }

        buffer_delete(serverBuff);

    } else {
        if (global.state == "inGame" && global.isReady) {
            // TODO: send if the player is jumping and spawn particles*
            scr_send_position(obj_player.x, obj_player.y, obj_player.hspeed, obj_player.vspeed, global.input_x, global.input_jump, room)

            // scr_send_player_info(obj_player.hspeed, obj_player.vspeed, obj_player.speed, obj_player.gun_equipped, obj_player.lookdir)
        }
    }
}