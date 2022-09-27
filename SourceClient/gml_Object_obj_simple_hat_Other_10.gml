var play_objc = undefined;

if (instance_exists(obj_player) && !variable_instance_exists(id,"custom_player"))
{
    play_objc = obj_player
}

playerHat = 0

hatId = 0

old = 0

global.killHat = id

if (variable_global_exists("isHost"))
{
    if (play_objc == obj_player)
        playerHat = 1
}

if (variable_instance_exists(id,"custom_player"))
{
	play_objc = custom_player
    playerHat = 0
    if (!instance_exists(custom_player))
    {
        instance_destroy()
    }
}

visible = play_objc.visible

if victory
{
    if (play_objc.x < 60)
        x -= 10
    if (play_objc.y < 60)
        y -= 10
    if (play_objc.x > (room_width - 60))
        x += 10
    if (play_objc.y > (room_height - 60))
        y += 10
}
else if dead
{
    yspeed += 0.4
    x += xspeed
    y += yspeed
    image_angle += sign(image_angle)
}
else if (backpack_mode >= 0)
{
    backpack_mode--
    hat_anchor_x = ((play_objc.x - (26 * play_objc.lookdir)) + lengthdir_x((20 * play_objc.house_height), (90 + play_objc.house_tilt)))
    hat_anchor_y = ((play_objc.y + 16) + lengthdir_y((20 * play_objc.house_height), (90 + play_objc.house_tilt)))
    x = hat_anchor_x
    y = hat_anchor_y
    image_angle = (play_objc.house_tilt + 90)
    image_xscale = clamp((1 + ((y - yprevious) * 0.01)), 0.5, 2)
    image_yscale = (play_objc.lookdir / image_xscale)
    xspeed = 0
    yspeed = 0
}
else
{
    if global.underwater
    {
        smooth_lookdir = lerp(smooth_lookdir, play_objc.lookdir, 0.1)
        yspeed += 0.48
    }
    else
    {
        smooth_lookdir = lerp(smooth_lookdir, play_objc.lookdir, 0.25)
        yspeed += 0.98
    }
    hat_anchor_x = ((play_objc.x - (15 * smooth_lookdir)) + lengthdir_x((39 * play_objc.house_height), (90 + play_objc.house_tilt)))
    hat_anchor_y = ((play_objc.y + 16) + lengthdir_y((39 * play_objc.house_height), (90 + play_objc.house_tilt)))
    x = hat_anchor_x
    xspeed = play_objc.hspeed
    if glued_to_hat
        y = hat_anchor_y
    else
    {
        y += yspeed
        if (y > hat_anchor_y)
        {
            yspeed = min(yspeed, max(-10, play_objc.vspeed))
            y = hat_anchor_y
        }
        else
            y = lerp(hat_anchor_y, y, 0.9)
    }
    image_angle = play_objc.house_tilt
    image_yscale = clamp((1 + ((y - yprevious) * 0.01)), 0.5, 2)
    image_xscale = (play_objc.lookdir / image_yscale)
}
if global.underwater
{
    yspeed *= 0.9
    xspeed *= 0.95
}