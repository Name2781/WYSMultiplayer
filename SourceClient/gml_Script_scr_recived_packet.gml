buffer = argument0;
socket = argument1;
msgid = buffer_read(buffer, buffer_s16);

if (ds_map_size(global.Clients) == 0) {
    return false;
}

inst = ds_map_find_value(global.Clients, socket);

switch(msgid)
{
    case 0: // POS_CMD
        inst.x = buffer_read(buffer, buffer_s16);
        inst.y = buffer_read(buffer, buffer_s16);

        break;

    case 1: // INFO_CMD
        inst.hspeed = buffer_read(buffer, buffer_s16);
        inst.vspeed = buffer_read(buffer, buffer_s16);
        inst.speed = buffer_read(buffer, buffer_s16);
        inst.gun_equipped = buffer_read(buffer, buffer_s16);
        inst.lookdir = buffer_read(buffer, buffer_s16);

        break;
}