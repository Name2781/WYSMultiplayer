var buff = buffer_create(256, buffer_grow, 1);

buffer_seek(buff, buffer_seek_start, 0);

buffer_write(buff, buffer_s16, 0);
buffer_write(buff, buffer_s32, argument0); //x
buffer_write(buff, buffer_s32, argument1); //y
buffer_write(buff, buffer_f32, argument2); //hspeed
buffer_write(buff, buffer_f32, argument3); //vspeed
buffer_write(buff, buffer_f32, argument4); //inputxy
buffer_write(buff, buffer_u8, argument5); //inputjump
buffer_write(buff, buffer_u16, argument6); //room
buffer_write(buff, buffer_bool, argument7); // isSpectator
//dont send jump press cuz the client already handles that speed change.

network_send_packet(global.clientTCP, buff, buffer_get_size(buff));

buffer_delete(buff);