/// Adds a virtual key on platforms that need it....
var platform = os_type;

if( platform == os_macosx  || platform == os_windows || platform == os_linux){
    instance_destroy();
}else{
    virtual_key_add(x,y,sprite_get_width(sprite_index)*image_xscale,sprite_get_height(sprite_index)*image_yscale, argument0 );
}


