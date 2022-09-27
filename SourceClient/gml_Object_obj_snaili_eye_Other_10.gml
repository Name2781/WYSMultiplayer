var play_objc = undefined

if (instance_exists(obj_player) && !variable_instance_exists(id,"custom_player"))
{
    play_objc = obj_player
}

if (variable_instance_exists(id,"custom_player"))
{
	play_objc = custom_player
	if (!instance_exists(custom_player))
	{
		instance_destroy()
	}
}

if (!instance_exists(play_objc))
{
	return false;
}

visible = play_objc.visible
yconnection = (play_objc.y + 15)
if (eye == 1)
{
	ytarget = (play_objc.y - 16)
	xtarget = (play_objc.x + (8 * (play_objc.lookdir > 0 ? 1 : -1)))
	time += 1
}
else
{
	ytarget = (play_objc.y - 14)
	xtarget = (play_objc.x + (20 * (play_objc.lookdir > 0 ? 1 : -1)))
	time += 1.15
}
xconnection = xtarget
eye_wind_lerpsi = lerp(eye_wind_lerpsi, min((play_objc.speed / 10), 1), 0.1)
lerpspeedmulti = 1
if global.underwater
{
	lerpspeedmulti = 0.5
	xtarget += lengthdir_x((3 * eye_wind_lerpsi), (time * 12))
	ytarget += lengthdir_y((4 * eye_wind_lerpsi), (time * 9.5))
	ytarget += lengthdir_y(4, (time * 1.6))
}
else
{
	xtarget += lengthdir_x((3 * eye_wind_lerpsi), (time * 24))
	ytarget += lengthdir_y((4 * eye_wind_lerpsi), (time * 19))
	ytarget += lengthdir_y(4, (time * 2.2))
}
if (eye == 1)
{
	x = lerp(x, xtarget, (0.35 * lerpspeedmulti))
	y = lerp(y, ytarget, (0.35 * lerpspeedmulti))
}
else
{
	x = lerp(x, xtarget, (0.4 * lerpspeedmulti))
	y = lerp(y, ytarget, (0.4 * lerpspeedmulti))
}
look_lerp_x = lerp(look_lerp_x, play_objc.lookdir, 0.1)
look_lerp_y = lerp(look_lerp_y, clamp((-play_objc.vspeed), 0, 1), 0.2)
dist = point_distance(x, y, xconnection, yconnection)
dir = point_direction(xconnection, yconnection, x, y)
