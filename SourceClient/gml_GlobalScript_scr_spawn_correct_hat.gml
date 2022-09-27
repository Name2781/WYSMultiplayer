scr_spawn_correct_hat = function() //gml_Script_scr_spawn_correct_hat
{
    with (obj_hat_parent)
    {
        if (!dead)
        {
            if (object_index == obj_simple_hat)
            {
                with (obj_simple_hat)
                {
                    old = 1

                    if (playerHat)
                    {
                        dead = 1
                        powery = (13 + random(6))
                        angle = ((global.temporary_stuff - 40) + random(80))
                        xspeed = (random(6) - 3)
                        yspeed = -5
                    }
                }
            }

            if (object_index == obj_simple_hat_heart)
            {
                dead = 1
                powery = (13 + random(6))
                angle = ((global.temporary_stuff - 40) + random(80))
                xspeed = (random(6) - 3)
                yspeed = -5
                dramatic_death = 1
                yspeed = -8
                sound = audio_play_sound(sou_teleport_a, 0.85, false)
                audio_sound_gain_fx(sound, 0.4, 0)
                audio_sound_pitch(sound, 0.4)
            }
        }
    }
    switch global.save_equipped_hat
    {
        case 0:
            created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
            created_hat.sprite_index = spr_hat_cylinder
            break
        case 1:
            created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
            created_hat.sprite_index = spr_hat_shelly
            break
        case 3:
            created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat_rider)
            created_hat.sprite_index = spr_hat_human
            break
        case 2:
            created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
            created_hat.sprite_index = spr_hat_unicorn
            created_hat.glued_to_hat = 1
            break
        case 4:
            created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
            created_hat.sprite_index = spr_hat_winter
            break
        case 5:
            created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
            created_hat.sprite_index = spr_hat_squid
            created_hat.glued_to_hat = 1
            break
        case 6:
            created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat)
            created_hat.sprite_index = spr_hat_poopoo
            break
        case 7:
            created_hat = instance_create_layer(-200, -200, "Player_Eyes", obj_simple_hat_heart)
            break
    }

    return;
}

