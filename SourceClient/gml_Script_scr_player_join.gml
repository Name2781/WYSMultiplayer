var sock = argument0
var serverBuff = buffer_create(256, buffer_grow, 1);

buffer_seek(serverBuff, buffer_seek_start, 0);
buffer_write(serverBuff, buffer_s16, 2);
buffer_write(serverBuff, buffer_s16, sock);
// uffer_write(serverBuff, buffer_string, "");

for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
{
    network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
}

buffer_delete(serverBuff);

for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
{
    var serverBuff = buffer_create(256, buffer_grow, 1);

    buffer_seek(serverBuff, buffer_seek_start, 0);
    buffer_write(serverBuff, buffer_s16, 4);
    buffer_write(serverBuff, buffer_s16, ds_list_find_value(global.socketlist, i));

    network_send_packet(sock, serverBuff, buffer_tell(serverBuff));

    buffer_delete(serverBuff);
}

var serverBuff = buffer_create(256, buffer_grow, 1);

buffer_seek(serverBuff, buffer_seek_start, 0);
buffer_write(serverBuff, buffer_s16, 4);
buffer_write(serverBuff, buffer_s16, 0);
// buffer_write(serverBuff, buffer_string, global.name);

network_send_packet(sock, serverBuff, buffer_tell(serverBuff));

buffer_delete(serverBuff);