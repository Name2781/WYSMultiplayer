if(!variable_global_exists("isReady")) {
    return false;
}

if(!variable_global_exists("iteration")) {
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
        buffer_write(serverBuff, buffer_s16, obj_player.x);
        buffer_write(serverBuff, buffer_s16, obj_player.y);
        buffer_write(serverBuff, buffer_s16, 0);

        for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
        {
            network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
        }

        buffer_delete(serverBuff);

    } else {
        if (global.state == "inGame" && global.isReady) {
            // TODO: send if the player is jumping and spawn particles
            scr_send_position(obj_player.x, obj_player.y)

            // scr_send_player_info(obj_player.hspeed, obj_player.vspeed, obj_player.speed, obj_player.gun_equipped, obj_player.lookdir)
        }
    }
}