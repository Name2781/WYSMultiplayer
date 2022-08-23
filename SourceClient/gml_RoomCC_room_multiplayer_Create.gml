global.isReady = false;
global.state = "waiting";
global.spectating = 0;
global.oldDifficulty = 0;
global.oldHatId = 0;

if(variable_global_exists("isHost"))
    return false;

if show_question("Host a game?") {
    global.isHost = true;

    port = get_integer("Enter the port: ", "25565");
    global.port = port

    global.name = get_string("Enter your name: ", "Player");

    global.isSpectator = show_question("Spectate?");

    serverTCP = network_create_server(network_socket_tcp, port, 32);

    global.serverTCP = serverTCP;

    global.iteration = 0;

    global.isReady = true;

    global.state = "inGame";
} else {
    global.isHost = false;
    global.hostIp = get_string("Enter the hosts ip: ", "127.0.0.1");
    global.port = get_integer("Enter the port: ", "25565");
    global.name = get_string("Enter your name: ", "Player");
    global.isSpectator = show_question("Spectate?");

    if (global.isSpectator)
        obj_player.visible = false;

    clientTCP = network_create_socket(network_socket_tcp);

    network_connect(clientTCP, global.hostIp, global.port);

    var cBuff = buffer_create(256, buffer_grow, 1);

    buffer_seek(cBuff, buffer_seek_start, 0);
    buffer_write(cBuff, buffer_s16, 6);
    buffer_write(cBuff, buffer_string, global.name);

    network_send_packet(clientTCP, cBuff, buffer_tell(cBuff))

    buffer_delete(cBuff);

    global.clientTCP = clientTCP;

    global.iteration = 0;

    global.isReady = true;

    global.state = "inGame";
}

var socketlist = ds_list_create();
var Clients = ds_map_create();

global.socketlist = socketlist;
global.Clients = Clients;