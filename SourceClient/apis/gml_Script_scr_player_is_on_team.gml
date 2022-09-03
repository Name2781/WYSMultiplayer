if (ds_map_size(global.Clients) == 0) {
    return false;
}

var plr = ds_map_find_value(global.Clients, argument0)

if (is_undefined(plr))
    return false;

if(!variable_global_exists("clientTCP"))
    return false;

if (plr.team == argument1)
    return true;
else
    return false;