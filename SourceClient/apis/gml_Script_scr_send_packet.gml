var buff = buffer_create(256, buffer_grow, 1);

if (!is_undefined(argument0))
{
    if (!is_undefined(ds_list_find_value(global.custom_packets, argument0)))
    {
        scr_write_data(buff, ds_list_find_value(global.custom_packets, argument0))
    }
}

if (!is_undefined(argument1))
{
    scr_write_data(buff, argument1)
}

if (!is_undefined(argument2))
{
    scr_write_data(buff, argument2)
}

if (!is_undefined(argument3))
{
    scr_write_data(buff, argument3)
}

if (!is_undefined(argument4))
{
    scr_write_data(buff, argument4)
}

if (!is_undefined(argument5))
{
    scr_write_data(buff, argument5)
}

if (!is_undefined(argument6))
{
    scr_write_data(buff, argument6)
}

if (!is_undefined(argument7))
{
    scr_write_data(buff, argument7)
}

if (!is_undefined(argument8))
{
    scr_write_data(buff, argument8)
}

if (!is_undefined(argument9))
{
    scr_write_data(buff, argument9)
}

if (!is_undefined(argument10))
{
    scr_write_data(buff, argument10)
}

if (!is_undefined(argument11))
{
    scr_write_data(buff, argument11)
}

if (!is_undefined(argument12))
{
    scr_write_data(buff, argument12)
}

if (!is_undefined(argument13))
{
    scr_write_data(buff, argument13)
}

if (!is_undefined(argument14))
{
    scr_write_data(buff, argument14)
}

if (!is_undefined(argument15))
{
    scr_write_data(buff, argument15)
}

if (!is_undefined(argument16))
{
    scr_write_data(buff, argument16)
}