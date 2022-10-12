namespace MP.Extensions;

using System.Net.Sockets;
using System.Reflection;

class ExtensionLoader
{
    public Dictionary<String, IExtension> extensions = new Dictionary<String, IExtension>();
    public List<Func<int, byte[], TcpClient, List<TcpClient>, bool>> onPacket = new List<Func<int, byte[], TcpClient, List<TcpClient>, bool>>();

    public ExtensionLoader(String extPath)
    {
        if (!Directory.Exists(extPath))
            Directory.CreateDirectory(extPath);

        try
        {
            var exts = Directory.EnumerateFiles(extPath, "*.dll");

            foreach (string extension in exts)
            {
                Assembly assembly = Assembly.LoadFrom(extension);

                Type extClass = assembly.GetTypes()
                    .FirstOrDefault(extType => extType.GetInterfaces().Contains(typeof(IExtension)));
                
                if(extClass is null) {
                    Console.WriteLine($"File {extension} isnt setup properly! Skipping");
                    continue;
                }
                
                IExtension ext = (IExtension)Activator.CreateInstance(extClass);
                if (ext != null)
                {
                    ext.Load();
                    extensions.Add(ext.id, ext);

                    if (ext.GetOnPacket() != null)
                    {
                        onPacket.Add(ext.GetOnPacket());
                    }

                    Console.WriteLine($"Loaded mod {ext.id}");
                }
                else
                {
                    Console.WriteLine($"File {extension} is not a extension! Skipping");
                }
            }
        }
        catch (Exception e)
        {
            Console.WriteLine(e); // we had a fucky wucky
            System.Environment.Exit(1);
        }
    }
}