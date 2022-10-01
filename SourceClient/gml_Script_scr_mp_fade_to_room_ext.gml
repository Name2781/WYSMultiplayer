
if (variable_global_exists("isHost"))
{
    if (global.isHost)
    {
        var serverBuff = buffer_create(256, buffer_grow, 1);

        buffer_write(serverBuff, buffer_s16, 10);
        buffer_write(serverBuff, buffer_s16, argument0)
        buffer_write(serverBuff, buffer_s8, global.save_equipped_hat);
        buffer_write(serverBuff, buffer_s16, 0);

        for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
        {         
            network_send_packet(ds_list_find_value(global.socketlist, i), serverBuff, buffer_tell(serverBuff));
        }

        buffer_delete(serverBuff)
    }
    else
    {
        if (variable_global_exists("clientTCP"))
        {
            var serverBuff = buffer_create(256, buffer_grow, 1);

            buffer_write(serverBuff, buffer_s16, 10);
            buffer_write(serverBuff, buffer_s16, argument0)
            buffer_write(serverBuff, buffer_s8, global.save_equipped_hat);

            network_send_packet(global.clientTCP, serverBuff, buffer_get_size(serverBuff));

            buffer_delete(serverBuff)
        }
    }
}

// argument0

scr_fade_to_room_ext(argument0, argument1)