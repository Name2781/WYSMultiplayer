using System.Text;
using System.Net.Sockets;
using System.Net;

namespace MP;

public static class BinaryReaderExtension
{
    public static byte[] ReadGMString(this BinaryReader reader)
    {
        List<byte> rstring = new List<byte>();
        byte nB;
        
        while ((nB = reader.ReadByte()) != (byte)0)
        {
            rstring.Add(nB);
        }

        return (byte[])rstring.ToArray();
    }
}