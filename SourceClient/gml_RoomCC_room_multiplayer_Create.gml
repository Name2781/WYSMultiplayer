global.isReady = false;
global.state = "waiting";

if show_question("Host a game?") {
    global.isHost = true;

    port = get_integer("Enter the port: ", "696969");
    global.port = port

    var serverTCP = network_create_server(network_socket_tcp, port, 32);

    global.serverTCP = serverTCP;

    global.iteration = 0;

    global.isReady = true;

    global.state = "inGame";
} else {
    global.isHost = false;
    global.hostIp = get_string("Enter the hosts ip: ", "127.0.0.1");
    global.port = get_integer("Enter the port: ", "696969");
    global.name = get_string("Enter your name: ", "Player");

    var clientTCP = network_create_socket(network_socket_tcp);

    network_connect_async(clientTCP, global.hostIp, global.port);

    global.clientTCP = clientTCP;

    global.iteration = 0;

    global.isReady = true;

    global.state = "inGame";
}

var socketlist = ds_list_create();
var Clients = ds_map_create();

global.socketlist = socketlist;
global.Clients = Clients;