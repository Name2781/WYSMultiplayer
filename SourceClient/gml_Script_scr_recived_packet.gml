buffer = argument0;
socket = argument1;

msgid = buffer_read(buffer, buffer_s16);

if (ds_map_size(global.Clients) == 0 && global.isHost) {
    return false;
}

if (global.isHost) {
    inst = ds_map_find_value(global.Clients, socket);
}

switch(msgid)
{
    case 0: // POS_CMD
        if (global.isHost) { 
            inst.x = buffer_read(buffer, buffer_s16);
            inst.y = buffer_read(buffer, buffer_s16);

            var serverBuff = buffer_create(256, buffer_grow, 1);

            buffer_seek(serverBuff, buffer_seek_start, 0);
            buffer_write(serverBuff, buffer_s16, 0);
            buffer_write(serverBuff, buffer_s16, inst.x);
            buffer_write(serverBuff, buffer_s16, inst.y);
            buffer_write(serverBuff, buffer_s16, socket);

            for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
            {
                network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
            }

            buffer_delete(serverBuff);

            break;
        }

        var nX = buffer_read(buffer, buffer_s16);
        var nY = buffer_read(buffer, buffer_s16);
        var socketId = buffer_read(buffer, buffer_s16);

        // show_debug_message(socketId)

        plr = ds_map_find_value(global.Clients, socketId);

        if (is_undefined(plr)) {
            return false;
        }

        plr.x = nX;
        plr.y = nY;

        break;
    /*
    case 1: // INFO_CMD
        inst.hspeed = buffer_read(buffer, buffer_s16);
        inst.vspeed = buffer_read(buffer, buffer_s16);
        inst.speed = buffer_read(buffer, buffer_s16);
        inst.gun_equipped = buffer_read(buffer, buffer_s16);
        inst.lookdir = buffer_read(buffer, buffer_s16);

        break; */

    case 2: // PLRJOIN_CMD
        var inst = instance_create_layer(0,0,"Player",obj_mp_player);

        var sId = buffer_read(buffer, buffer_s16);

        show_debug_message(sId)

        // inst.sId = sId;

        ds_map_add(global.Clients, sId, inst);

        break;

    /* case 3: // PLRLEAVE_CMD
        var sId = buffer_read(buffer, buffer_s16);

        show_debug_message(sId)

        ds_map_remove(global.Clients, sId);

        break; */

    case 4: // NEWPLR_DATA
        var inst = instance_create_layer(0,0,"Player",obj_mp_player);

        var sId = buffer_read(buffer, buffer_s16);

        ds_map_add(global.Clients, sId, inst);

        break;

    default:
        // show_debug_message("Unknown packet");

        break;
}