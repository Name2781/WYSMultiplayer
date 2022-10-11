using System.Net;
using System.Net.Sockets;
using Server.Types;

namespace Networking
{
    public class Packets
    {
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

        public static void SendPlayerLeavePacket(List<TcpClient> clients, TcpClient socket)
        {
            byte[] message = new byte[268];

            Stream buffer = new MemoryStream(message);

            using (var writer = new BinaryWriter(buffer))
            {
                writer.Write(new byte[] {222, 192, 173, 222, 12, 0, 0, 0, 0, 1, 0, 0});
                writer.Write((short)3);
                writer.Write((short)clients.IndexOf(socket));
            }

            foreach (TcpClient client in clients)
            {
                if (client.Equals(socket))
                    continue;

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