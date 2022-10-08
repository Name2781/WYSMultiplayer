using System.Net;
using System.Net.Sockets;
using System.Text;
using Server.Types;

class WYSMPServer
{
    static List<TcpClient> clients = new List<TcpClient>();
    static List<PlayerData> playerDatas = new List<PlayerData>();

    public static void Main()
    {
        TcpListener server=null;

        try
        {
            TcpListener listener = new TcpListener(IPAddress.Any , 25565);
            TcpClient client;
            listener.Start();

            Console.WriteLine($"Server started on port 25565");

            while (true)
            {
                client = listener.AcceptTcpClient();
                clients.Add(client);
                ThreadPool.QueueUserWorkItem(ClientThread, client);

                Console.WriteLine("New client connected");
            }
        }
        catch(SocketException e)
        {
            Console.WriteLine("SocketException: {0}", e);
        }
        finally
        {
            server.Stop();
        }

        Console.WriteLine("\nHit enter to continue...");
        Console.Read();
    }

    private static void ClientThread(object obj)
    {
        var client = (TcpClient)obj;

        try
        {
            Byte[] bytes = new Byte[268];  

            PlayerData plrData = new PlayerData();

            plrData.team = new Byte[0];
            plrData.teamName = new Byte[0];

            playerDatas.Add(plrData);

            NetworkStream stream = client.GetStream();

            Networking.Packets.playerJoinSequence(clients, client, playerDatas);

            int i;

            while((i = stream.Read(bytes, 0, bytes.Length))!=0)
            {
                int x = int.MaxValue;
                int y = int.MaxValue;
                float hspeed = float.MaxValue;
                float vspeed = float.MaxValue;
                float inputxy = float.MaxValue;
                byte inputjump = byte.MaxValue;
                short packetId = short.MaxValue;
                short room = short.MaxValue;
                bool isSpectator = false;
                short bRoom = short.MaxValue;
                float nX = float.MaxValue;
                float nY = float.MaxValue;
                float nH = float.MaxValue;
                float nV = float.MaxValue;
                float nS = float.MaxValue;
                float nBX = float.MaxValue;
                float nBY = float.MaxValue;
                float nDir = float.MaxValue;

                Stream buffer = new MemoryStream(bytes[12..bytes.Length]); // why does gm add 12 garbage bytes idk but fuck them for it

                using (var reader = new BinaryReader(buffer, Encoding.Unicode, false))
                {   
                    packetId = reader.ReadInt16();

                    switch (packetId)
                    {
                        case 0:
                            x = reader.ReadInt32();
                            y = reader.ReadInt32();
                            hspeed = reader.ReadSingle(); // nice naming microsoft
                            vspeed = reader.ReadSingle();
                            inputxy = reader.ReadSingle();
                            inputjump = reader.ReadByte();
                            room = reader.ReadInt16();
                            isSpectator = reader.ReadBoolean();
                            break;

                        case 6:
                            plrData.name = reader.ReadBytes(242);
                            break;

                        case 7:
                            bRoom = reader.ReadInt16();
                            nX = reader.ReadSingle();
                            nY = reader.ReadSingle();
                            nH = reader.ReadSingle();
                            nV = reader.ReadSingle();
                            nS = reader.ReadSingle();
                            nBX = reader.ReadSingle();
                            nBY = reader.ReadSingle();
                            nDir = reader.ReadSingle();
                            break;
                    }
                }

                if (packetId != -16162)
                {
                    switch (packetId)
                    {
                        case 0:
                            Networking.Packets.SendMovementPacket(x, y, hspeed, vspeed, inputxy, inputjump, room, isSpectator, clients, client);
                            break;

                        case 6:
                            Networking.Packets.SendPlayerNamePacket(plrData.name, clients, client);
                            break;

                        case 7:
                            Networking.Packets.SendBasketballPacket(bRoom, nX, nY, nH, nV, nS, nBX, nBY, nDir, clients, client);
                            break;

                        default:
                            Console.WriteLine($"unknown packet, id: {packetId}");
                            break;
                    }
                }
            } 
            
            client.Close();
        }
        catch
        {
            Console.WriteLine("Disconnecing a client due to an error or them leaving");
            client.Close();
        }
    }
}