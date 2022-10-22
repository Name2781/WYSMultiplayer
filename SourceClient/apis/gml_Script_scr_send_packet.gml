var buff = buffer_create(256, buffer_grow, 1);
var buffReal = buffer_create(256, buffer_grow, 1);
var types = ds_list_create();

if (!is_undefined(argument0))
{
    if (!is_undefined(ds_list_find_value(global.custom_packets, argument0)))
    {
        buffer_write(buffReal, buffer_s16, ds_list_find_value(global.custom_packets, argument0))
        // scr_write_data(buff, ds_list_find_value(global.custom_packets, argument0), types)
    }
}

if (!is_undefined(argument1))
{
    scr_write_data(buff, argument1, types)
}

if (!is_undefined(argument2))
{
    scr_write_data(buff, argument2, types)
}

if (!is_undefined(argument3))
{
    scr_write_data(buff, argument3, types)
}

if (!is_undefined(argument4))
{
    scr_write_data(buff, argument4, types)
}

if (!is_undefined(argument5))
{
    scr_write_data(buff, argument5, types)
}

if (!is_undefined(argument6))
{
    scr_write_data(buff, argument6, types)
}

if (!is_undefined(argument7))
{
    scr_write_data(buff, argument7, types)
}

if (!is_undefined(argument8))
{
    scr_write_data(buff, argument8, types)
}

if (!is_undefined(argument9))
{
    scr_write_data(buff, argument9, types)
}

if (!is_undefined(argument10))
{
    scr_write_data(buff, argument10, types)
}

if (!is_undefined(argument11))
{
    scr_write_data(buff, argument11, types)
}

if (!is_undefined(argument12))
{
    scr_write_data(buff, argument12, types)
}

if (!is_undefined(argument13))
{
    scr_write_data(buff, argument13, types)
}

if (!is_undefined(argument14))
{
    scr_write_data(buff, argument14, types)
}

if (!is_undefined(argument15))
{
    scr_write_data(buff, argument15, types)
}

buffer_write(buffReal, buffer_s16, ds_list_size(types))

for (var i = 0; i > ds_list_size(types); ++i;)
{
    buffer_write(buffReal, buffer_s16, ds_list_find_value(types, i))
}

buffer_copy(buff, 0, 256, buffReal, buffer_tell(buffReal))