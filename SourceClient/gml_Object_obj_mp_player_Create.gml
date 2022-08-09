gun_equipped = 0
lookdir = 1
eye1 = instance_create_layer(x, y, "Player_Eyes", obj_snaili_eye)
eye1.eye = 1
eye1.custom_player = id
eye1.persistent = true
eye2 = instance_create_layer(x, y, "Player_Eyes", obj_snaili_eye)
eye2.eye = 2
eye2.persistent = true
eye2.custom_player = id
house_height = 1
house_width = 1
house_tilt = 0
lockmovement = 40
room_id = room
isSpectator = false
col_snail_outline = 0
col_snail_body = 0
col_snail_shell = 0
col_snail_eye = 0
inputxy = 0
input_jump = 0
name = ""
if instance_exists(obj_levelstyler)
{
    if variable_instance_exists(obj_levelstyler.id, "col_snail_body")
        event_user(0)
}

scr_move_like_a_snail_ini()