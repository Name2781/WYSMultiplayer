instance_destroy(obj_mp_player)
instance_destroy(obj_multiplayer_manager)

if (global.isHost)
{
    network_destroy(global.serverTCP)
}
else
{
    network_destroy(global.clientTCP)
}

global.justReset = true

global.isHost = undefined

scr_continue()