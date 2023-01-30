show_debug_message( "--------------------------------------------------------------");
show_debug_message( "Unhandled exception " + string(argument0) );
show_debug_message( "--------------------------------------------------------------");

if file_exists("packet.bin") file_delete("packet.bin")
if file_exists("wysmpcrash.txt") file_delete("wysmpcrash.txt")

buffer_save(global.currentPacketData, "packet.bin");
var log = file_text_open_append("wysmpcrash.txt");

for (var i = 0; i < ds_list_size(global.lastPackets); ++i;)
{
    file_text_write_string(log, "Packet " + string(ds_list_find_value(global.lastPackets, i)) + "\n")
}

file_text_write_string(log, "\n\n" + string(global.currentPacketData) + "\n\n")
file_text_write_string(log, variable_struct_get(argument0, "longMessage"))
file_text_close(log);

show_message(variable_struct_get(argument0, "longMessage"));

return 0;