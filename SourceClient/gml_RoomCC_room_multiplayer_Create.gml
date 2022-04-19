global.isReady = false;
global.state = "waiting";

if show_question("Host a game?") {
    global.isHost = true;

    port = get_integer("Enter the port: ", "696969");
    global.port = port

    global.serverTCP = network_create_server(network_socket_tcp, port, 32);
    global.serverUDP = network_create_server(network_socket_udp, port, 32);

    global.isReady = true;

    global.state = "inGame";
} else {
    global.isHost = false;
    global.hostIp = get_string("Enter the hosts ip: ", "127.0.0.1");
    global.port = get_integer("Enter the port: ", "696969");
    global.name = get_string("Enter your name: ", "Player");

    clientUDP = network_create_socket(network_socket_udp);
    clientTCP = network_create_socket(network_socket_tcp);

    network_connect(clientUDP, global.hostIp, global.port);
    network_connect(clientTCP, global.hostIp, global.port);

    global.clientUDP = clientUDP;
    global.clientTCP = clientTCP;

    global.isReady = true;

    global.state = "inGame";
}

var socketlist = ds_map_create();
var Clients = ds_map_create();

global.socketlist = socketlist;
global.Clients = Clients;