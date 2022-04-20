var t = ds_map_find_value(async_load, "type");

var sock = ds_map_find_value(async_load, "socket");

var ip = ds_map_find_value(async_load, "ip");

show_debug_message("type: " + string(t));

switch(t)
{
    case network_type_connect:
        // show_debug_message("Connecting to " + ip);

        ds_list_add( global.socketlist, sock );
    
        var inst = instance_create_layer(0,0,"Player",obj_mp_player);

        show_debug_message(object_get_name(inst));

        ds_map_add( global.Clients, sock, inst );

        break;

    case network_type_disconnect:
        var inst = ds_map_find_value(global.Clients, sock );

        ds_map_delete(global.Clients, sock );
        with(inst) { instance_destroy(); }

        var index = ds_list_find_index( global.socketlist, sock );
        ds_list_delete(socketlist,index);

        break;

    case network_type_data:
        var buff = ds_map_find_value(async_load, "buffer");
        var sock = ds_map_find_value(async_load, "id");

        scr_recived_packet(buff, sock);

        break;
}