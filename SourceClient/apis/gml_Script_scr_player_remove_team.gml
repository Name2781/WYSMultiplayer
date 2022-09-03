if (ds_map_size(global.Clients) == 0) {
    return false;
}

var plr = ds_map_find_value(global.Clients, argument0)

if (is_undefined(plr))
    return false;

plr.team = ""

if (global.isHost)
{
    var buff = buffer_create(256, buffer_grow, 1);

    buffer_seek(buff, buffer_seek_start, 0);

    buffer_write(buff, buffer_string, plr.team);
    buffer_write(buff, buffer_string, argument2);

    for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
    {
        network_send_packet(ds_list_find_value(global.socketlist, i), buff, buffer_tell(buff));
    }

    buffer_delete(buff);
} 
else
{
    var buff = buffer_create(256, buffer_grow, 1);

    buffer_seek(buff, buffer_seek_start, 0);

    buffer_write(buff, buffer_string, plr.team);
    buffer_write(buff, buffer_string, argument2);

    network_send_packet(global.clientTCP, buff, buffer_get_size(buff));

    buffer_delete(buff);
}
