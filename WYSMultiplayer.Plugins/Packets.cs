using System.Net;
using System.Net.Sockets;
using Server.Types;
using System.Text;

namespace Networking
{
    public class Packets
    {
        public static void ResizeObject(GameObject obj, TcpClient client)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)12);
                writer.Write((short)4);
                writer.Write(obj.xscale);
                writer.Write(obj.yscale);
                writer.Write(obj.id);
            }

            client.GetStream().Write(message, 0, message.Length);
        }

        public static void MoveObject(GameObject obj, TcpClient client)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)12);
                writer.Write((short)2);
                writer.Write(obj.x);
                writer.Write(obj.y);
                writer.Write(obj.id);
            }

            client.GetStream().Write(message, 0, message.Length);
        }

        public static void RedrawWalls(TcpClient client)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)12);
                writer.Write((short)12);
            }

            client.GetStream().Write(message, 0, message.Length);
        }

        public static void RemoveObject(GameObject obj, TcpClient client)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)12);
                writer.Write((short)1);
                writer.Write(obj.id);
            }

            client.GetStream().Write(message, 0, message.Length);
        }

        private static async Task<int> GetId(TcpClient client)
        {
            Byte[] bytes = new Byte[268];  
            int i;
            int id = 0;

            NetworkStream stream = client.GetStream();
            while((i = stream.Read(bytes, 0, bytes.Length)) !=0)
            {
                Stream buffer = new MemoryStream(bytes[12..bytes.Length]);

                using (var reader = new BinaryReader(buffer, Encoding.Unicode, false))
                {   
                    switch (reader.ReadInt16())
                    {
                        case 12:
                            id = reader.ReadInt32();
                            return id;
                    }
                }
            }

            return id;
            // await Task.Run(() => );
        }

        public static int AddObject(string name, string layer, TcpClient client, int x, int y, float xscale, float yscale)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)12);
                writer.Write((short)0);
                writer.Write(Encoding.ASCII.GetBytes(name));
                writer.Write((byte)0);
                writer.Write(Encoding.ASCII.GetBytes(layer));
                writer.Write((byte)0);
                writer.Write(x);
                writer.Write(y);
                writer.Write(xscale);
                writer.Write(yscale);
            }

            client.GetStream().Write(message, 0, message.Length);

            var res = GetId(client);

            Task.WaitAll(res);

            int id = res.Result;

            return id;
        }

        public static void SendPlayerToRoom(string room, TcpClient client)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)12);
                writer.Write((short)7);
                writer.Write(Encoding.ASCII.GetBytes(room));
                writer.Write((byte)0);
            }

            client.GetStream().Write(message, 0, message.Length);
        }

        public static void DrawText(string text, int x, int y, int angle, float xscale, float yscale, float durration, TcpClient client)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)12);
                writer.Write((short)5);
                writer.Write(x);
                writer.Write(y);
                writer.Write(Encoding.ASCII.GetBytes(text));
                writer.Write((byte)0);
                writer.Write(xscale);
                writer.Write(yscale);
                writer.Write(angle);
                writer.Write(durration);
            }

            client.GetStream().Write(message, 0, message.Length);
        }

        public static void ClearText(TcpClient client)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)12);
                writer.Write((short)6);
            }

            client.GetStream().Write(message, 0, message.Length);
        }

        public static void playerJoinSequence(List<TcpClient> clients, TcpClient newPlayer, List<PlayerData> playerDatas)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)2);
                writer.Write((short)clients.IndexOf(newPlayer));
                writer.Write("");
                writer.Write(playerDatas[clients.IndexOf(newPlayer)].team);
            }

            foreach (TcpClient client in clients)
            {
                if (client.Equals(newPlayer))
                    continue;

                client.GetStream().Write(message, 0, message.Length);
            }

            foreach (TcpClient client in clients)
            {
                if (client.Equals(newPlayer))
                    continue;

                message = new byte[268];

                buffer = new MemoryStream(message);
            
                using (var writer = new BinaryWriter(buffer))
                {
                    writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                    writer.Write((short)4);
                    writer.Write((short)clients.IndexOf(client));
                    writer.Write(playerDatas[clients.IndexOf(client)].name);
                    writer.Write(playerDatas[clients.IndexOf(client)].team);
                }

                newPlayer.GetStream().Write(message, 0, message.Length);
            }

            message = new byte[268];

            buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)1);
                writer.Write((ushort)0); // EASY = 3, inf easy = 0
            }

            newPlayer.GetStream().Write(message, 0, message.Length);
        }

        public static void SendBasketballPacket(short bRoom, float nX, float nY, float nH, float nV, float nS, float nBX, float nBY, float nDir, List<TcpClient> clients, TcpClient player)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)7);
                writer.Write(bRoom);
                writer.Write(nX);
                writer.Write(nY);
                writer.Write(nH);
                writer.Write(nV);
                writer.Write(nS);
                writer.Write(nBX);
                writer.Write(nBY);
                writer.Write(nDir);
            }
            
            foreach (TcpClient client in clients)
            {
                if (client.Equals(player))
                    continue;

                client.GetStream().Write(message, 0, message.Length);
            }
        }

        public static void SendMovementPacket(int x, int y, float hspeed, float vspeed, float inputxy, byte inputjump, short room, bool isSpectator, List<TcpClient> clients, TcpClient newPlayer)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)0);
                writer.Write(x);
                writer.Write(y);
                writer.Write(hspeed);
                writer.Write(vspeed);
                writer.Write(inputxy);
                writer.Write(inputjump);
                writer.Write(room);
                writer.Write(isSpectator);
                writer.Write(clients.IndexOf(newPlayer));
            }

            foreach (TcpClient client in clients)
            {
                if (client.Equals(newPlayer))
                    continue;

                client.GetStream().Write(message, 0, message.Length);
            }
        }

        public static void SendPlayerNamePacket(byte[] name, List<TcpClient> clients, TcpClient socket)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)6);
                writer.Write((short)clients.IndexOf(socket));
                writer.Write(name);
            }

            foreach (TcpClient client in clients)
            {
                if (client.Equals(socket))
                    continue;

                client.GetStream().Write(message, 0, message.Length);
            }
        }

        public static void SendHatPacket(sbyte hat, List<TcpClient> clients, TcpClient socket)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)8);
                writer.Write(hat);
                writer.Write((short)clients.IndexOf(socket));
            }

            foreach (TcpClient client in clients)
            {
                if (client.Equals(socket))
                    continue;

                client.GetStream().Write(message, 0, message.Length);
            }
        }

        public static void SendRoomSyncPacket(short roomId, sbyte hatId, List<TcpClient> clients, TcpClient socket)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)10);
                writer.Write(roomId);
                writer.Write(hatId);
                writer.Write((short)clients.IndexOf(socket));
            }

            foreach (TcpClient client in clients)
            {
                if (client.Equals(socket))
                    continue;

                client.GetStream().Write(message, 0, message.Length);
            }
        }

        public static void SendHatQueryPacket(List<TcpClient> clients, TcpClient socket)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)11);
                writer.Write((short)clients.IndexOf(socket));
            }

            foreach (TcpClient client in clients)
            {
                if (client.Equals(socket))
                    continue;

                client.GetStream().Write(message, 0, message.Length);
            }
        }

        public static void SendRoomSyncPacket(short roomId, sbyte hatId, short target, List<TcpClient> clients, TcpClient socket)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)10);
                writer.Write(roomId);
                writer.Write(hatId);
                writer.Write((short)clients.IndexOf(socket));
            }

            clients[target].GetStream().Write(message, 0, message.Length);
        }

        public static void SendPlayerLeavePacket(List<TcpClient> clients, short socket)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)3);
                writer.Write(socket);
            }

            foreach (TcpClient client in clients)
            {
                client.GetStream().Write(message, 0, message.Length);
            }
        }

        public static void SendTeamPacket(PlayerData data, List<TcpClient> clients, TcpClient socket)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)9);
                writer.Write(data.team);
                writer.Write(data.hideTeam);
                writer.Write((short)clients.IndexOf(socket));
            }

            foreach (TcpClient client in clients)
            {
                if (client.Equals(socket))
                    continue;

                client.GetStream().Write(message, 0, message.Length);
            }
        }
    }
}