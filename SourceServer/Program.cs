using System.Net;
using System.Net.Sockets;
using System.Text;
using Server.Types;
using Server;
using MP.Extensions;
using MP;

class WYSMPServer
{
    public static ExtensionLoader extensionLoader = null;
    public static int nextClientId = 0;
    static List<TcpClient> clients = new List<TcpClient>();
    static List<PlayerData> playerDatas = new List<PlayerData>();
    public static bool useNext = false;

    public static void Main()
    {
        TcpListener server=null;

        extensionLoader = new ExtensionLoader("plugins");

        try
        {
            TcpListener listener = new TcpListener(IPAddress.Any , 25565);
            TcpClient client;
            listener.Start();

            Logger.Log($"Server started on port 25565");

            Thread.Sleep(100); 

            while (true)
            {
                client = listener.AcceptTcpClient();

                if (useNext)
                {
                    clients.Insert(nextClientId, client);
                }
                else
                {
                    clients.Add(client);
                }

                ThreadPool.QueueUserWorkItem(ClientThread, client);

                Logger.Log("New client connected");
            }
        }
        catch(SocketException e)
        {
            Logger.Log($"SocketException: {e}", Logger.LogLevel.Error);
        }
        finally
        {
            server.Stop();
        }

        Logger.Log("\nHit enter to continue...");
        Console.Read();
    }

    private static void ClientThread(object obj)
    {
        var client = (TcpClient)obj;

        PlayerData plrData = new PlayerData();

        try
        {
            Byte[] bytes = new Byte[268];  

            plrData.team = new Byte[0];
            plrData.teamName = new Byte[0];

            if (useNext)
            {
                playerDatas.Insert(WYSMPServer.nextClientId, plrData);
                useNext = false;
            }
            else
            {
                playerDatas.Add(plrData);
            }

            NetworkStream stream = client.GetStream();

            Networking.Packets.playerJoinSequence(clients, client, playerDatas);

            int i;

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
            sbyte hat = sbyte.MaxValue;
            short roomId = short.MaxValue;
            sbyte hatId = sbyte.MaxValue;
            short target = short.MaxValue;
            bool skip = false;
            bool cancelled = false;

            while((i = stream.Read(bytes, 0, bytes.Length)) !=0)
            {
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
                            /*
                            List<byte> name = new List<byte>();
                            byte nB;
                            
                            while ((nB = reader.ReadByte()) != (byte)0)
                            {
                                name.Add(nB);
                            }

                            plrData.name = (byte[])name.ToArray(); */
                            plrData.name = reader.ReadGMString();
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

                        case 8:
                            hat = (sbyte)reader.ReadByte(); // please work
                            break;

                        case 9:
                            // plrData
                            break;

                        case 10:
                            roomId = reader.ReadInt16();
                            hatId = (sbyte)reader.ReadByte();
                            break;

                        case 11:
                            roomId = reader.ReadInt16();
                            hatId = (sbyte)reader.ReadByte();
                            target = reader.ReadInt16();
                            skip = reader.ReadBoolean();
                            break;
                    }
                }

                foreach(Func<int, byte[], TcpClient, List<TcpClient>, bool?> onPacket in extensionLoader.onPacket)
                {
                    bool? cancel = onPacket(packetId, bytes[14..bytes.Length], client, clients);

                    if (cancel != null)
                    {
                        cancelled = (bool)cancel;
                    }
                }

                if (packetId != -16162 && !cancelled)
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

                        case 8:
                            Networking.Packets.SendHatPacket(hat, clients, client);
                            break;

                        case 9:

                            break;

                        case 10:
                            Networking.Packets.SendRoomSyncPacket(roomId, hatId, clients, client);
                            Networking.Packets.SendHatQueryPacket(clients, client);
                            break;

                        case 11:
                            if (skip)
                                break;

                            Networking.Packets.SendRoomSyncPacket(roomId, hatId, target, clients, client);
                            break;

                        case 12:
                            break;

                        default:
                            Logger.Log($"unknown packet, id: {packetId}", Logger.LogLevel.Warn);
                            break;
                    }
                }
            } 

            client.Close();
        }
        catch
        {
            Logger.Log("Disconnecing a client due to an error or them leaving");
            WYSMPServer.nextClientId = clients.IndexOf(client);
            useNext = true;
			
			foreach(Func<int, byte[], TcpClient, List<TcpClient>, bool?> onPacket in extensionLoader.onPacket)
			{
				onPacket(-1, new byte[0], client, clients);
			}
			
            clients.Remove(client);
            playerDatas.Remove(plrData);
            client.Close();

            Networking.Packets.SendPlayerLeavePacket(clients, (short)WYSMPServer.nextClientId);
        }
    }
}
