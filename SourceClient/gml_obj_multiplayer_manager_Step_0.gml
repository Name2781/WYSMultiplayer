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

    } else {
        if (global.state == "inGame" && global.isReady) {
            // TODO: send if the player is jumping and spawn particles
            scr_send_position(obj_player.x, obj_player.y)

            scr_send_player_info(obj_player.hspeed, obj_player.vspeed, obj_player.speed, obj_player.gun_equipped, obj_player.lookdir)
        }
    }
}