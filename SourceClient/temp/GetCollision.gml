//
// argument0 = X coordinate to get tile (in pixels, not tiles)
// argument1 = Y coordinate to get tile (in pixels, not tiles)
//
if( argument0>=room_width ) return -1;
if( argument1>=room_height ) return -1;
if( argument0<0) return -1;
if( argument1<0) return -1;

var xx,yy;

xx = floor(argument0/32) + (floor(argument1/32) * floor(room_width/32));
if( global.mapsize<xx ) return -1;
return global.map[ xx ];

