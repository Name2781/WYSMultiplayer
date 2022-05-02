// var level = get_integer("Enter the level to play: ", "A_03_hello_spikes");

scr_fade_to_room(level_select);

var serverBuff = buffer_create(256, buffer_grow, 1);

buffer_seek(serverBuff, buffer_seek_start, 0);
buffer_write(serverBuff, buffer_s16, 5);
buffer_write(serverBuff, buffer_s16, level_select);

for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
{
    network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
}

buffer_delete(serverBuff);