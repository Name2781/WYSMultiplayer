if (ds_list_size(global.texts) == 0)
    return false;

for (var i = 0; i < ds_list_size(global.texts); ++i;)
{
    var dhold = ds_list_find_value(global.hold, i) - 1;
    ds_list_set(global.hold, i, dhold)

    if (dhold == -1)
    {
        buffer_delete(ds_list_find_value(global.datas, i))
        ds_list_delete(global.datas, i)
        ds_list_delete(global.hold, i)
        ds_list_delete(global.texts, i)

        exit;
    }

    var data = ds_list_find_value(global.datas, i)

    buffer_seek(data, buffer_seek_start, 0)

    var dx = buffer_read(data, buffer_s32)
    var dy = buffer_read(data, buffer_s32)
    var dxscale = buffer_read(data, buffer_f32)
    var dyscale = buffer_read(data, buffer_f32)
    var dangle = buffer_read(data, buffer_s32)
    var dstay = buffer_read(data, buffer_f32)

    draw_set_valign(fa_top);
    draw_set_halign(fa_left);

    var text = ds_list_find_value(global.texts, i)

    draw_text_transformed(dx, dy, ds_list_find_value(global.texts, i), dxscale, dyscale, dangle)
}