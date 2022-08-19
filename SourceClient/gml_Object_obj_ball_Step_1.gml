if (x > 0)
{
    global.ball_time_since_touching_sb += 1
    global.ball_distance_since_touching_sb += point_distance(x, y, ballx_prev2, bally_prev2)
}
vspeed += 0.2
bouncefactor = 0.7
bouncefactorother = 0.95
sound_cooldown--
caught_ball_timer--
if (caught_ball_timer <= 0)
    scale = min(1, (scale + 0.005))
if global.underwater
{
    speed *= 0.99
    vspeed -= 0.18
}
if place_meeting(x, y, obj_player)
{
    if (caught_ball_timer <= 0)
    {
        speed_before = speed
        hspeed_before = hspeed
        vspeed_before = vspeed
        selfx = ballx_prev1
        selfy = bally_prev1
        playx = obj_player.xlast
        playy = obj_player.ylast
        speed = 10
        direction = point_direction(playx, playy, selfx, selfy)
        hspeed += obj_player.hspeed
        vspeed += obj_player.vspeed
        speed *= 0.6

        if (speed_before > speed && global.ball_time_since_touching_sb <= 20 && global.ball_last_touched_entity_was == 1)
        {
            hspeed = hspeed_before
            vspeed = vspeed_before
        }
        else
        {
            while (place_meeting(x, y, obj_player) && place_free((x + (hspeed * 0.5)), (y + (hspeed * 0.5))))
            {
                x += (hspeed * 0.5)
                y += (vspeed * 0.5)
            }
            if (sound_cooldown <= 0)
            {
                sound = audio_play_sound_at(choose(37, 38, 39), x, y, 100, 200, 1000, 1, false, 0.6)
                audio_sound_gain_fx(sound, clamp((speed / 13), 0, 1), 0)
                audio_sound_pitch(sound, (0.3 + (speed * 0.02)))
                sound_cooldown = 5
            }
        }
        global.ball_last_touched_entity_was = 1
        global.ball_distance_since_touching_sb = 0
        global.ball_time_since_touching_sb = 0
        if (global.save_equipped_hat == 2)
        {
            if place_meeting(x, y, obj_hat_parent)
            {
                event_user(0)
                if (!(aivl_play("hat_unicorn_ball_01", 3)))
                    aivl_play_ext("hat_unicorn_ball_02", -1, -1, 3, 0, 1)
            }
        }
    }

    var buff = buffer_create(256, buffer_grow, 1);

    buffer_seek(buff, buffer_seek_start, 0);

    buffer_write(buff, buffer_s16, 7);
    buffer_write(buff, buffer_u16, room);
    buffer_write(buff, buffer_f32, x);
    buffer_write(buff, buffer_f32, y);
    buffer_write(buff, buffer_f32, hspeed);
    buffer_write(buff, buffer_f32, vspeed);
    buffer_write(buff, buffer_f32, speed);
    buffer_write(buff, buffer_s32, ballx_prev1);
    buffer_write(buff, buffer_s32, bally_prev1);
    buffer_write(buff, buffer_s32, direction);

    if (global.isHost) {
        for (var i = 0; i < ds_list_size(global.socketlist); ++i;)
        {
            network_send_packet(ds_list_find_value(global.socketlist, i), buff, buffer_tell(buff));
        }
    } else {
        network_send_packet(global.clientTCP, buff, buffer_get_size(buff));
    }

    buffer_delete(buff);
}
if place_meeting(x, y, obj_basketboss)
{
    if (caught_ball_timer <= 0)
    {
        global.ball_last_touched_entity_was = -1
        global.ball_distance_since_touching_sb = 0
        global.ball_time_since_touching_sb = 0
        speed = 10
        direction = point_direction(obj_basketboss.x, obj_basketboss.y, x, y)
        vspee = min(obj_basketboss.vspeed, -1)
        hspeed += (vspee - ((5 + random(2)) * real(x < obj_basketboss.x)))
        vspeed += vspee
        speed *= 0.6
        while (place_meeting(x, y, obj_basketboss) && place_free((x + (hspeed * 0.5)), (y + (hspeed * 0.5))))
        {
            x += (hspeed * 0.5)
            y += (vspeed * 0.5)
        }
        if (sound_cooldown <= 0)
        {
            sound = audio_play_sound_at(choose(37, 38, 39), x, y, 100, 200, 1000, 1, false, 0.6)
            audio_sound_gain_fx(sound, clamp((speed / 13), 0, 1), 0)
            audio_sound_pitch(sound, (0.3 + (speed * 0.02)))
            sound_cooldown = 5
        }
    }
}
if (x > -500)
{
    if (x < 50)
    {
        x = 50
        hspeed = 5
    }
    if (y < 50)
    {
        y = 50
        vspeed = 5
    }
    if (x > (room_width - 50))
    {
        x = (room_width - 50)
        hspeed = -5
    }
    if (y > (room_height - 50))
    {
        y = (room_height - 50)
        vspeed = -5
    }
}
bounced = 0
if (place_free(x, y) == 0)
{
    x = xprevious
    y = yprevious
}
if (place_free((x + hspeed), y) == 0)
{
    if (hspeed > 0)
        move_contact_solid(0, -1)
    else
        move_contact_solid(180, -1)
    hspeed *= (-bouncefactor)
    vspeed *= bouncefactorother
    if hyperpowered
        hspeed += (10 * sign(hspeed))
    bounced = 1
}
if (place_free(x, (y + vspeed)) == 0)
{
    if (vspeed > 0)
        move_contact_solid(270, -1)
    else
        move_contact_solid(90, -1)
    vspeed *= (-bouncefactor)
    hspeed *= bouncefactorother
    if hyperpowered
        vspeed += (10 * sign(vspeed))
    bounced = 1
}
if (place_free((x + hspeed), (y + vspeed)) == 0)
{
    hspeed *= (-bouncefactor)
    vspeed *= bouncefactorother
    bounced = 1
}
if bounced
{
    if (speed > 1)
    {
        sound = audio_play_sound_at(choose(37, 38, 39), x, y, 200, 300, 1000, 0.5, false, 0.4)
        audio_sound_gain_fx(sound, clamp((speed / 13), 0, 1), 0)
        audio_sound_pitch(sound, (1.3 + (speed * 0.02)))
    }
}
if bounced
{
    if place_meeting(x, y, obj_tiny_spikes_player)
    {
        playervictory = 1
        event_user(0)
    }
    if place_meeting(x, y, obj_tiny_spikes)
        event_user(0)
}
if (abs(vspeed) < 0.2)
{
    if (!(place_free(x, (y + 2))))
    {
        move_contact_solid(270, -1)
        vspeed = 0
    }
}
if (vspeed < 0)
    highesty = y
scr_autowhobble_update()
