if (ds_map_size(global.Clients) == 0) {
    return false;
}

if argument0 == obj_player
{
    plr = obj_player
    global.team = argument1
}
else
{
    var plr = ds_map_find_value(global.Clients, argument0)
}

if (is_undefined(plr))
    return false;

if (obj_player.team == argument2)
{
    plr.team = argument1
    plr.teamName = ""
}
else
{
    plr.team = argument1
    plr.teamName = argument1
}

if (global.isHost)
{
    var buff = buffer_create(256, buffer_grow, 1);

    buffer_seek(buff, buffer_seek_start, 0);

    buffer_write(buff, buffer_s16, 9);
    buffer_write(buff, buffer_string, argument1);
    buffer_write(buff, buffer_string, argument2);

    if (argument0 == obj_player)
        buffer_write(buff, buffer_s16, 0);
    else
        buffer_write(buff, buffer_s16, argument0);

    for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
    {
        if (i != argument0)
            network_send_packet(ds_list_find_value(global.socketlist, i), buff, buffer_tell(buff));
    }

    buffer_delete(buff);
} 
else
{
    var buff = buffer_create(256, buffer_grow, 1);

    buffer_seek(buff, buffer_seek_start, 0);

    buffer_write(buff, buffer_s16, 9);
    buffer_write(buff, buffer_string, argument1);
    buffer_write(buff, buffer_string, argument2);

    network_send_packet(global.clientTCP, buff, buffer_get_size(buff));

    buffer_delete(buff);
}
