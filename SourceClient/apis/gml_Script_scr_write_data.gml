if (is_undefined(argument1) || is_undefined(argument0) || is_undefined(argument2))
    return false;

if (is_string(argument1))
{
    buffer_write(argument0, buffer_string, argument1)
    ds_list_add(argument2, 1)
}

if (is_int32(argument1))
{
    buffer_write(argument0, buffer_s32, argument1)
    ds_list_add(argument2, 2)
}

if (is_bool(argument1))
{
    buffer_write(argument0, buffer_bool, argument1)
    ds_list_add(argument2, 3)
}