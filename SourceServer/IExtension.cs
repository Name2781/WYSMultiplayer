namespace MP.Extensions;

using System.Net.Sockets;

public interface IExtension
{
    public string id { get; }

    public void Load();

    public bool? OnPacket(int id, byte[] data, TcpClient incoming , List<TcpClient> clients);

    public Func<int, byte[], TcpClient, List<TcpClient>, bool?> GetOnPacket();
}