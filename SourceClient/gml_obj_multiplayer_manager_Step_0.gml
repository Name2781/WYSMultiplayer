var iteration = 0;

if (iteration < 9)
    return false;
else 
    iteration = 0;

if(!variable_global_exists("isReady")) {
    return false;
}

if(global.isHost) {
    // server network logic

} else {
    // client network logic
    if (global.state == "inGame" && global.isReady) {
        // check if x and y are the same as last frame and if so then dont send to the server to save bandwidth
        /* if (obj_player.x != obj_player.lastX || obj_player.y != obj_player.lastY) {
            obj_player.lastX = obj_player.x
            obj_player.lastY = obj_player.y
            
            scr_send_position(obj_player.x, obj_player.y)
        } */
        // TODO: send if the player is jumping and spawn particles
        scr_send_position(obj_player.x, obj_player.y)

        scr_send_player_info(obj_player.hspeed, obj_player.vspeed, obj_player.speed, obj_player.gun_equipped, obj_player.lookdir)
    }
}