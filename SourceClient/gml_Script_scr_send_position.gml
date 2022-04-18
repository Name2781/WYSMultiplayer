var buff = buffer_create(256, buffer_grow, 1);

buffer_seek(buff, buffer_seek_start, 0);

buffer_write(buff, buffer_s16, POS_CMD);
buffer_write(buff, buffer_s16, argument0);
buffer_write(buff, buffer_s16, argument1);

network_send_packet(global.clientUDP, buff, buffer_tell(buff));

buffer_delete(buff);