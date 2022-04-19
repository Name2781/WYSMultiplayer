// get connect or disconnect (1=connect)
var t = ds_map_find_value(async_load, "type");

// Get the NEW socket ID, or the socket that's disconnecting
var sock = ds_map_find_value(async_load, "socket");

// Get the IP that the socket comes from
var ip = ds_map_find_value(async_load, "ip");

// Connecting?
if( t==network_type_connect)
{
    // add client to our list of connected clients
    ds_list_add( global.socketlist, sock );

    // Create a new player, and pick a random colour for that player        
    var inst = instance_create_layer(0,0,Player,obj_mp_player);

    // put this instance into a map, using the socket ID as the lookup
    ds_map_add( global.Clients, sock, inst );
}
else
{
    // disconnect a CLIENT. First find the player instance using the socket ID as a lookup
    var inst = ds_map_find_value(global.Clients, sock );

    // Delete the socket from out map, and kill the player instance
    ds_map_delete(global.Clients, sock );
    with(inst) { instance_destroy(); }
    
    // Also delete the socket from our global list of connected clients
    var index = ds_list_find_index( global.socketlist, sock );
    ds_list_delete(socketlist,index);
}

var buff = ds_map_find_value(async_load, "buffer");

var cmd = buffer_read(buff, buffer_s16 );

var sock = ds_map_find_value(async_load, "id");
var inst = ds_map_find_value(global.Clients, sock );

if(cmd==POS_CMD)    
{
    inst.x = buffer_read(buff, buffer_s16);
    inst.y = buffer_read(buff, buffer_s16);
}

else if(cmd==INFO_CMD)
{
    inst.hspeed = buffer_read(buff, buffer_s16);
    inst.vspeed = buffer_read(buff, buffer_s16);
    inst.peed = buffer_read(buff, buffer_s16);
    inst.gun_equipped = buffer_read(buff, buffer_s16);
    inst.lookdir = buffer_read(buff, buffer_s16);
}