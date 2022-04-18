var xx,yy,i,t,top,left,s;

global.mapsize=floor(room_width/32)*floor(room_height/32);

// Loop through the tile map, and find the tiles, then place them 
// in the "simple" collision map.
for( yy=0;yy<room_height;yy+=32)
{
    s="";
    for( xx=0;xx<room_width;xx+=32)
    {
        i = (xx/32)+((yy/32)*(room_width/32));
        global.map[i]=-1;
        t = tile_layer_find(10,xx,yy);
        if( t>=0 )
        {
            s = s+"1";
            left = tile_get_left(t);
            global.map[i]=left/32;            
        }else
            s = s+"_";
    }
    show_debug_message(s);
}


