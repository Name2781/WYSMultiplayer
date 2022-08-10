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
            inst.x = buffer_read(buffer, buffer_s32);
            inst.y = buffer_read(buffer, buffer_s32);
	    	inst.hspeed = buffer_read(buffer, buffer_f32);
	    	inst.vspeed = buffer_read(buffer, buffer_f32);
	    	inst.inputxy = buffer_read(buffer, buffer_f32);
	    	inst.input_jump = buffer_read(buffer, buffer_u8);
	    	inst.room_id = buffer_read(buffer, buffer_u16);
            inst.isSpectator = buffer_read(buffer, buffer_bool);

            var serverBuff = buffer_create(256, buffer_grow, 1);

            buffer_seek(serverBuff, buffer_seek_start, 0);
            buffer_write(serverBuff, buffer_s16, 0);
            buffer_write(serverBuff, buffer_s32, inst.x);
            buffer_write(serverBuff, buffer_s32, inst.y);
	   	 	buffer_write(serverBuff, buffer_f32, inst.hspeed);
        	buffer_write(serverBuff, buffer_f32, inst.vspeed);
	    	buffer_write(serverBuff, buffer_f32, inst.inputxy); //input
	    	buffer_write(serverBuff, buffer_u8, inst.input_jump); //jumppressthing
	    	buffer_write(serverBuff, buffer_u16, inst.room_id); //room_id
            buffer_write(serverBuff, buffer_bool, inst.isSpectator);
            buffer_write(serverBuff, buffer_s16, socket);

            for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
            {
                network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
            }

            // buffer_delete(serverBuff);

            break;
        }

        var nX = buffer_read(buffer, buffer_s32);
        var nY = buffer_read(buffer, buffer_s32);
		var nH = buffer_read(buffer, buffer_f32);
		var nV = buffer_read(buffer, buffer_f32);
		
		var nIXY = buffer_read(buffer, buffer_f32);
		var nJ = buffer_read(buffer, buffer_u8);
		var room_id_to_set = buffer_read(buffer, buffer_u16);
        var isSpectator = buffer_read(buffer, buffer_bool);
        // var hat_id = buffer_read(buffer, buffer_u16);
        
        var socketId = buffer_read(buffer, buffer_s16);

        // show_debug_message(socketId)

        plr = ds_map_find_value(global.Clients, socketId);

        if (is_undefined(plr) || !instance_exists(plr)) {
            break;
        }

        if (!isSpectator)
        {
            plr.x = nX;
            plr.y = nY;
        } else {
            plr.x = 9999;
            plr.y = 9999;
        }

        // plr.x = nX;
        // plr.y = nY;
		
		plr.hspeed = nH;
        plr.vspeed = nV;
		
		plr.inputxy = nIXY;
		plr.input_jump = nJ;
		
		plr.room_id = room_id_to_set;
		
        break;
    
    case 1: // INFO_CMD
        // inst.gun_equipped = buffer_read(buffer, buffer_u8);

        break;

    case 2: // PLRJOIN_CMD
        var inst = instance_create_layer(0,0,"Player",obj_mp_player);

        var sId = buffer_read(buffer, buffer_s16);

        ds_map_add(global.Clients, sId, inst);

        break;

    case 3: // PLRLEAVE_CMD
        var sId = buffer_read(buffer, buffer_s16);

        plr = ds_map_find_value(global.Clients, sId);

        with(plr) { instance_destroy(); }

        ds_map_delete(global.Clients, sId);

        break;

    case 4: // NEWPLR_DATA
        var inst = instance_create_layer(0,0,"Player",obj_mp_player);

        var sId = buffer_read(buffer, buffer_s16);

        inst.name = buffer_read(buffer, buffer_string);
        // inst.isSpectator = buffer_read(buffer, buffer_u8);

        ds_map_add(global.Clients, sId, inst);

        break;

    case 5: // LEVEL_SELECT
        var level = buffer_read(buffer, buffer_s16);

        scr_fade_to_room(level);

        break;

    case 6: // PLR_NAME
        if (global.isHost) { 
            inst.name = buffer_read(buffer, buffer_string);

            var serverBuff = buffer_create(256, buffer_grow, 1);

            buffer_seek(serverBuff, buffer_seek_start, 0);
            buffer_write(serverBuff, buffer_s16, 6);
            buffer_write(serverBuff, buffer_s16, socket);
            buffer_write(serverBuff, buffer_string, inst.name);

            for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
            {
                network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
            }

            break;
        }

        var sId = buffer_read(buffer, buffer_s16);
        var plr = ds_map_find_value(global.Clients, sId);

        if (is_undefined(plr) || !instance_exists(plr)) {
            break;
        }

        var plrName = buffer_read(buffer, buffer_string);

        plr.name = plrName;

        break;

    default:
        // show_debug_message("Unknown packet");

        break;
}