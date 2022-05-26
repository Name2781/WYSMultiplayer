var t = ds_map_find_value(async_load, "type");

var sock = ds_map_find_value(async_load, "socket");

var ip = ds_map_find_value(async_load, "ip");

switch(t)
{
    case network_type_connect:
        scr_player_join(sock);

        ds_list_add( global.socketlist, sock );
    
        var inst = instance_create_layer(0,0,"Player",obj_mp_player);

        ds_map_add( global.Clients, sock, inst );

        break;

    case network_type_disconnect:
        var inst = ds_map_find_value(global.Clients, sock );

        ds_map_delete(global.Clients, sock );
        with(inst) { instance_destroy(); }

        var index = ds_list_find_index( global.socketlist, sock );
        ds_list_delete(global.socketlist,index);

        var serverBuff = buffer_create(256, buffer_grow, 1);

        buffer_seek(serverBuff, buffer_seek_start, 0);
        buffer_write(serverBuff, buffer_s16, 3);
        buffer_write(serverBuff, buffer_s16, sock);

        for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
        {
            network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
        }

        buffer_delete(serverBuff);

        break;

    case network_type_data:
        var buff = ds_map_find_value(async_load, "buffer");
        var sock = ds_map_find_value(async_load, "id");

        scr_recived_packet(buff, sock);

        break;
}