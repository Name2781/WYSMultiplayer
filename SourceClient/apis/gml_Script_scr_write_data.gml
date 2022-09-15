if (is_undefined(argument1) || is_undefined(argument0))
    return false;

if (is_string(argument1))
{
    buffer_write(argument0, buffer_string, argument1)
}

if (is_int32(argument1))
{
    buffer_write(argument0, buffer_s32, argument1)
}

if (is_int64(argument1))
{
    buffer_write(argument0, buffer_s64, argument1)
}