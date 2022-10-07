using System.Net;
using System.Net.Sockets;
using System.Text;

class WYSMPServer
{
    public static void Main()
    {
        TcpListener server=null;
        List<TcpClient> clients = new List<TcpClient>();

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
                ThreadPool.QueueUserWorkItem(ClientTread, client);

                Console.WriteLine("New client connected");
            }
        }
        catch(SocketException e)
        {
            Console.WriteLine("SocketException: {0}", e);
        }
        finally
        {
            // Stop listening for new clients.
            server.Stop();
        }

        Console.WriteLine("\nHit enter to continue...");
        Console.Read();
    }

    private static void ClientTread(object obj)
    {
        var client = (TcpClient)obj;

        try
        {
            Byte[] bytes = new Byte[268];  

            // Get a stream object for reading and writing
            NetworkStream stream = client.GetStream();

            int i;

            // Loop to receive all the data sent by the client.
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

                Stream buffer = new MemoryStream(bytes[12..bytes.Length]); // why does gm add 12 garbage bytes idk but fuck them for it

                using (var reader = new BinaryReader(buffer, Encoding.Unicode, false))
                {   
                    packetId = reader.ReadInt16();

                    if (packetId == 0)
                    {
                        x = reader.ReadInt32();
                        y = reader.ReadInt32();
                        hspeed = reader.ReadSingle(); // nice naming microsoft
                        vspeed = reader.ReadSingle();
                        inputxy = reader.ReadSingle();
                        inputjump = reader.ReadByte();
                        room = reader.ReadInt16();
                        isSpectator = reader.ReadBoolean();
                    }
                }
        
                if (packetId != -16162)
                {
                    if (packetId == 0)
                    {
                        Console.WriteLine($"id: {packetId} x: {x} y: {y} hspeed: {hspeed} vspeed: {vspeed} inputxy: {inputxy} inputjump: {inputjump} packetId: {packetId} room: {room} isSpectator: {isSpectator}");
                    }
                    else
                    {
                        Console.WriteLine($"id: {packetId}");
                    }
                }
            } 
            // Console.WriteLine("Received: {0}", String.Join(" ", bytes));

            // Process the data sent by the client.
            // data = data.ToUpper();

            // byte[] msg = System.Text.Encoding.ASCII.GetBytes();

            // Send back a response.
            // stream.Write(msg, 0, msg.Length);
            // Console.WriteLine("Sent: {0}", data);

            // Shutdown and end connection
            client.Close();
        }
        catch
        {
            Console.WriteLine("Disconnecing a client due to an error or them leaving");
            client.Close();
        }
    }
}